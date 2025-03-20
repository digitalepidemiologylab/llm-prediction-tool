# frozen_string_literal: true

require "csv"

module Results
  class ProcessRowJob < ApplicationJob
    queue_as :default

    def perform(result:, index:)
      result.process! if result.initial?
      return unless result.processing?

      row = parse_row(result:, index:)
      if row.nil?
        # no more rows to process
        result.complete!
        return
      end

      user_messages = messages(row:)
      begin
        Results::SaveService.new(result:).call(index:, user_messages:)
        self.class.perform_later(result:, index: index + 1) # queue next row
      rescue Results::SaveService::UnrecoverableError => e
        Sentry.capture_exception(e) # Do not retry
        result.fail!
      end
    end

    # Convert flat row to JSON hierarchy of messages
    private def messages(row:)
      cols = row.headers.filter_map { _1.match(/\A(?<msg_idx>\d+)_MSG_(?<type_idx>\d+)_(?<type>.*)\z/) }
      cols.group_by { _1[:msg_idx].to_i }.sort_by { _1.first }.map do |_msg_idx, headers|
        content = headers.sort_by { _1[:type_idx].to_i }.filter_map do |header|
          data = row[header.string]
          case header[:type].downcase.to_sym
          when :text
            {type: :text, text: data}
          when :image
            {type: :image_url, image_url: {detail: :high, url: data}}
          end
        end
        {role: :user, content:}
      end
    end

    private def parse_row(result:, index:)
      col_sep = result.experiment.dataset.column_separator
      result.experiment.dataset.evaluation.open do |stream|
        CSV.open(stream, "r", headers: true, encoding: Encoding::UTF_8, col_sep:) do |csv|
          index.times { csv.shift }
          csv.shift
        end
      end
    end
  end
end

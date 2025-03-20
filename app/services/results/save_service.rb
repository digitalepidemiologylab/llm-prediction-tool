# frozen_string_literal: true

module Results
  class SaveService
    class TemporaryError < StandardError; end # may retry later

    class UnrecoverableError < StandardError; end # may not proceed

    def initialize(result:)
      @result = result
    end

    def call(index:, user_messages:)
      response = fetch_response(user_messages:)
      if response[:skip]
        handle_skip!(index:)
        return
      end

      case response[:code]
      when 200
        handle_success!(index:, response:)
      when 429, 500..599
        handle_temporary_error!(response:)
      else
        handle_unrecoverable_error!(response:)
      end
    end

    private def fetch_response(user_messages:)
      adapter_class.new(experiment: @result.experiment, user_messages:).create
    rescue Exception => e # rubocop:disable Lint/RescueException
      handle_unrecoverable_error!(response: {error: e.message})
    end

    private def handle_success!(index:, response:)
      result_data = response[:success]
      @result.with_lock do
        @result.reload.data["annotations"] ||= {}
        @result.data["annotations"][index.to_s] = result_data
        @result.save!
      end
    end

    private def handle_skip!(index:)
      @result.with_lock do
        @result.reload.data["skipped"] ||= []
        @result.data["skipped"] << index
        @result.save!
      end
    end

    private def handle_temporary_error!(response:)
      raise TemporaryError, "Temporarary #{provider} API error #{response[:code]}"
    end

    private def handle_unrecoverable_error!(response:)
      message = response[:error]
      message = "#{provider} API error #{response[:code]}: #{message}" if response[:code].present?
      @result.with_lock do
        @result.reload.data["error"] ||= {}
        @result.data["error"]["message"] = message
        @result.save!
      end
      raise UnrecoverableError, message
    end

    private def adapter_class
      case provider
      when "openai"
        Openai::ChatAdapter
      when "gemini"
        Gemini::ChatAdapter
      when "anthropic"
        Anthropic::ChatAdapter
      when "huggingface"
        Huggingface::ChatAdapter
      else
        raise UnrecoverableError, "LLM provider #{@result.experiment.llm.provider} not supported"
      end
    end

    private def provider
      @result.experiment.llm.provider
    end
  end
end

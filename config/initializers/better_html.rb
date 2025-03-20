# frozen_string_literal: true

if Rails.env.in?(%w[development test])
  BetterHtml.configure do |config|
    config.template_exclusion_filter = proc do |filename|
      !filename.start_with?(Rails.root.to_s)
    end
  end
end

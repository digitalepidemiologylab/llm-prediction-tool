# frozen_string_literal: true

# https://docs.anthropic.com/en/api/getting-started
module Anthropic
  class ChatAdapter < BaseChatAdapter
    base_uri "https://api.anthropic.com/v1/messages"

    def create
      response = super(args: {headers:, body:})
      {
        code: response.code,
        success: response.parsed_response.dig("content", 0, "text"),
        error: response.parsed_response.dig("error", "message")
      }
    end

    private def headers
      api_key = @experiment.dataset.user.llm_credentials.dig(:anthropic, :api_key)
      {
        "Content-Type" => "application/json",
        "Anthropic-Version" => "2023-06-01", # https://docs.anthropic.com/en/api/versioning
        "X-Api-Key" => api_key
      }
    end

    private def body_hash
      ensure_no_images!
      {
        **@experiment.llm.parameters,
        model: @experiment.llm.codename,
        system: instruction_message,
        messages: @user_messages
      }
    end

    private def instruction_message
      "#{@experiment.system_prompt}\n\n#{json_coercion_note}"
    end
  end
end

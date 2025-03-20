# frozen_string_literal: true

# https://platform.openai.com/docs/api-reference/chat/create
module Openai
  class ChatAdapter < BaseChatAdapter
    base_uri "https://api.openai.com/v1/chat/completions"

    def create
      response = super(args: {headers:, body:})
      data = response.parsed_response.deep_symbolize_keys
      {
        code: response.code,
        success: data.dig(:choices, 0, :message, :content),
        error: data.dig(:error, :message),
        skip: response.code == 500 && data.dig(:error, :type) == "model_error"
      }
    end

    private def headers
      bearer = @experiment.dataset.user.llm_credentials.dig(:openai, :bearer_token)
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{bearer}"
      }
    end

    private def body_hash
      {
        **@experiment.llm.parameters,
        model: @experiment.llm.codename,
        messages: [
          instruction_message,
          *@user_messages
        ]
      }
    end

    private def instruction_message
      role = @experiment.llm.data.fetch("instruction_role") { "user" }
      content = [{type: :text, text: @experiment.system_prompt}]
      if !@experiment.llm.parameters.key?("response_format")
        content << {type: :text, text: json_coercion_note}
      end
      {role:, content:}
    end
  end
end

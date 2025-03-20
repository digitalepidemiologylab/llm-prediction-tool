# frozen_string_literal: true

# https://ai.google.dev/gemini-api/docs/models/gemini
module Gemini
  class ChatAdapter < BaseChatAdapter
    base_uri "https://generativelanguage.googleapis.com/v1beta/models"

    def create
      response = super(path:, args: {query:, headers:, body:})
      {
        code: response.code,
        success: response.parsed_response.dig("candidates", 0, "content", "parts", 0, "text"),
        error: response.parsed_response.dig("error", "message")
      }
    end

    private def path
      "/#{@experiment.llm.codename}:generateContent"
    end

    private def query
      {key: @experiment.dataset.user.llm_credentials.dig(:gemini, :api_key)}
    end

    private def headers
      {"Content-Type" => "application/json"}
    end

    private def body_hash
      ensure_no_images!
      contents = @user_messages.map do |message|
        {
          role: (message[:role] == "assistant") ? "model" : message[:role],
          parts: message[:content].map { |part| {text: part[:text]} }
        }
      end
      {
        system_instruction: {parts: {text: @experiment.system_prompt}},
        contents:,
        generationConfig: @experiment.llm.parameters
      }
    end
  end
end

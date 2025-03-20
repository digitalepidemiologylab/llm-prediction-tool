# frozen_string_literal: true

# The API can be used in 3 ways.
# * Serverless (< 10GB)
#   https://huggingface.co/docs/api-inference/getting-started
#   Costs: per-token
# * Third-party
#   https://huggingface.co/blog/inference-providers
#   Costs: per-token
# * Dedicated (User-deployed)
#   https://huggingface.co/docs/inference-endpoints
#   Costs: hourly rate while running, free when scaled-to-zero after period of inactivity
# Cold models return 503 for 5–10 minutes while warming up.
module Huggingface
  class ChatAdapter < BaseChatAdapter
    def create
      response = super(path:, args: {headers:, body:})
      {
        code: response.code,
        success: success_content(response:),
        error: error_message(response:)
      }
    end

    private def path
      llm = @experiment.llm
      base_url = if llm.deployed_by_user.present?
        "https://#{llm.host}.endpoints.huggingface.cloud" # Dedicated
      elsif llm.host.present?
        "https://router.huggingface.co/#{llm.host}" # Third-party
      else
        "https://api-inference.huggingface.co/models/#{llm.codename}" # Serverless
      end
      base_url + "/v1/chat/completions"
    end

    # Note: `"X-Wait-For-Model" => "true"` waits for cold models to warm up, but it
    #   will wait FOREVER if the model cannot be warmed (e.g. serverless and larger than 10GB)
    private def headers
      token = @experiment.dataset.user.llm_credentials.dig(:huggingface, :token)
      {
        "Content-Type" => "application/json",
        "X-Use-Cache" => "false", # non-deterministism
        "Authorization" => "Bearer #{token}"
      }
    end

    private def body_hash
      ensure_no_images!
      {
        **@experiment.llm.parameters,
        model: @experiment.llm.codename,
        messages: [
          instruction_message,
          *@user_messages
        ]
      }
    end

    # Note: We try to coerce JSON because response_format would require a full schema.
    private def instruction_message
      {
        role: "system",
        content: [
          {type: :text, text: @experiment.system_prompt},
          {type: :text, text: json_coercion_note}
        ]
      }
    end

    private def success_content(response:)
      return unless (200..299).cover?(response.code)

      response.parsed_response.dig("choices", 0, "message", "content")
    end

    private def error_message(response:)
      return unless response.code >= 400

      data = response.parsed_response
      if data.is_a?(Hash)
        # Response "Content-Type": "application/json"
        data["error"]
      else
        # Response "Content-Type": "text/plain; charset=utf-8"
        data
      end
    end
  end
end

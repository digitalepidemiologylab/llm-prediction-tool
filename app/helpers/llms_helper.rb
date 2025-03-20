# frozen_string_literal: true

module LlmsHelper
  PROVIDER_NAMES = {
    "anthropic" => "Anthropic",
    "gemini" => "Gemini",
    "huggingface" => "Hugging Face",
    "openai" => "OpenAI"
  }.freeze

  # Provider headings for grouped_collection_select of LLMs
  def provider_name(provider)
    PROVIDER_NAMES.fetch(provider) { provider.to_s.titleize }
  end
end

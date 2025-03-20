# frozen_string_literal: true

class BaseChatAdapter
  include HTTParty

  class NetworkError < StandardError; end

  # Wait up to 10 minutes, as some models can take a long time to generate the full response.
  default_timeout 600

  def initialize(experiment:, user_messages:)
    @experiment = experiment
    @user_messages = user_messages
  end

  def create(args:, path: nil)
    self.class.post(path || self.class.base_uri, **args)
  rescue => e
    Sentry.capture_exception(e)
    raise NetworkError, "Service is not currently accessible (#{e.message})."
  end

  protected def body
    JSON.generate(body_hash) # concrete implementation in subclasses
  end

  protected def json_coercion_note
    "(Note: Your response *must* only contain RFC8259 JSON data. No preamble, markdown, code fences, or explanations.)"
  end

  # removable once all providers support images
  protected def ensure_no_images!
    @user_messages.each do |message|
      message[:content].pluck(:type).each do |type|
        if type == :image_url
          raise NotImplementedError, "Provider does not yet support images"
        end
      end
    end
  end
end

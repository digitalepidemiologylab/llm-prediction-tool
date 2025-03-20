# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # TODO: We need our own domain so we can set up DKIM and mandrill
  default from: "noreply-llmbench@myfoodrepo.org"
  layout "mailer"
end

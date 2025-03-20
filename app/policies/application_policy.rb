# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, I18n.t("devise.failure.unauthenticated") if user.blank?

    @user = user
    @record = record
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  class Scope
    private attr_reader(:user, :scope)

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, I18n.t("devise.failure.unauthenticated") if user.blank?

      @user = user
      @scope = scope
    end
  end
end

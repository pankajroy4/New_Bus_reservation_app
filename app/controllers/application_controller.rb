class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  before_action :store_user_location!, if: :storable_location?
  before_action :set_locale

  private

  def user_not_authorized
    redirect_to root_path,
                alert: "You are not authorized to access this page."
  end

  def handle_not_found
    redirect_to root_path, alert: "Record not found"
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def set_locale
    I18n.locale = current_user.try(:locale) || I18n.default_locale
  end
end

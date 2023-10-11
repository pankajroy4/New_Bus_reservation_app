class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  private

  def user_not_authorized
    redirect_to root_path,
                alert: "You are not authorized to access this page."
  end

  def handle_not_found
    redirect_to root_path, alert: "Record not found"
  end
end

class HomesController < ApplicationController
  def index
    @approved_buses = Bus.where(approved: true)
    respond_to do |format|
      format.json { render json: @approved_buses }
      format.html { render :index }
    end
  end

  def search
    string = params[:user_query]
    @approved_buses = Bus.approved.search_by_name_or_route(string)
    respond_to do |format|
      format.json { render json: @approved_buses }
      format.html { render :search }
    end
  end

  def change_locale 
    if current_user.update(locale: params[:locale])
      I18n.locale = current_user.try(:locale) || I18n.default_locale
      redirect_to root_path, notice: "Language updated successfully!."
    else
      redirect_to root_path, notice: "Please try later!."
    end
  end

  def not_found
    render file: "public/404.html", status: :not_found
  end
end

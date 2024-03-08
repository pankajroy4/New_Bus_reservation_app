class HomesController < ApplicationController
  def index
    @approved_buses = Bus.includes(:user, main_image_attachment: :blob).where(approved: true)
    respond_to do |format|
      format.json { render json: @approved_buses }
      format.html { render :index }
    end
  end

  def search
    string = params[:user_query]
    @approved_buses = Bus.approved.search_by_name_or_route(string).includes(:user, main_image_attachment: :blob)
    respond_to do |format|
      format.json { render json: @approved_buses }
      format.html { render :search }
    end
  end

  def not_found
    render file: "public/404.html", status: :not_found
  end
end

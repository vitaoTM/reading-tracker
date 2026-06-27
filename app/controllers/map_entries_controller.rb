class MapEntriesController < ApplicationController
  before_action :require_authentication

  def index
    @entries = Current.user.map_entries.includes(:book)
    @filled  = Current.user.map_data
    @books_per_country = Current.user.books_per_country
  end

  def create
    entry = Current.user.map_entries.find_or_initialize_by(country_code: params[:country_code])
    entry.assign_attributes(color: params[:color], book_id: params[:book_id].presence, auto_filled: false)
    if entry.save
      head :ok
    else
      render json: { error: entry.errors.full_messages.to_sentence }, status: :unprocessable_entity

    end
  end

  def destroy
    Current.user.map_entries.find_by!(country_code: params[:country_code]).destroy
    head :ok
  end
end

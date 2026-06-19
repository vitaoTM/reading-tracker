class FavoriteBooksController < ApplicationController
  before_action :require_authentication

  def create
    @favorite = Current.user.favorite_books.new(favorite_params)
    if @favorite.save
      redirect_back fallback_location: root_path, notice: "Added to favorites"
    else
      redirect_back fallback_location: root_path, alert: @favorite.errors.full_messages.to_sentence
    end
  end

  def destroy
    Current.user.favorite_books.find(params[:id]).destroy
    redirect_back fallback_location: root_path
  end

  def reorder
    Array(params[:ordered_ids]).each_with_index do |id, i|
      Current.user.favorite_books.find(id).update!(position: i + 1)
    end

    head :ok
  end
  private

  def favorite_params
    params.require(:favorite_book).permit(:book_id, :position)
  end
end

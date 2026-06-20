class RatingsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @rating = Current.user.ratings.find_or_initialize_by(book: @book)
    @rating.assign_attributes(rating_params)

    if @rating.save
      redirect_to @book, notice: "Rating saved successfully."
    else
      redirect_to @book, alert: "Failed to save rating: #{@rating.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @rating = Current.user.ratings.find(params[:id])
    book = @rating.book
    @rating.destroy
    redirect_to book, notice: "Rating removed."
  end

  private

  def rating_params
    params.require(:rating).permit(:score, :review)
  end
end

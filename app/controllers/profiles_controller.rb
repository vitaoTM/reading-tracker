class ProfilesController < ApplicationController
  skip_before_action :require_authentication

  def show
    @user             = User.find_by(username: params[:username])
    return render file: "public/404.html", status: :not_found unless @user
    @favorites        = @user.favorite_books.includes(:book)
    @reading          = @user.currently_reading
    @public_lists     = @user.recommendation_lists.public_lists.includes(items: :book)
    @map_data         = @user.map_data
    @stats            = @user.reading_stats
  end
end

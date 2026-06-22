class RecommendationListItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_list

  def create
    @item = @list.items.new(item_params)
    if @item.save
      redirect_back fallback_location: @list, notice: "Book added"
    else
      redirect_back fallback_location: @list, alert: @item.errors.full_messages.to_sentence
    end
  end

  def update
    @item = @list.items.find(params[:id])
    @item.update!(item_params)
    redirect_back fallback_location: @list
  end

  def destroy
    @list.items.find(params[:id]).destroy
    redirect_back fallback_location: @list
  end

  private

  def set_list
    @list = Current.user.recommendation_lists.find(params[:recommendation_list_id])
  end

  def item_params
    params.require(:recommendation_list_item).permit(
      :book_id, :position, :note
    )
  end
end

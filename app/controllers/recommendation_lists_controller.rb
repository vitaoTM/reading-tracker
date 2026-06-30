class RecommendationListsController < ApplicationController
  before_action :require_authentication, except: [ :discover ]
  before_action :set_list, only: [ :show, :edit, :update, :destroy ]

  def index
    @lists = Current.user.recommendation_lists.includes(items: :book)
  end

  def show
  end

  def new
    @list = Current.user.recommendation_lists.new
  end

  def create
    @list = Current.user.recommendation_lists.new(list_params)
    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, notice: "List Created" }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to @list, notice: "List updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to recommendation_lists_path }
      format.turbo_stream
    end
  end

  def discover
    @lists = RecommendationList.public_lists
      .includes(:user, items: :book)
      .order(created_at: :desc)
      .limit(50)
  end

  private

  def set_list
    @list = Current.user.recommendation_lists.find(params[:id])
  end

  def list_params
    params.require(:recommendation_list).permit(
      :title, :description, :public
    )
  end
end

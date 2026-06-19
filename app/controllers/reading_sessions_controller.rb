class ReadingSessionsController < ApplicationController
  def index
    @stats   = Current.user.reading_stats
    @recent  = Current.user.reading_sessions.order(read_on: :desc).limit(30)
    @heatmap = Current.user.reading_sessions
      .where(read_on: 90.days.ago..Date.current)
      .group(:read_on)
      .sum(:duration_minutes)
  end

  def create
    Current.user.reading_sessions.create!(session_params)
    redirect_to habits_path, notice: "Session logged"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to habits_path, alert: e.message
  end

  def destroy
    Current.user.reading_sessions.find(params[:id]).destroy
    redirect_to habits_path
  end

  private

  def session_params
    params.require(:reading_session).permit(
      :book_id, :read_on, :duration_minutes, :pages_read, :notes
    )
  end
end

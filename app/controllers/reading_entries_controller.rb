class ReadingEntriesController < ApplicationController
  def index
    @entries = Current.user.reading_entries.includes(:book).group_by(&:status)
  end

  def create
    @entry = Current.user.reading_entries.new(entry_params)
    if @entry.save
      redirect_back fallback_location: book_path(@entry.book), notice: "Added"
    else
      redirect_back fallback_location: root_path, alert: @entry.errors.full_messages.to_sentence
    end
  end

  def update
    @entry = Current.user.reading_entries.find(params[:id])
    @entry.update!(entry_params)
    redirect_back fallback_location: library_path
  end

  def destroy
    Current.user.reading_entries.find(params[:id]).destroy
    redirect_back fallback_location: library_path
  end

  private

  def entry_params
    params.require(:reading_entry).permit(
      :book_id, :status, :started_at, :finished_at,
      :notes, :discovery_source, :citation
    )
  end
end

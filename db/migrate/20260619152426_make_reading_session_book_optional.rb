class MakeReadingSessionBookOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :reading_sessions, :book_id, true
  end
end

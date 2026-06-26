class ReadingEntry < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum :status, {
    reading: 1,
    want_to_read: 0,
    finished: 2,
    not_finished: 3
  }

  validates :book_id, uniqueness: { scope: :user_id }
  validates :status, presence: true

  after_save :sync_map_entry

  private

  def sync_map_entry
    MapEntryAutoFiller.call(self)
  end
end

class ReadingEntry < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum :status, {
    want_to_read: 0,
    reading: 1,
    finished: 2,
    dnf: 3
  }

  validates :book_id, uniqueness: { scope: :user_id }
  validates :status, presence: true

  after_save :sync_map_entry

  private

  def sync_map_entry
    MapEntryAutoFiller.call(self)
  end
end

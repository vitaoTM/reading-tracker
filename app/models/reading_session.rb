class ReadingSession < ApplicationRecord
  belongs_to :user
  belongs_to :book, optional: true

  validates :read_on, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
  validates :pages_read, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :on_day, ->(date) { where(read_on: date) }
  scope :in_range, ->(from, to) { where(read_on: from..to) }
end

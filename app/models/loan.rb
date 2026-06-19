class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :book, optional: true

  enum :direction, { borrowed: 0, lent: 1 }

  validates :counterparty_name, presence: true
  validates :loaned_on, presence: true
  validates :direction, presence: true
  validate  :has_book_reference

  scope :open,    -> { where(returned_on: nil) }
  scope :closed,  -> { where.not(returned_on: nil) }

  def display_title
    book&.title || book_title
  end

  private

  def has_book_reference
    if book.nil? && book_title.blank?
      errors.add(:base, "must reference a book or provide a title")
    end
  end
end

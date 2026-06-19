class FavoriteBook < ApplicationRecord
  MAX_FAVORITES = 20

  belongs_to :user
  belongs_to :book

  validates :book_id, uniqueness: { scope: :user_id }
  validates :position, numericality: { in: 1..MAX_FAVORITES }
  validate  :shelf_not_full, on: :create

  default_scope { order(:position) }

  private

  def shelf_not_full
    if user && user.favorite_books.count >= MAX_FAVORITES
      errors.add(:base, "Shelf is full (max #{MAX_FAVORITES} books")
    end
  end
end

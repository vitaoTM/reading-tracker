class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :score, inclusion: { in: 1..5 }
  validates :book_id, uniqueness: { scope: :user_id }

  after_save    :update_book_cache
  after_destroy :update_book_cache

  private

  def update_book_cache
    avg = book.ratings.average(:score)&.round(2) || 0
    book.update_columns(
      cached_average_rating: avg,
      ratings_count: book.ratings.count
    )
  end
end

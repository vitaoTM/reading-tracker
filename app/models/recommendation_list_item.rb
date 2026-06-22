class RecommendationListItem < ApplicationRecord
  belongs_to :recommendation_list
  belongs_to :book

  validates :book_id, uniqueness: { scope: :recommendation_list_id }
  validate :list_not_full

  after_create :bump_book_count
  after_destroy :decrement_book_count

  private

  def list_not_full
    if recommendation_list && recommendation_list.items.count >= RecommendationList::MAX_ITEMS
      errors.add(:base, "List is full (max #{RecommendationList::MAX_ITEMS})")
    end
  end

  def bump_book_count
    book.increment!(:recommendation_count) if recommendation_list.public?
  end

  def decrement_book_count
    book.decrement!(:recommendation_count) if recommendation_list.public? && book.recommendation_count > 0
  end
end

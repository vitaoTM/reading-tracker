require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "valid rating" do
    assert build(:rating).valid?
  end

  test "score must be 1-5" do
    refute build(:rating, score: 0).valid?
    refute build(:rating, score: 6).valid?
    assert build(:rating, score: 3).valid?
  end

  test "user cannot rate same book twice" do
    user = create(:user)
    book = create(:book)
    create(:rating, user: user, book: book, score: 4)
    refute build(:rating, user: user, book: book, score: 5).valid?
  end

  test "book cache updates on rating save" do
    book = create(:book)
    create(:rating, book: book, score: 5)
    create(:rating, book: book, score: 3)
    assert_equal 4.0, book.reload.cached_average_rating.to_f
    assert_equal 2, book.ratings_count
  end
end

require "test_helper"

class FavoriteBookTest < ActiveSupport::TestCase
  test "valid favorite" do
    assert build(:favorite_book, position: 1).valid?
  end

  test "cannot favorite same book twice" do
    user = create(:user)
    book = create(:book)
    create(:favorite_book, user: user, book: book, position: 1)
    refute build(:favorite_book, user: user, book: book, position: 2).valid?
  end

  test "shelf maxes out at 20" do
    user = create(:user)
    20.times { |i| user.favorite_books.create!(book: create(:book), position: i + 1) }
    over_limit = user.favorite_books.build(book: create(:book), position: 21)
    refute over_limit.valid?
    assert_includes over_limit.errors[:base].join, "Shelf is full"
  end

  test "ordered by position" do
    user = create(:user)
    create(:favorite_book, user: user, book: create(:book), position: 3)
    create(:favorite_book, user: user, book: create(:book), position: 1)
    create(:favorite_book, user: user, book: create(:book), position: 2)
    assert_equal [ 1, 2, 3 ], user.favorite_books.pluck(:position)
  end
end

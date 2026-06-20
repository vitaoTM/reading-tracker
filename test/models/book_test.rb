require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "valid book passes validation" do
    assert build(:book).valid?
  end

  test "title is required" do
    refute build(:book, title: nil).valid?
  end

  test "age_indicator must be from list" do
    refute build(:book, age_indicator: "invalid").valid?
    assert build(:book, age_indicator: "young_adult").valid?
  end

  test "recommendation_count defaults to 0" do
    book = create(:book)
    assert_equal 0, book.recommendation_count
  end

    test "blank isbn is stored as nil" do
    book = create(:book, isbn: "")
    assert_nil book.reload.isbn
  end

  test "two books without isbn can coexist" do
    create(:book, isbn: "")
    assert_nothing_raised { create(:book, isbn: "") }
  end
end

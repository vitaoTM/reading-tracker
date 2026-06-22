require "test_helper"

class RecommendationListTest < ActiveSupport::TestCase
  test "list with items" do
    list = create(:recommendation_list, title: "Top Horror")
    3.times { |i| list.items.create!(book: create(:book), position: i + 1) }
    assert_equal 3, list.items.count
  end

  test "max 10 items per list" do
    list = create(:recommendation_list)
    10.times { |i| list.items.create!(book: create(:book), position: i + 1) }
    overflow = list.items.build(book: create(:book), position: 11)
    refute overflow.valid?
    assert_includes overflow.errors[:base].join, "List is full"
  end

  test "public lists visible via scope" do
    public_list  = create(:recommendation_list, public: true)
    private_list = create(:recommendation_list, public: false)
    assert_includes RecommendationList.public_lists, public_list
    refute_includes RecommendationList.public_lists, private_list
  end

  test "adding item to public list bumps book.recommendation_count" do
    list = create(:recommendation_list, public: true)
    book = create(:book)
    assert_difference("book.reload.recommendation_count", 1) do
      list.items.create!(book: book, position: 1)
    end
  end

  test "private list does NOT bump count" do
    list = create(:recommendation_list, public: false)
    book = create(:book)
    assert_no_difference("book.reload.recommendation_count") do
      list.items.create!(book: book, position: 1)
    end
  end

  test "removing item decrements count" do
    list = create(:recommendation_list, public: true)
    book = create(:book)
    item = list.items.create!(book: book, position: 1)
    assert_difference("book.reload.recommendation_count", -1) do
      item.destroy
    end
  end
end

require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "name is downcased" do
    tag = Tag.create!(name: "FANTASY")
    assert_equal "fantasy", tag.name
  end

  test "duplicates rejected" do
    Tag.create!(name: "horror")
    refute Tag.new(name: "Horror").valid?
  end

  test "book can be tagged via tag_names=" do
    book = create(:book)
    book.tag_names = [ "fantasy", "translated" ]
    book.save!
    assert_equal [ "fantasy", "translated" ].sort, book.reload.tag_names.sort
  end
end

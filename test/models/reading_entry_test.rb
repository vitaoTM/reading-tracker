require "test_helper"

class ReadingEntryTest < ActiveSupport::TestCase
  test "valid entry" do
    assert build(:reading_entry).valid?
  end

  test "user cannot have two entries for same book" do
    user = create(:user)
    book = create(:book)
    create(:reading_entry, user: user, book: book)
    duplicate = build(:reading_entry, user: user, book: book)
    refute duplicate.valid?
  end

  test "status enum works" do
    entry = create(:reading_entry, status: :reading)
    assert entry.reading?
    refute entry.finished?
  end

  test "user.currently_reading returns reading books" do
    user = create(:user)
    reading_book = create(:book, title: "Reading Now")
    finished_book = create(:book, title: "Done")
    create(:reading_entry, user: user, book: reading_book, status: :reading)
    create(:reading_entry, user: user, book: finished_book, status: :finished)

    assert_includes user.currently_reading, reading_book
    refute_includes user.currently_reading, finished_book
  end

  test "stores notes, discovery_source, citation" do
    entry = create(:reading_entry,
      notes: "Loved chapter 3",
      discovery_source: "Recommended by a friend",
      citation: "All happy families are alike")
    entry.reload
    assert_equal "Loved chapter 3", entry.notes
    assert_match "friend", entry.discovery_source
    assert_match "happy families", entry.citation
  end
end

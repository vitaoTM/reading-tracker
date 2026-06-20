require "test_helper"

class ReadingEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
    @book = create(:book)
  end

  test "library page renders" do
    get library_url
    assert_response :success
  end

  test "create adds entry" do
    assert_difference("ReadingEntry.count", 1) do
      post reading_entries_url, params: {
        reading_entry: { book_id: @book.id, status: "reading", discovery_source: "Library" }
      }
    end
  end

  test "update changes status" do
    entry = create(:reading_entry, user: @user, book: @book, status: :reading)
    patch reading_entry_url(entry), params: {
      reading_entry: { status: "finished", finished_at: Date.today }
    }
    assert_equal "finished", entry.reload.status
  end

  test "want_to_read page lists only want_to_read entries" do
    reading_book = create(:book)
    to_read_book = create(:book)
    create(:reading_entry, user: @user, book: reading_book, status: :reading)
    create(:reading_entry, user: @user, book: to_read_book, status: :want_to_read)

    get want_to_read_url
    assert_response :success
    assert_match to_read_book.title, response.body
    refute_match reading_book.title, response.body
  end
end

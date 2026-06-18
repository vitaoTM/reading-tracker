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
end

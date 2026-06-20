require "test_helper"

class ReadingSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
  end

  test "habits page renders with stats" do
    create(:reading_session, user: @user, pages_read: 50, duration_minutes: 60)
    get habits_url
    assert_response :success
    assert_match "60", response.body
  end

  test "create logs a session" do
    book = create(:book)
    assert_difference("ReadingSession.count", 1) do
      post reading_sessions_url, params: {
        reading_session: { book_id: book.id, read_on: Date.current, duration_minutes: 30, pages_read: 20 }
      }
    end
    assert_redirected_to habits_path
  end

  test "destroy removes a session" do
    session = create(:reading_session, user: @user)
    assert_difference("ReadingSession.count", -1) do
      delete reading_session_url(session)
    end
    assert_redirected_to habits_path
  end
end

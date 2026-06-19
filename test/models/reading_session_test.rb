require "test_helper"

class ReadingSessionTest < ActiveSupport::TestCase
  test "valid session" do
    assert build(:reading_session).valid?
  end

  test "duration must be positive" do
    refute build(:reading_session, duration_minutes: 0).valid?
  end

  test "session without book is valid" do
    assert build(:reading_session, book: nil).valid?
  end

  test "reading_stats sums correctly" do
    user = create(:user)
    create(:reading_session, user: user, duration_minutes: 30, pages_read: 20, read_on: Date.current)
    create(:reading_session, user: user, duration_minutes: 45, pages_read: 30, read_on: Date.current - 1)

    stats = user.reading_stats
    assert_equal 75, stats[:total_minutes]
    assert_equal 50, stats[:total_pages]
    assert_equal 2,  stats[:days_active]
  end

  test "streak counts consecuteve days from current" do
    user = create(:user)
    (0..4).each { |i| create(:reading_session, user: user, read_on: Date.current - i.days) }
    assert_equal 5, user.current_streak
  end

  test "streak breaks on gap" do
    user = create(:user)
    create(:reading_session, user: user, read_on: Date.current)
    create(:reading_session, user: user, read_on: Date.current - 1)
    create(:reading_session, user: user, read_on: Date.current - 3)
    assert_equal 2, user.current_streak
  end
end

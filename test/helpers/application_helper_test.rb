require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "format_duration with nil" do
    assert_equal "0m", format_duration(nil)
  end

  test "format_duration with 0" do
    assert_equal "0m", format_duration(0)
  end

  test "format_duration with minutes less than an hour" do
    assert_equal "45m", format_duration(45)
  end

  test "format_duration with minutes equal to an hour" do
    assert_equal "1h 0m", format_duration(60)
  end

  test "format_duration with multiple hours and minutes" do
    assert_equal "2h 15m", format_duration(135)
  end
end

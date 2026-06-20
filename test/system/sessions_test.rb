require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "visiting the sign in page" do
    visit new_session_url
    assert_selector "h1", text: "Sign in"
  end
end

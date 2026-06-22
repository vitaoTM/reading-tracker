require "application_system_test_case"
require "test_helper"

class FavoritesTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, email_address: "john@example.com", password: "password")
    sign_in_as(@user)
    @book = create(:book, title: "The Great Gatsby", author: "F. Scott Fitzgerald")

    # Sign in
  end

  test "user can add and remove favorite books" do
    # Navigate to book page
    visit book_path(@book)

    # Click Add
    assert_button "☆ Add to Favorites"
    click_on "☆ Add to Favorites"

    # Check toggled state (using exact button text with filled star)
    assert_button "★ Favorited"

    # Visit favorites page
    visit favorites_url
    assert_text "My Favorites"
    assert_link "The Great Gatsby"

    # Test clicking link navigates to book page
    click_on "The Great Gatsby"
    assert_current_path book_path(@book)

    # Test deletion
    visit favorites_url
    click_on "×"
    assert_text "You don't have any favorite books yet"
  end
end

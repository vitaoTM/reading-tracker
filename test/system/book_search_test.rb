require "application_system_test_case"
require "test_helper"

class BookSearchTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    sign_in_as(@user)
    @dune = create(:book, title: "Dune", author: "Frank Herbert")
    @foundation = create(:book, title: "foundation", author: "Isaac Asimov")
  end

  test "user can search and filter books on the library index" do
    visit books_url

    assert_text "Dune"
    assert_text "foundation"

    fill_in "q", with: "Dune"
    click_on "Search"

    assert_text "Dune"
    refute_text "foundation"
    assert_text 'Results for "Dune"'

    click_on "Clear"

    assert_text "Dune"
    assert_text "foundation"
  end
end

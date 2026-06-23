require "application_system_test_case"

class MapTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, email_address: "ex@example.com", password: "password")
    sign_in_as(@user)
  end

  test "user can mark and clear countries on the map" do
    visit map_url
    assert_text "My Reading Map"

    # Verify SVG map is loaded
    assert_selector "svg"
    #
    # # Click on a country (e.g. Brazil - BR)
    find("path#BR.land").click
    #
    # # Assert map panel color configuration card appears
    assert_selector "#map-panel"
    assert_selector "#map-panel-title", text: "BR"
    #
    # # Save color
    click_on "Save Color"
    #
    # # Verify country code appears under 'Marked countries' (Capybara waits for JS reload)
    assert_text "BR"
    #
    # # Clear country
    find("path#BR").click
    click_on "Clear"
    #
    # # Verify country code is removed from list (Capybara waits for JS reload)
    refute_text "BR"
  end
end

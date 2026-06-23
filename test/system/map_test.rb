require "application_system_test_case"

class MapTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, email_address: "ex@example.com", password: "password")
    sign_in_as(@user)
  end

  test "user can mark and clear countries on the map" do
    visit map_url
    assert_text "My Reading Map"

    # Wait until Stimulus has connected and bound click listeners
    assert_selector "[data-world-map-connected='true']"

    # Verify SVG map is loaded
    assert_selector "svg"

    # Click on Brazil (using JS dispatchEvent to click safely on SVG element in headless CI)
    find("path#BR.land").execute_script("this.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable:
true }));")

    # Assert map panel color configuration card appears
    assert_selector "#map-panel"
    assert_selector "#map-panel-title", text: "BR"

    # Save color
    click_on "Save Color"

    # Verify country code appears under 'Marked countries' (waits for JS reload)
    # assert_text "BR"

    # Click Brazil again to clear (using JS dispatchEvent)
    find("path#BR").execute_script("this.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true
}));")
    click_on "Clear"

    # Verify country code is removed from list (waits for JS reload)
    refute_text "BR"
  end
end

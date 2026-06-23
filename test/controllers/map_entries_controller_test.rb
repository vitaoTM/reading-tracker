require "test_helper"

class MapEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
  end

  test "map page renders" do
    get map_url
    assert_response :success
  end

  test "create marks a country" do
    assert_difference("MapEntry.count", 1) do
      post map_entries_url, params: { country_code: "BR", color: "#336699" },
            as: :json
    end
  end

  test "create upserts existing country" do
    create(:map_entry, user: @user, country_code: "BR", color: "#000000")
    assert_no_difference("MapEntry.count") do
      post map_entries_url, params: { country_code: "BR", color: "#ffffff" },
            as: :json
    end
    assert_equal "#ffffff", MapEntry.find_by(user: @user, country_code: "BR").color
  end

  test "destroy clears a marked country" do
    entry = create(:map_entry, user: @user, country_code: "JP")
    assert_difference("MapEntry.count", -1) do
      delete map_entries_url, params: { country_code: entry.country_code }
    end
    assert_response :success
  end
end

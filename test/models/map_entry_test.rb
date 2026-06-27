require "test_helper"

class MapEntryTest < ActiveSupport::TestCase
  test "uppercases country code" do
    entry = create(:map_entry, country_code: "br")
    assert_equal "BR", entry.country_code
  end

  test "validates ISO 2-letter format" do
    refute build(:map_entry, country_code: "Brazil").valid?
    refute build(:map_entry, country_code: "BRA").valid?
    assert build(:map_entry, country_code: "BR").valid?
  end

  test "validates hex color" do
    refute build(:map_entry, color: "red").valid?
    assert build(:map_entry, color: "#FF5733").valid?
    assert build(:map_entry, color: nil).valid?
  end

  test "one entry per country per user" do
    user = create(:user)
    create(:map_entry, user: user, country_code: "JP")
    refute build(:map_entry, user: user, country_code: "JP").valid?
  end

  test "map_data returns country-to-color hash" do
    user = create(:user)
    create(:map_entry, user: user, country_code: "BR", color: "#00FF00")
    create(:map_entry, user: user, country_code: "JP", color: "#FF0000")
    assert_equal({ "BR" => "#00FF00", "JP" => "#FF0000" }, user.map_data)
  end

  test "auto_filled defaults to false" do
    entry = create(:map_entry)
    refute entry.auto_filled?
  end
end

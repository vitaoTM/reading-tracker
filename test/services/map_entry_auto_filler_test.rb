require "test_helper"

class MapEntryAutoFillerTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @book = create(:book, country_of_origin: "BR")
  end

  test "creates amber map entry when book marked reading" do
    @user.reading_entries.create!(book: @book, status: :reading)
    entry = @user.map_entries.find_by(country_code: "BR")
    assert entry, "Expected a MapEntry for BR"

    assert_equal MapEntry::READING_COLOR, entry.color
    assert entry.auto_filled
  end

  test "creates a green map entry when book marked finished" do
    @user.reading_entries.create!(book: @book, status: :finished)
    assert_equal MapEntry::FINISHED_COLOR, @user.map_entries.find_by(country_code: "BR").color
  end

  test "updates color when same book moves from reading to finished" do
    re = @user.reading_entries.create!(book: @book, status: :reading)
    re.update!(status: :finished)
    assert_equal MapEntry::FINISHED_COLOR, @user.map_entries.find_by(country_code: "BR").color
  end

  test "does not overwrite a manual map entry" do
    create(:map_entry, user: @user, country_code: "BR", color: "#123456", auto_filled: false)
    @user.reading_entries.create!(book: @book, status: :finished)
    assert_equal "#123456", @user.map_entries.find_by(country_code: "BR").color
  end

  test "skips books with non-ISO country_of_origin" do
    book = create(:book, country_of_origin: "Brazil")
    @user.reading_entries.create!(book: book, status: :finished)
    assert_equal 0, @user.map_entries.count
  end

  test "skips want_to_read and dnf status" do
    @user.reading_entries.create!(book: @book, status: :want_to_read)
    assert_equal 0, @user.map_entries.count
  end

  test "skips books with no country_of_origin" do
    book = create(:book, country_of_origin: nil)
    @user.reading_entries.create!(book: book, status: :finished)
    assert_equal 0, @user.map_entries.count
  end
end

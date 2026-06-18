require "test_helper"
require "webmock/minitest"

class AmazonWishlistImporterTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @url  = "https://www.amazon.com/hz/wishlist/ls/EXAMPLE"
    stub_request(:get, @url).to_return(
      status: 200,
      body: amazon_wishlist_html_fixture
    )
  end

  test "parses items from HTML" do
    items = AmazonWishlistImporter.new(@url).fetch_items
    assert items.any?
    assert items.first.title.present?
  end

  test "creates books and reading entries" do
    assert_difference([ "Book.count", "ReadingEntry.count" ], 2) do
      AmazonWishlistImporter.new(@url).import_for(@user)
    end
    assert @user.reading_entries.all?(&:want_to_read?)
  end

  test "skips books user already has" do
    book = Book.find_or_create_by!(title: "The Pragmatic Programmer")
    create(:reading_entry, user: @user, book: book, status: :reading)

    AmazonWishlistImporter.new(@url).import_for(@user)
    assert_equal 2, ReadingEntry.where(user: @user).count
    assert_equal 1, ReadingEntry.where(user: @user, book: book).count
  end

  private

  def amazon_wishlist_html_fixture
    <<~HTML
      <html><body>
        <ul>
          <li data-itemid="ASIN001">
            <a id="itemName_ASIN001">The Pragmatic Programmer</a>
            <span class="a-size-base">by David Thomas</span>
            <img src="https://example.com/cover1.jpg" />
          </li>
          <li data-itemid="ASIN002">
            <a id="itemName_ASIN002">Clean Code</a>
            <span class="a-size-base">by Robert Martin</span>
            <img src="https://example.com/cover2.jpg" />
          </li>
        </ul>
      </body></html>
    HTML
  end
end

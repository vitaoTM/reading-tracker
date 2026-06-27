require "httparty"
require "nokogiri"

class AmazonWishlistImporter
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
               "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

  Item = Struct.new(:title, :author, :asin, :image_url, keyword_init: true)

  def initialize(wishlist_url)
    @url = wishlist_url
  end

  def fetch_items
    response = HTTParty.get(@url, headers: { "User-Agent" => USER_AGENT })
    raise "Amazon returned #{response.code}" unless response.success?

    doc = Nokogiri::HTML(response.body)
    items = []

    doc.css("li[data-itemid]").each do |li|
      title_node = li.at_css("a[id^='itemName_']")
      next unless title_node

      author_node = li.at_css("span.a-size-base")
      img_node    = li.at_css("img")
      author_text = author_node&.text&.strip
      next unless author_text&.match?(/\Aby\s+\S/i)

      items << Item.new(
        title:     title_node.text.strip,
        author:    author_text.sub(/^by\s+/i, "").strip,
        asin:      li["data-itemid"],
        image_url: img_node&.[]("src")
      )
    end

    items
  end

  def import_for(user)
    created = 0
    fetch_items.each do |item|
      book = Book.find_or_create_by!(title: item.title) do |b|
        b.author = item.author
      end

      next if user.reading_entries.exists?(book: book)

      user.reading_entries.create!(
        book: book,
        status: :want_to_read,
        discovery_source: "Imported from Amazon wishlist"
      )
      created += 1
    end
    created
  end
end

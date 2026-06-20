require "csv"

class AmazonCsvImporter
  def initialize(file)
    @file = file
  end

  def import_for(user)
    created = 0
    rows = CSV.parse(@file.read, headers: true)

    rows.each do |row|
      title = row["Title"]&.strip
      next if title.blank?

      book = Book.find_or_create_by!(title: title) do |b|
        b.author = row["Author(s)"]&.strip
      end

      next if user.reading_entries.exists?(book: book)

      user.reading_entries.create!(
        book: book,
        status: :want_to_read,
        discovery_source: "Imported from Amazon Wishlist CSV"
      )
      created += 1
    end

    created
  end
end

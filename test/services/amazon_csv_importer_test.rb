require "test_helper"

class AmazonCsvImporterTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "imports books from CSV" do
    file = mock_csv(<<~CSV)
      Title,Author(s),ASIN
      Sapiens,Yuval Noah Harari,B00ICN066A
      Dune,Frank Herbert,B0011UGIJY
    CSV

    assert_difference([ "Book.count", "ReadingEntry.count" ], 2) do
      AmazonCsvImporter.new(file).import_for(@user)
    end
    assert @user.reading_entries.all?(&:want_to_read?)
  end

  test "skips rows with blank titles" do
    file = mock_csv(<<~CSV)
      Title,Author(s),ASIN
      ,Unknown Author,XXX
      Dune,Frank Herbert,B0011UGIJY
    CSV

    assert_difference("Book.count", 1) do
      AmazonCsvImporter.new(file).import_for(@user)
    end
  end

  test "skips books user already has" do
    book = Book.find_or_create_by!(title: "Dune")
    create(:reading_entry, user: @user, book: book, status: :reading)

    file = mock_csv(<<~CSV)
      Title,Author(s),ASIN
      Dune,Frank Herbert,B0011UGIJY
    CSV

    assert_no_difference("ReadingEntry.count") do
      AmazonCsvImporter.new(file).import_for(@user)
    end
  end

  private

  def mock_csv(content)
    StringIO.new(content)
  end
end

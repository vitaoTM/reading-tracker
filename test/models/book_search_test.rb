require "test_helper"

class BookSearchTest < ActiveSupport::TestCase
  test "search finds by title prefix" do
    create(:book, title: "The Brothers Karamazov", author: "Dostoevshy")
    create(:book, title: "Crime and Punishment", author: "Dostoevshy")
    results = Book.search("Karama")
    assert_equal 1, results.count
    assert_equal "The Brothers Karamazov", results.first.title
  end

  test "search finds by author" do
    create(:book, title: "The Idiot", author: "Clarice Lispector")
    create(:book, title: "Other book", author: "Someone Else")
    results = Book.search("clarice")
    assert_equal 1, results.count
  end

  test "search finds via tags" do
    book = create(:book, title: "Dune")
    book.tag_names = [ "scifi", "epic" ]
    book.save!
    results = Book.search("scifi")
    assert_includes results, book
  end

  test "empty query returns all books via scope" do
    create(:book, title: "A")
    create(:book, title: "B")
    assert_equal 2, Book.count
  end
end

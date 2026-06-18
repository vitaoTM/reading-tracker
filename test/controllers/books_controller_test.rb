require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
    @book = create(:book)
  end

  test "index renders" do
    get books_url
    assert_response :success
  end

  test "show renders" do
    get book_url(@book)
    assert_response :success
  end

  test "create persists book" do
    assert_difference("Book.count", 1) do
      post books_url, params: { book: { title: "New Book", author: "Author" } }
    end
  end

  # test "should get new" do
  #   get new_book_url
  #   assert_response :success
  # end
  #
  # test "should create book" do
  #   assert_difference("Book.count") do
  #     post books_url, params: { book: { age_indicator: @book.age_indicator, author: @book.author, country_of_origin: @book.country_of_origin, description: @book.description, isbn: @book.isbn, language: @book.language, page_count: @book.page_count, published_year: @book.published_year, title: @book.title } }
  #   end
  #
  #   assert_redirected_to book_url(Book.last)
  # end
  #
  # test "should show book" do
  #   get book_url(@book)
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get edit_book_url(@book)
  #   assert_response :success
  # end
  #
  # test "should update book" do
  #   patch book_url(@book), params: { book: { age_indicator: @book.age_indicator, author: @book.author, country_of_origin: @book.country_of_origin, description: @book.description, isbn: @book.isbn, language: @book.language, page_count: @book.page_count, published_year: @book.published_year, title: @book.title } }
  #   assert_redirected_to book_url(@book)
  # end
  #
  # test "should destroy book" do
  #   assert_difference("Book.count", -1) do
  #     delete book_url(@book)
  #   end
  #
  #   assert_redirected_to books_url
  # end
end

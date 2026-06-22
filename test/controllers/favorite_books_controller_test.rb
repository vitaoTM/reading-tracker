require "test_helper"

class FavoriteBooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
  end

  test "create adds a favorite" do
    book = create(:book)
    assert_difference("FavoriteBook.count", 1) do
      post favorite_books_url, params: {
        favorite_book: { book_id: book.id, position: 1 }
      }
    end
  end

  test "destroy removes a favorite" do
    fav = create(:favorite_book, user: @user, position: 1)
    assert_difference("FavoriteBook.count", -1) do
      delete favorite_book_url(fav)
    end
  end

  test "reorder update positions" do
    a = create(:favorite_book, user: @user, book: create(:book), position: 1)
    b = create(:favorite_book, user: @user, book: create(:book), position: 2)
    c = create(:favorite_book, user: @user, book: create(:book), position: 3)

    patch reorder_favorite_books_url, params: { ordered_ids: [ c.id, a.id, b.id ] }
    assert_response :ok
    assert_equal 1, c.reload.position
    assert_equal 2, a.reload.position
    assert_equal 3, b.reload.position
  end

  test "create without position parameter auto-assigns and succeeds" do
    book = create(:book)
    assert_difference("FavoriteBook.count", 1) do
      post favorite_books_url, params: {
        favorite_book: { book_id: book.id } # No position parameter
      }
    end
    assert_redirected_to root_path # or root_path depending on fallback
    assert_equal 1, @user.favorite_books.last.position
  end
end

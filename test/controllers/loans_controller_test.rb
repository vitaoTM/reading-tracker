require "test_helper"

class LoansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in_as(@user)
  end

  test "index renders with three sections" do
    get loans_url
    assert_response :success
  end

  test "create lent loan with book" do
    book = create(:book)
    assert_difference("Loan.count", 1) do
      post loans_url, params: {
        loan: { book_id: book.id, counterparty_name: "X", direction: "lent", loaned_on: Date.current }
      }
    end
  end

  test "create borrowed loan with just title" do
    assert_difference("Loan.count", 1) do
      post loans_url, params: {
        loan: { book_title: "Random Zine", counterparty_name: "Y", direction: "borrowed", loaned_on: Date.current }
      }
    end
  end

  test "mark as returned" do
    loan = create(:loan, user: @user)
    patch loan_url(loan), params: { loan: { returned_on: Date.current } }
    assert loan.reload.returned_on.present?
  end
end

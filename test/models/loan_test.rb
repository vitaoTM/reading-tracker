require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "valid loan with book" do
    assert build(:loan).valid?
  end

  test "valid loan with just title" do
    loan = build(:loan, book: nil, book_title: "Some Old Paperback")
    assert loan.valid?
  end

  test "invalid without book or title" do
    refute build(:loan, book: nil, book_title: nil).valid?
  end

  test "direction enum" do
    assert create(:loan, direction: :borrowed).borrowed?
    assert create(:loan, direction: :lent).lent?
  end

  test "open scope excludes returned" do
    open_loan   = create(:loan, returned_on: nil)
    closed_loan = create(:loan, returned_on: Date.current)
    assert_includes Loan.open, open_loan
    refute_includes Loan.open, closed_loan
  end

  test "display_title falls back to book_title" do
    book = create(:book, title: "Real Book")
    assert_equal "Real Book",    create(:loan, book: book).display_title
    assert_equal "Manual Title", create(:loan, book: nil, book_title: "Manual Title").display_title
  end
end

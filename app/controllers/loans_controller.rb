class LoansController < ApplicationController
  def index
    @lent     = Current.user.loans.lent.open.includes(:book)
    @borrowed = Current.user.loans.borrowed.open.includes(:book)
    @history  = Current.user.loans.closed.order(returned_on: :desc).includes(:book)
  end

  def new
    @loan = Current.user.loans.new
  end

  def create
    @loan = Current.user.loans.new(loan_params)
    if @loan.save
      redirect_to loans_path, notice: "Loan recorded"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @loan = Current.user.loans.find(params[:id])
    @loan.update!(loan_params)
    redirect_to loans_path
  end

  def destroy
    Current.user.loans.find(params[:id]).destroy
    redirect_to loans_path
  end

  private

  def loan_params
    params.require(:loan).permit(
      :book_id, :book_title, :counterparty_name,
      :direction, :loaned_on, :returned_on, :notes
    )
  end
end

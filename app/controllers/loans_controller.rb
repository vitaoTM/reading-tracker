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
      respond_to do |format|
        format.html { redirect_to loans_path, notice: "Loan recorded" }
        format.turbo_stream do
          @lent_count = Current.user.loans.lent.open.count
          @borrowed_count = Current.user.loans.borrowed.open.count
          @was_empty = if @loan.lent?
              @lent_count == 1
          else
              @borrowed_count == 1
          end
          flash.now[:notice] = "Loan recorded successfully!"
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    @loan = Current.user.loans.find(params[:id])
    history_was_empty = Current.user.loans.closed.empty?
    @loan.update!(loan_params)

    respond_to do |format|
      format.html { redirect_to loans_path }
      format.turbo_stream do
        @history_was_empty = history_was_empty
        @lent_count        = Current.user.loans.lent.open.count
        @borrowed_count    = Current.user.loans.borrowed.open.count
        flash.now[:notice] = "Loan returned successfully!"
      end
    end
  end

  def destroy
   @loan =  Current.user.loans.find(params[:id])
   @loan.destroy

    respond_to do |format|
      format.html { redirect_to loans_path }
      format.turbo_stream do
        @lent_count = Current.user.loans.lent.open.count
        @borrowed_count = Current.user.loans.borrowed.open.count
        @history_count = Current.user.loans.closed.count
        flash.now[:notice] = "Loan deleted successfully!"
      end
    end
  end

  private

  def loan_params
    params.require(:loan).permit(
      :book_id, :book_title, :counterparty_name,
      :direction, :loaned_on, :returned_on, :notes
    )
  end
end

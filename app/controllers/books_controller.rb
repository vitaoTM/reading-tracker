class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    @books = params[:q].present? ? Book.search(params[:q]) : Book.order(:title)
  end

  # GET /books/1 or /books/1.json
  def show
    @reading_entry = Current.user&.reading_entries&.find_by(book: @book)
    @user_rating = Current.user&.ratings&.find_by(book: @book) || Current.user&.ratings&.build(book: @book)
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @book.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "Book was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @book.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    @book.destroy!

    respond_to do |format|
      format.html { redirect_to books_path, notice: "Book was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def top_recommended
    @books = Book.where("recommendation_count > 0")
                 .order(recommendation_count: :desc, cached_average_rating: :desc)
                 .limit(50)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.expect(book: [ :title, :author, :isbn, :description, :published_year, :country_of_origin, :language, :page_count, :age_indicator, :tag_list ])
    end
end

require 'ostruct'

class BooksController < ApplicationController
  before_action :set_global_query, only: [:index, :show_google]

  def index
    params[:source] ||= 'seeded_books'
    params[:page] = params[:page].to_i > 0 ? params[:page].to_i : 1
    @per_page = 10
  
    if params[:source] == 'google_books'
      @books, @has_more_pages = fetch_books_from_google_books(@query, @per_page, params[:page])
    else
      @books = Book.all.order(:title).page(params[:page]).per(@per_page)
      @has_more_pages = @books.current_page < @books.total_pages
    end  
  
    # Search query filtering
    if params[:query].present? && @query.length > 2
      @query = params[:query]
      if params[:source] == 'google_books'
        @books.select! do |book|
          book[:title].to_s.downcase.include?(params[:query].downcase) || 
          book[:author].to_s.downcase.include?(params[:query].downcase)
        end
      else
        @books = @books.by_search_string(params[:query])
      end
      @query_filt = params[:query]
    end
  
    # Rating filtering
    if params[:rating].present?
      if params[:source] == 'google_books'
        @books.select! { |book| book.respond_to?(:average_rating) && book.average_rating.to_f >= params[:rating].to_f }
      else
        @books = @books.with_average_rating(params[:rating].to_f)
      end
      @rating_filt = params[:rating]
    end
  
    # Genre filtering
    if params[:genre].present?
      if params[:source] == 'google_books'
        @books.select! { |book| book.genre.to_s.downcase.include?(params[:genre].downcase) }
      else
        @books = Book.where(genre: params[:genre])
      end
      @genre_filt = params[:genre]
    end
  
    # Apply sorting if sort param is provided
    if params[:sort].present?
      if params[:source] == 'google_books'
        # Manually sort Google Books based on title or rating
        @books.sort_by! { |book| params[:sort].include?('rating') ? -book.average_rating.to_f : book.title }
      else
        @books = @books.unscope(:order).order(params[:sort])
      end
      @sort_filt = params[:sort]
    end
  
    # Sort options
    @sorts = [
      ["Title - A to Z", "title ASC"],
      ["Title - Z to A", "title DESC"],
      ["Rating - Highest to Lowest", "rating DESC"],
      ["Rating - Lowest to Highest", "rating ASC"],
      ["Author - A to Z", "author ASC"],
      ["Author - Z to A", "author DESC"],
      ["Release Date - Newest to Oldest", "publish_date DESC"],
      ["Release Date - Oldest to Newest", "publish_date ASC"]
    ]
  end
  
  def show
    @book = Book.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to books_path, alert: "Book not found."
  end

  def show_google
    google_id = params[:id]
    
    url = "https://www.googleapis.com/books/v1/volumes/#{google_id}"
    response = HTTParty.get(url)
    
    if response.success?
      book_data = response.parsed_response['volumeInfo']
      
      @book = OpenStruct.new(
        id: google_id,
        title: book_data['title'],
        author: book_data['authors']&.join(', ') || 'Unknown Author',
        description: book_data['description'] || 'No description available.',
        genre: book_data['categories']&.join(', ') || 'Unknown',
        publisher: book_data['publisher'] || 'Unknown',
        publish_date: book_data['publishedDate'] || 'Unknown',
        pages: book_data['pageCount'] || 'Unknown',
        language_written: book_data['language'] || 'Unknown',
        isbn_13: book_data['industryIdentifiers']&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier') || 'Unknown',
        img_url: book_data['imageLinks']&.dig('thumbnail') || nil
      )
    else
      redirect_to books_path, alert: 'Google book not found'
    end
  rescue StandardError => e
    flash[:alert] = 'Something went wrong while fetching Google Books data'
    redirect_to books_path
  end
  
  
  def create
    @book = Book.new(create_params)
    if @book.save
      flash[:notice] = "Book #{@book.title} created successfully"
      redirect_to books_path
    else
      flash[:alert] = "Book could not be created" 
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @book = Book.new
  end

  def add_google_book
    book_data = params[:book]
  
    existing_book = Book.find_by(isbn_13: book_data[:isbn_13])
    
    if existing_book
      redirect_to book_path(existing_book), notice: "This book is already in your library."
      return
    end
  
    # new book with the data from Google Books
    @google_book = Book.new(
      title: book_data[:title],
      author: book_data[:author],
      genre: book_data[:genre],
      description: book_data[:description],
      publisher: book_data[:publisher],
      publish_date: book_data[:publish_date],
      pages: book_data[:pages],
      language_written: book_data[:language_written],
      isbn_13: book_data[:isbn_13],
      img_url: book_data[:img_url]
    )

    print ("google book data: #{@book_data}")
  
    # Save the book if it's valid, and redirect to its show page
    if @google_book.save
      redirect_to book_path(@google_book), notice: "Google Book '#{@google_book.title}' was successfully added."
    else
      redirect_to books_path, alert: "Error adding Google Book."
    end
  end

  def destroy
    @book = Book.find(params[:id])
    # @book.images.each {|img| img.purge }
    @book.destroy
    redirect_to books_path, notice: 'Book deleted successfully'
  end
    
  private
  
  def create_params
    params.require(:book).permit(:title, :author, :genre, :pages, :description, :publisher, :publish_date, :isbn_13, :language_written, :image)
  end

  def set_global_query
    @query = params[:query] || ''
  end

  # Google Books API response parser helper function
  def fetch_books_from_google_books(query = 'default', max_results = 10, page = 1)
    query = 'default' if query.blank?
    start_index = (page - 1) * max_results
    url = "https://www.googleapis.com/books/v1/volumes?q=#{query}&startIndex=#{start_index}&maxResults=#{max_results}"
    response = HTTParty.get(url)
  
    books_data = response.parsed_response['items'] || []
    total_items = response.parsed_response['totalItems'] || 0
    has_more_pages = start_index + books_data.size < total_items
  
    books = books_data.map.with_index do |item, index|
      OpenStruct.new(
        id: item['id'],
        title: item['volumeInfo']['title'],
        author: item['volumeInfo']['authors']&.join(', ') || 'Unknown Author',
        description: item['volumeInfo']['description'] || 'No description available.',
        genre: item['volumeInfo']['categories']&.join(', ') || 'Unknown',
        publisher: item['volumeInfo']['publisher'] || 'Unknown',
        publish_date: item['volumeInfo']['publishedDate'] || 'Unknown',
        pages: item['volumeInfo']['pageCount'] || 'Unknown',
        language_written: item['volumeInfo']['language'] || 'Unknown',
        isbn_13: item['volumeInfo']['industryIdentifiers']&.find { |id| id['type'] == 'ISBN_13' }&.dig('identifier') || 'Unknown',
        img_url: item['volumeInfo']['imageLinks']&.dig('thumbnail') || nil
      )
    end
  
    [books, has_more_pages]
  end  
end
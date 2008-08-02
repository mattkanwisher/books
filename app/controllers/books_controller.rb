class BooksController < ApplicationController
  active_scaffold :book


  # GET /books/1
  # GET /books/1.xml
  def view
    @book = Book.find(params[:id])
    @comment = Comment.new
    @comments = Comment.paginate_by_book_id @book.id, :page => 1
    puts "@comments.previous_page#{@comments.previous_page}"
    puts "@comments.next_page#{@comments.next_page}"
    
    @next_page = @comments.next_page.to_i
    @prev_page = @comments.previous_page.to_i

    respond_to do |format|
      format.html { render :layout => false} # view.html.erb
      format.xml  { render :xml => @book }
    end
  end

end

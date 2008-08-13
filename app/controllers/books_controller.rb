class BooksController < ApplicationController


  def show
    @book = Book.find(params[:id])
    @book.views = @book.views + 1
    @book.save #Not efficent !
    
    @comment = Comment.new
    @comments = Comment.paginate_by_book_id @book.id, :page => 1, :order => "created_at DESC"
    puts "@comments.previous_page#{@comments.previous_page}"
    puts "@comments.next_page#{@comments.next_page}"
    
    @next_page = @comments.next_page.to_i
    @prev_page = @comments.previous_page.to_i

    respond_to do |format|
      format.html { render :action => "view2.html.erb", :layout => false} # view.html.erb
      format.xml  { render :xml => @book }
    end
  end

  

end

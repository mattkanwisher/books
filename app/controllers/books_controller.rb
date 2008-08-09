class BooksController < ApplicationController


  # GET /books/1
  # GET /books/1.xml
  def show
    @book = Book.find_by_url_key(params[:id])
    @book.views = @book.views + 1
    @book.save #Not efficent !
    
    @comment = Comment.new
    @comments = Comment.paginate_by_book_id @book.id, :page => 1
    puts "@comments.previous_page#{@comments.previous_page}"
    puts "@comments.next_page#{@comments.next_page}"
    
    @next_page = @comments.next_page.to_i
    @prev_page = @comments.previous_page.to_i

    respond_to do |format|
      format.html { render :action => "view2.html.erb", :layout => false} # view.html.erb
      format.xml  { render :xml => @book }
    end
  end


  
  def subscribe
    email = params["sub_email"]
    if(email.include?("@"))
      not_email = Notification.new()
      not_email.email = email
      not_email.book_id = params["book_id"].to_i
      not_email.save
      respond_to do |format|
        format.html { render :action => "success_subscribe.html.erb", :layout => false}
      end
    else
      respond_to do |format|
        format.html { render :action => "failure_subscribe.html.erb", :layout => false}
      end
    end
  end
  

end

class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])

    if(params["commenting_subscribe_checkbox"] == "on")
      noti_found =  Notification.find(:first, :conditions => { :email => @comment.email, :book_id  => @comment.book_id  } )
      if( noti_found == nil  )
        not_email = Notification.new()
        not_email.email = @comment.email
        not_email.book_id = @comment.book_id
        not_email.save
      else
        puts "already saved notifications"
      end
    end

    respond_to do |format|
      if @comment.save
        @comments = Comment.paginate_by_book_id @comment.book_id, :page => 1
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(@comment) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
        format.js{ render :action=>'create' }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        format.js{ render :action=>'create_error' }
      end
    end
  end

  def ViewBookComments
    @comments = Comment.paginate_by_book_id params[:id], :page => params[:p]
    @next_page = @comments.next_page.to_s
    @prev_page = @comments.next_page.to_s
    if( params["spoilers"] != nil)
      @allow_spoilers = true
    end
    respond_to do |format|
      format.js{ render :action=>'bookcommentspagination' }
    end
  end

  def RenderComment
    @comment = Comment.find(params[:id])
    render :partial => "comment"
   end 
  
  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def recommend 
    begin
      @comment = Comment.find(params[:id])
      @comment.recommendcount = @comment.recommendcount + 1
      @comment.save
      render :text => @comment.recommendcount
    rescue 
       render :text =>"failure" 
    end
  end 
  
  def spoiler
    begin
      @comment = Comment.find(params[:id])
      @comment.spoilercount = @comment.spoilercount + 1
      @comment.save
      render :text => @comment.spoilercount 
    rescue 
       render :text =>"failure" 
    end
  end 

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end

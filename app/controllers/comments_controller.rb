class CommentsController < ApplicationController

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
    
#    Notification.find(:all, :conditions => {:book_id => @comment.book_id}).each do |notifiy|
#      User.TempUserEmail(notifiy.email)
#      Notifier.deliver_signup_thanks(notifiy.email, @comment, @comment.book)
#    end 
    
    respond_to do |format|
      if @comment.save
        @comments = Comment.paginate_by_book_id @comment.book_id, :page => 1,  :order => "created_at DESC"
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
    @comments = Comment.paginate_by_book_id params[:id], :page => params[:p],  :order => "created_at DESC"
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
      @just_marked_as_spoiler = true
#      render :text => @comment.spoilercount 
      render :partial => "spoiler"
    rescue 
       render :text =>"failure" 
    end
  end 

  def unspoil
    begin
      @comment = Comment.find(params[:id])
      @comment.spoilercount = @comment.spoilercount - 1
      @comment.save
      @just_marked_as_spoiler = false
#      render :text => @comment.spoilercount 
      render :partial => "spoiler"
    rescue 
       render :text =>"failure" 
    end
  end 

  
  def testmail
    delete_if = lambda {|email| MyMailer.deleteif(email) }
    MailFetcher.fetch(:delete_if => delete_if, :mailer_methods => [:receive])
    render :text => "Love", :layout => "false"
  end
  
  
=begin  
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
=end
  
  def subscribe
    email = params["sub_email"]
    book_id =  params["book_id"].to_i
    if(email.include?("@"))
      noti_found =  Notification.find(:first, :conditions => { :email => email, :book_id  => book_id  } )
      if( noti_found == nil  ) #no dupes
        not_email = Notification.new()
        not_email.email = email
        not_email.book_id = book_id
        not_email.save
      end
      
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

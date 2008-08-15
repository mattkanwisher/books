class CommentsController < ApplicationController

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])

    u = nil
    if( self.current_user == nil)
      u = User.find_by_email(@comment.email)
      u = User.Createtempuser(@comment.email) unless u
    elsif( self.current_user.email == nil)
      u = self.current_user
      u.email = @comment.email
      u.save
    else
      u = self.current_user
    end
    set_auth

#    Notification.find(:all, :conditions => {:book_id => @comment.book_id}).each do |notifiy|
#      User.TempUserEmail(notifiy.email)
#      Notifier.deliver_signup_thanks(notifiy.email, @comment, @comment.book)
#    end 
    puts "current_user.id#{current_user.id}-"
    @comment.user_id = current_user.id unless current_user == nil
    
    respond_to do |format|
      if @comment.save
        puts "Comments saved !"
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
            
      
        @comments = Comment.paginate_by_book_id @comment.book_id, :page => 1,  :order => "created_at DESC"
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(@comment) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
        format.js{ render :action=>'create' }
      else
        puts "Comments failed to save! #{@comment.errors.inspect}"
        @book = Book.find(@comment.book_id)
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
    render :update do |page|
      page.replace 'comment_spoiler_' + @comment.id.to_s, :partial => 'comment'		    
		end
   end 
  
  # PUT /comments/1
  # PUT /comments/1.xml
  def update
=begin    @comment = Comment.find(params[:id])

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
=end
    create
  end

  def recommend 
    begin
      @comment = Comment.find(params[:id])
      r = nil
      if(self.current_user != nil)
        r = Recommend.find(:first, :conditions => {:user_id => self.current_user.id, :book_id => @comment.book_id, :comment_id => @comment.id})
      else
       self.current_user = User.Createtempuser(nil)
       set_auth
      end
      if(!r)
        
        @comment.recommendcount = @comment.recommendcount + 1
        @comment.save
        
        rec = Recommend.new()
        rec.book_id = @comment.book_id
        rec.comment_id = @comment.id
        rec.user_id = self.current_user.id 
        rec.save
      end
      render :text => @comment.recommendcount
    rescue Exception => e
       puts e
       render :text =>"failure" 
    end
  end 
  
  def spoiler
    begin
      puts "current_user.id #{self.current_user.inspect}"
      @comment = Comment.find(params[:id])
      s = nil
      if(self.current_user != nil)
        s = Spoiler.find(:first, :conditions => {:user_id => self.current_user.id, :book_id => @comment.book_id, :comment_id => @comment.id})
      else
       self.current_user = User.Createtempuser(nil)
       set_auth
      end
      if(!s)      
        if( @comment.user_id == self.current_user.id) 
          @comment.spoilercount = @comment.spoilercount + 3
        else
          @comment.spoilercount = @comment.spoilercount + 1
        end
        @comment.save
        
        sop = Spoiler.new()
        sop.book_id = @comment.book_id
        sop.comment_id = @comment.id
        sop.user_id = self.current_user.id 
        sop.save
      end

      @just_marked_as_spoiler = true
 #     render :text => @comment.spoilercount 
      render :update do |page|        
       page.replace 'comment_'  + @comment.id.to_s, :partial => 'spoiler'		    
    	end
    rescue Exception => e
       puts e
       render :text =>"failure" 
    end
  end 

  def unspoil
    begin
      @comment = Comment.find(params[:id])
      s = nil
      if(current_user != nil)
        s = Spoiler.find(:first, :conditions => {:user_id => self.current_user.id, :book_id => @comment.book_id, :comment_id => @comment.id})
      else
       self.current_user = User.Createtempuser(nil)
       set_auth
      end
      if(s)
        if( @comment.user_id == self.current_user.id) 
          @comment.spoilercount = @comment.spoilercount - 3
        else
          @comment.spoilercount = @comment.spoilercount - 1
        end
        @comment.save
        Spoiler.delete(s.id)
      end
      @just_marked_as_spoiler = false
#      render :text => @comment.spoilercount 
      puts "done"

      render :update do |page|        
       page.replace 'comment_spoiler_'  + @comment.id.to_s, :partial => 'comment'		    
    	end
    rescue Exception => e
       puts e
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
    if(email.include?("@") && email.include?("."))
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
        @book = Book.find(book_id)
        format.html { render :action => "failure_subscribe.html.erb", :layout => false}
      end
    end
  end
  
  private
  def set_auth
    self.current_user.remember_me
    puts "current_user.remember_token #{current_user.remember_token}"
    cookies[:auth_token] = { :value => current_user.remember_token , :expires => current_user.remember_token_expires_at }
  end
end

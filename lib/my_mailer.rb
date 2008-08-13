class MyMailer
  def self.receive(mail)
    puts "REC"
#    puts mail.methods
    commentstr = ""

    mail.body.each_line do |line|
      puts "l-#{line}"
      match = line.match("Sent from my iPhone")
      break unless match == nil

      match = line.match("Reply ABOVE THIS LINE to post a comment to the project")
      break unless match == nil

      match = line.match("On(.*)wrote")
      break unless match == nil

      match = line.match("----- Original Message ----")
      break unless match == nil
      
      
      commentstr = commentstr + line
    end
    puts "commentstr-----#{commentstr}"
    
    match = mail.body.match("bookreadingroom.com\/books\/(.)\-")
    if( match != nil)
      if (match[1] != nil)
        puts match[1]
        
        c = Comment.find_by_email(mail.sender)
        puts "c#{c.inspect}"
        if( c != nil)
          name = c.name
        else
          name = mail.sender.split("@")[0]
        end
        
        book = Book.find(match[1])
        comment = book.comments.new()
        comment.email =  mail.from.to_s
        comment.name =  name
        comment.body = commentstr
        comment.save
        return
      end
    end    
  end
  
  def self.sendallnotifications()
    #    Notification.find(:all, :conditions => {:book_id => @comment.book_id}).each do |notifiy|
    #      User.TempUserEmail(notifiy.email)
    #      Notifier.deliver_signup_thanks(notifiy.email, @comment, @comment.book)
    #    end 
    
    Book.all.each do |book|
      puts "book#{book.id}"
      last_comment_id = 0
      if book.last_sent_notification != nil
        last_sent_notification = book.last_sent_notification
      else
        last_sent_notification = 0
      end 
      Comment.find(:all, :conditions => "book_id = #{book.id} AND id > #{last_sent_notification}").each do |comment|
          puts "comment"
          Notification.find(:all, :conditions => {:book_id => book.id}).each do |notify|
#                User.TempUserEmail(notifiy.email)
                puts "Sending email to #{notify.email}, on #{book.title}"
                Notifier.deliver_signup_thanks(notify.email, comment, book)
          end
          last_comment_id = comment.id
      end
      book.last_sent_notification = last_comment_id
      book.save
    end
  end
  
  def self.deleteif(mail)
#    puts ENV["RAILS_ENV"]
    return true
  end
end

class Notifier < ActionMailer::Base
  def signup_thanks( user, comment, book )
    # Email header info MUST be added here
    recipients user
    from  "serveradmin@bookreadingroom.com"
    subject "New comment on book -"+ book.title

    puts "comment#{comment.inspect}"
    # Email body substitutions go here
    body :user=> user, :book=>book, :comment=>comment

  end
  
  
end

class Notifier < ActionMailer::Base
  def signup_thanks( user, comments, book )
    # Email header info MUST be added here
    recipients user
    from  "serveradmin@bookreadingroom.com"
    subject "New comment(s) on book -"+ book.title

    # Email body substitutions go here
    body :user=> user, :book=>book, :comments=>comments

  end
  
  
end

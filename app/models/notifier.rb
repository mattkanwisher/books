class Notifier < ActionMailer::Base
  def signup_thanks( user, comment, book )
    # Email header info MUST be added here
    recipients user
    from  "asdf@adsf.com"
    subject "Thank you for registering with our website"

    # Email body substitutions go here
    body :user=> user
    body :comment=>comment
    body :body=>book
  end
  
  
end

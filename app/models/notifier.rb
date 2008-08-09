class Notifier < ActionMailer::Base
  def signup_thanks( user )
    # Email header info MUST be added here
    recipients user
    from  "asdf@adsf.com"
    subject "Thank you for registering with our website"

    # Email body substitutions go here
    body :user=> user
  end
  
  
end

class TestController < ApplicationController
  def viewmail
     render :template => "notifier/signup_thanks.html.erb", :layout => false
  end
end

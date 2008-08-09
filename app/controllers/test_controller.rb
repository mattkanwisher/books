class TestController < ApplicationController
  def viewmail
     @comment = Comment.find(params[:id])
     render :template => "notifier/signup_thanks.html.erb", :layout => false
  end
end

class TestController < ApplicationController
  def viewmail
     @comment = Comment.find(params[:id])
     @book = @comment.book
     render :template => "notifier/signup_thanks.html.erb", :layout => false
  end
end

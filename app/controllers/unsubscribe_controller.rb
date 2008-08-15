class UnsubscribeController < ApplicationController
    def index
      @user = User.find(params[:id])
      @book = Book.find(params[:id2])
      noti  = Notification.find(:first, :conditions => { :email => @user.email, :book_id => @book.id } )
      Notification.delete(noti.id) unless noti == nil
    end
    def all
      @user = User.find(params[:id])
      Notification.find(:all, :conditions => { :email => @user.email } ).each do |noti|
        Notification.delete(noti.id)
      end
    end
end

class Comment < ActiveRecord::Base
  belongs_to :book,
                 :class_name => "Book",
                 :foreign_key => "book_id"
   validates_presence_of     :name, :body

   def validate
     if !email.include?("@") || !email.include?(".")
         errors.add(:email, "Invalid Email")
     end
   end

   cattr_reader :per_page
   @@per_page = 20

end

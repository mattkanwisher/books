class Comment < ActiveRecord::Base
    belongs_to :book,
                 :class_name => "Book",
                 :foreign_key => "book_id"

   cattr_reader :per_page
   @@per_page = 10

end

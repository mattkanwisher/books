class Book < ActiveRecord::Base
  has_many :comments
  has_url_key :title
end

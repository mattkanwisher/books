require 'iconv'
# Use this in your ActiveRecord models with <tt>has_url_key :attr_name</tt>.
# You must add a column for storing the URL key. This defaults to +url_key+.
module UrlKey
  class << self
    # Escape _str_ by transliterating to ASCII with Iconv, downcasing, 
    # then removing illegal characters and replacing them with '-'
    def escape(str)
      s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
      s = s.downcase
      s = s.gsub(/\W+/, ' ')
      s = s.strip
      s = s.gsub(/\ +/, '-') # set single or multiple spaces to a single dash
      
      return s
    end    
     
    # Given _str_, the _url_key_field_ and the ActiveRecord class _klass_,
    # create a unique URL key.
    def create_url_key(str, url_key_field, klass)
      str = UrlKey.escape(str)
      key = str
      counter = 1
      until klass.find(:all, :conditions => ["#{url_key_field} = ?", key]).empty?
        key = "#{str}-#{counter}"
        counter += 1
      end
       
      key
    end 
  end

  # Call this in your model with the name of the attribute to base the
  # URL key on, and optionally the name of the URL key field.
  # (defaults to _url_key_)
  def has_url_key(attr_name, url_key_field = nil)
    url_key_field ||= 'url_key'
    before_validation_on_create { |record|
      key = UrlKey.create_url_key(record.send(attr_name).to_s, 
                                  url_key_field,
                                  record.class)
                  
      record.send("#{url_key_field}=", key) 
    }
  end
end

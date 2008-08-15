require 'amazon/aws/search'
require 'isbn/tools'
  
# Avoid having to fully qualify our methods.
#
include Amazon::AWS
include Amazon::AWS::Search


class SearchController < ApplicationController
  def index
#      begin
        puts "params #{params.inspect}"
        book = find_createbook( params["searchfield"])
        if( book )
          if( book.url_key == nil)
            book.url_key = UrlKey.create_url_key(book.title, "url_key", Book)
            book.save
          end
          #redirect_to :controller => "books", :action => "show", :id => book.id, :booktitle => book.url_key
          redirect_to "/books/" + book.id.to_s + "-" + book.url_key
          return
        end
        puts "book#{book}"
#      rescue
#        "puts error"
#      end
      render :action => "no_books_found"
  end

  def find_createbook(bookname)
    is = nil
    il = nil
    asin = nil
    req = Request.new
    req.locale = 'us'
    if !ISBN_Tools.is_valid?(bookname)
        is = ItemSearch.new( 'Books', { 'Title' => bookname } )
        # I want to receive just a small amount of data for the items found.
        rg = ResponseGroup.new( 'Small' )
        begin
            if( il == nil)
              resp = req.search( is, rg )
            end
        rescue Exception => e
          puts "Probaly book isn't found #{e}"
          return
        end
        asin = resp.item_search_response[0].items[0].item[0].asin.to_s
    else
        il = ItemLookup.new( 'ISBN', { 'ItemId' => bookname , 'IdType' => 'ISBN', :SearchIndex =>'Books'} )
    end
    
    rg = nil
    resp = nil
  
    if(il == nil)
      il = ItemLookup.new( 'ASIN', { 'ItemId' => asin,
                                      'MerchantId' => 'Amazon' } )
    end
    req = Request.new
    req.locale = 'us'
    rg = ResponseGroup.new( 'Medium' )
    resp = req.search( il, rg )

    items = resp.item_lookup_response.items.item
    book =  resp.item_lookup_response.items[0]
    author = book.item[0].item_attributes[0].author[0].to_s
    title = items[0].item_attributes.title.to_s
    page_url = items[0].detail_page_url.to_s


    #debugger
begin
    image_url = book.item[0].image_sets[0].image_set.large_image.url[0].to_s
rescue
    begin
    image_url = book.item[0].image_sets[0].image_set[0].large_image.url[0].to_s
    rescue
      image_url = ""
      puts "=============== FAILED TO FIND AMAZON IMAGE"
      puts resp
      puts "==============="  
#      debugger
    end
end
    book = Book.find_by_title(title) || Book.new
    book.asin = asin
    book.title = slightly_nicer_title(title)
    book.image_url = image_url
    book.author = author
    book.amz_purchase_url = page_url
    book.save
    return book
  end

  def slightly_nicer_title(title)
    idx = title.index("(")
    if(idx != nil)
      title.slice!(idx, title.length)
    end
    title
  end
end

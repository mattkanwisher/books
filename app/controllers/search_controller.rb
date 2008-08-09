require 'amazon/aws/search'

# Avoid having to fully qualify our methods.
#
include Amazon::AWS
include Amazon::AWS::Search


class SearchController < ApplicationController
  def index
      begin
        puts "params #{params.inspect}"
        book = find_createbook( params["searchfield"])
        if( book )
          redirect_to :controller => "books", :action => "show", :id => book.url_key
          return
        end
        puts "book#{book}"
      rescue
        "puts error"
      end
      render :action => "no_books_found"
  end

  def find_createbook(bookname)

    is = ItemSearch.new( 'Books', { 'Title' => bookname } )

    # I want to receive just a small amount of data for the items found.
    #
    rg = ResponseGroup.new( 'Small' )

    req = Request.new

    # Make sure I'm talking to amazon.co.uk.
    #
    req.locale = 'us'

    # Actually talk to AWS.
    #
    resp = req.search( is, rg )

    # Drill down to the meat: the array of items returned.
    #
    items = resp.item_search_response.items.item

    # The following alternative shorthand would also have worked:
    #
    # items = resp.item_search_response.items.item

    # Available properties for first item:
    #
    puts items[0].inspect
    title = items[0].item_attributes.title.to_s
    puts "title- #{title}"
    asin = resp.item_search_response[0].items[0].item[0].asin.to_s
    puts "asin- #{asin}"

    page_url = items[0].detail_page_url.to_s
  

    il = ItemLookup.new( 'ASIN', { 'ItemId' => asin,
                                    'MerchantId' => 'Amazon' } )

    #req = Request.new
    rg = ResponseGroup.new( 'Medium' )
    resp = req.search( il, rg )
    book =  resp.item_lookup_response.items[0]
    author = book.item[0].item_attributes[0].author[0].to_s



    image_url = book.item[0].image_sets[0].image_set.large_image.url[0].to_s
    
    book = Book.find_by_title(title) || Book.new
    book.asin = asin
    book.title = slightly_nicer_title(title)
    book.image_url = image_url
    book.author = author
    book.amz_purchase_url = page_url
    book.save
    return book
  end

  def slightly_nicer_title(tile)
    idx = title.index("(")
    if(idx != nil)
      title.slice!(idx, title.length)
    end
    title
  end
end

require 'amazon/aws/search'

# Avoid having to fully qualify our methods.
#
include Amazon::AWS
include Amazon::AWS::Search

is = ItemSearch.new( 'Books', { 'Title' => 'catcher in the rye' } )

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
title = items[0].item_attributes.title
puts "title- #{title}"
asin = resp.item_search_response[0].items[0].item[0].asin
puts "asin- #{asin}"


il = ItemLookup.new( 'ASIN', { 'ItemId' => asin,
                                'MerchantId' => 'Amazon' } )

#req = Request.new
rg = ResponseGroup.new( 'Medium' )
resp = req.search( il, rg )
book =  resp.item_lookup_response.items[0]



@image_url = book.item[0].image_sets[0].image_set.large_image.url[0].to_s
puts  book.item[0].item_attributes[0].author[0].to_s
#items.each do |item|
#  puts item
#end

=begin
items.each do |item|
  attribs = item.item_attributes[0]
  puts attribs.label
  if attribs.list_price
    puts attribs.title, attribs.list_price[0].formatted_price, ''
  end
end
=end

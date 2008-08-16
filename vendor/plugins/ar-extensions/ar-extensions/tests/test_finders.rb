require File.expand_path( File.join( File.dirname( __FILE__ ), 'test_helper' ) )

class FindersTest < Test::Unit::TestCase
  include ActiveRecord::ConnectionAdapters
  self.fixture_path = File.join( File.dirname( __FILE__ ), 'fixtures/unit/active_record_base_finders' )
  self.fixtures 'developers', 'books'

  def setup
    @connection = ActiveRecord::Base.connection
  end
  
  def teardown
    Developer.delete_all
    Book.delete_all
  end

  def setup_time
    Book.destroy_all
    3.times do |i|
      book = Book.create! :title=>"a#{i}", :publisher=>"b#{i}", :author_name=>"c#{i}"
      assert book.update_attribute(:created_at, Time.local(2007, 01, 01, 21, 38, i))
    end
    book = Book.create! :title=>"nope", :publisher=>"not i", :author_name=>"not me"
    assert book.update_attribute(:created_at, Time.local(2007, 01, 01, 20, 38, 04))    
  end

  def test_find_by_array1
    developers = Developer.find( :all, :conditions=>[ 'ID IN(?)', [1,2] ] )
    assert_equal( 2, developers.size )
  end
  
  def test_find_by_array_with_reserved_words1
    Group.destroy_all
    Group.create!(:order => "a")
    Group.create!(:order => "b")
    Group.create!(:order => "c")
    groups = Group.find(:all, :conditions => {:order => ["a", "b", "c"]})
    assert_equal 3, groups.size
  end
  
  def test_find_by_array2
    developers = Developer.find_all_by_id( [ 1, 2 ] )
    assert_equal( 2, developers.size )
  end
  
  def test_find_by_array_with_reserved_words2
    Group.destroy_all
    Group.create!(:order => "a")
    Group.create!(:order => "b")
    Group.create!(:order => "c")
    groups = Group.find_all_by_order(["a", "b", "c"])
    assert_equal 3, groups.size
  end
  
  def test_find_by_array3
    developers = Developer.find_all_by_name( [ 'Zach Dennis', 'John Doe', "The Second Topic's of the day" ] )
    assert_equal( 2, developers.size )
  end
      
  def test_find_by_array4
    developers = Developer.find( :all, :conditions=>{ :id=>[1,2] } )
    assert_equal( 2, developers.size )
  end
  
  def test_find_by_range
    # there is no difference between ( x..z ) and ( x...z )
    developers = Developer.find( :all, :conditions=>{ :id=>(1..2) } )
    assert_equal( 2, developers.size )
    developers = Developer.find( :all, :conditions=>{ :id=>(1...2) } )
    assert_equal( 2, developers.size )
  end

  def test_find_by_range_with_reserved_words
    Group.destroy_all
    Group.create!(:order => "a")
    Group.create!(:order => "b")
    Group.create!(:order => "c")
    groups = Group.find(:all, :conditions => {:order => ("a".."c")})
    assert_equal 3, groups.size
    groups = Group.find(:all, :conditions => {:order => ("b".."c")})
    assert_equal 2, groups.size
    groups = Group.find(:all, :conditions => {:order => ("d".."z")})
    assert_equal 0, groups.size
  end
    
  def test_find_with_like
    developers = Developer.find( :all, :conditions=>{ :name_like=>'ach' } )
    assert_equal( 1, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :name_like=>'Zach' } )
    assert_equal( 1, developers.size )
   
    developers = Developer.find( :all, :conditions=>{ :name_like=>['ach', 'oe'] } )
    assert_equal( 2, developers.size )
  end

  def test_find_with_like_with_reserved_words
    Group.destroy_all
    g1 = Group.create!(:order => "a")
    g2 = Group.create!(:order => "b")
    groups = Group.find(:all, :conditions => {:order_like => 'a'})
    assert_equal g1, groups.first

    groups = Group.find(:all, :conditions => {:order_like => ['a', 'b']})
    assert_equal [g1, g2], groups
  end
  
  def test_find_with_contains
    developers = Developer.find( :all, :conditions=>{ :name_contains=>'ach' } )
    assert_equal( 1, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :name_contains=>'Zach' } )
    assert_equal( 1, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :name_contains=>['ach', 'oe'] } )
    assert_equal( 2, developers.size )
  end
  
  def test_find_with_contains_with_reserved_words
    Group.destroy_all
    g1 = Group.create!(:order => "a")
    g2 = Group.create!(:order => "b")
    groups = Group.find(:all, :conditions => {:order_contains => 'a'})
    assert_equal g1, groups.first

    groups = Group.find(:all, :conditions => {:order_contains => ['a', 'b']})
    assert_equal [g1, g2], groups
  end
  
  
  def test_find_with_starts_with
    developers = Developer.find( :all, :conditions=>{ :name_starts_with=>'Zach' } )
    assert_equal( 1, developers.size )
  
    # we shouldn't find a record which starts with the last name Dennis
    developers = Developer.find( :all, :conditions=>{ :name_starts_with=>'Dennis' } )
    assert_equal( 0, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :name_starts_with=>['Za', 'Jo'] } )
    assert_equal( 2, developers.size )
  end
  
  def test_find_with_starts_with_with_reserved_words
    Group.destroy_all
    g1 = Group.create!(:order => "a")
    g2 = Group.create!(:order => "b")
    groups = Group.find(:all, :conditions => {:order_starts_with => 'a'})
    assert_equal g1, groups.first

    groups = Group.find(:all, :conditions => {:order_starts_with => ['a', 'b']})
    assert_equal [g1, g2], groups

    groups = Group.find(:all, :conditions => {:order_starts_with => ['z']})
    assert groups.empty?
  end  
  
  def test_find_with_ends_with
    developers = Developer.find( :all, :conditions=>{ :name_ends_with=>'Dennis' } )
    assert_equal( 1, developers.size )
  
    # we shouldn't find an issue which ends with the first name Zach
    developers = Developer.find( :all, :conditions=>{ :name_ends_with=>'Zach' } )
    assert_equal( 0, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :name_ends_with=>['is', 'oe'] } )
    assert_equal( 2, developers.size )
  end

  def test_find_with_ends_with_with_reserved_words
    Group.destroy_all
    g1 = Group.create!(:order => "a")
    g2 = Group.create!(:order => "b")
    groups = Group.find(:all, :conditions => {:order_ends_with => 'a'})
    assert_equal g1, groups.first

    groups = Group.find(:all, :conditions => {:order_ends_with => ['a', 'b']})
    assert_equal [g1, g2], groups

    groups = Group.find(:all, :conditions => {:order_ends_with => ['z']})
    assert groups.empty?
  end  
 
  def test_find_with_regex
    developers = Developer.find( :all, :conditions=>{ :name=>/^Zach/ } )
    assert_equal( 1, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :name=>/Dennis$/ } )
    assert_equal( 1, developers.size )
  end

  def test_find_using_regexp_with_reserved_words
    Group.destroy_all
    g1 = Group.create!(:order => "abc")
    group = Group.find(:first, :conditions => {:order => /abc/})
    assert_equal g1, group

    g2 = Group.create!(:order => "adf")
    groups = Group.find(:all, :conditions => {:order => /a/})
    assert_equal [g1, g2], groups
    
    groups = Group.find(:all, :conditions => {:order => /^a/})
    assert_equal g1, groups.first

    groups = Group.find(:all, :conditions => {:order => /df$/})
    assert_equal g2, groups.first
  end
  
  def test_find_with_less_than
    developers = Developer.find( :all, :conditions=>{ :id_lt=>2 } )
    assert_equal( 1, developers.size )
  end
  
  def test_find_with_greater_than
    developers = Developer.find( :all, :conditions=>{ :id_gt=>1 } )
    assert_equal( 2, developers.size )
  end
  
  def test_find_with_less_than_or_equal_to
    developers = Developer.find( :all, :conditions=>{ :id_lte=>2 } )
    assert_equal( 2, developers.size )
  end
  
  def test_find_with_greater_than_or_equal_to
    developers = Developer.find( :all, :conditions=>{ :id_gte=>1 } )
    assert_equal( 3, developers.size )
  end
  
  def test_find_not_equal_to
    developers = Developer.find( :all, :conditions=>{ :id_ne=>9999 } )
    assert_equal( Developer.count, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :id_not=>9999 } )
    assert_equal( Developer.count, developers.size )
  end
  
  def test_find_greater_than_time
    setup_time
    books = Book.find( :all, :conditions=>{ :created_at_gt => Time.local(2007, 01, 01, 21, 38, 0) } )
    assert_equal 2, books.size
  end

  def test_find_greater_than_time_with_reserved_words
    now = Time.now
    Group.destroy_all
    g1 = Group.create! :created_at => now - 1
    g2 = Group.create! :created_at => now 
    g3 = Group.create! :created_at => now + 1
    groups = Group.find( :all, :conditions=>{ :created_at_gt => now } )
    assert_equal [g3], groups
  end
  
  def test_find_less_than_time
    setup_time    
    books = Book.find( :all, :conditions=>{ :created_at_lt => Time.local(2007, 01, 01, 21, 38, 0) } )
    assert_equal 1, books.size
  end
  
  def test_find_less_than_time_with_reserved_words
    now = Time.now
    Group.destroy_all
    g1 = Group.create! :created_at => now - 1
    g2 = Group.create! :created_at => now 
    g3 = Group.create! :created_at => now + 1
    groups = Group.find( :all, :conditions=>{ :created_at_lt => now } )
    assert_equal [g1], groups
  end
  
  def test_find_greater_than_or_equal_to_time
    time = setup_time
    books = Book.find( :all, :conditions=>{ :created_at_gte => Time.local(2007, 01, 01, 21, 38, 0) } )
    assert_equal 3, books.size
  end
  
  def test_find_greater_than_or_equal_to_time_with_reserved_words
    now = Time.now
    Group.destroy_all
    g1 = Group.create! :created_at => now - 1
    g2 = Group.create! :created_at => now 
    g3 = Group.create! :created_at => now + 1
    groups = Group.find( :all, :conditions=>{ :created_at_gte => now } )
    assert_equal [g2, g3], groups
  end
  
  def test_find_less_than_or_equal_to_time
    setup_time
    
    books = Book.find( :all, :conditions=>{ :created_at_lte => Time.local(2007, 01, 01, 21, 38, 0) } )
    assert_equal 2, books.size
  end

  def test_find_less_than_or_equal_to_time_with_reserved_words
    now = Time.now
    Group.destroy_all
    g1 = Group.create! :created_at => now - 1
    g2 = Group.create! :created_at => now 
    g3 = Group.create! :created_at => now + 1
    groups = Group.find( :all, :conditions=>{ :created_at_lte => now } )
    assert_equal [g1, g2], groups
  end
  
  def test_find_not_equal_to_time
    setup_time
    books = Book.find( :all, :conditions=>{ :created_at_ne => Time.local(2007, 01, 01, 21, 38, 0) } )
    assert_equal 3, books.size
  end

  def test_find_greater_than_or_equal_to_time_with_reserved_words
    now = Time.now
    Group.destroy_all
    g1 = Group.create! :created_at => now - 1
    g2 = Group.create! :created_at => now 
    g3 = Group.create! :created_at => now + 1
    groups = Group.find( :all, :conditions=>{ :created_at_ne => now } )
    assert_equal [g1, g3], groups
  end
  
  def test_find_not_in_array
    developers = Developer.find( :all, :conditions=>{ :id_ne=>[ 9999 ] } )
    assert_equal( Developer.count, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :id_not=>[ 9999 ] } )
    assert_equal( Developer.count, developers.size )
    
    developers = Developer.find( :all, :conditions=>{ :id_not_in=>[ 9999 ] } )
    assert_equal( Developer.count, developers.size )
  end
  
  def test_find_not_in_array_with_reserved_words
    Group.destroy_all
    g1 = Group.create! :order => "a"
    g2 = Group.create! :order => "b"
    g3 = Group.create! :order => "c"
    groups = Group.find( :all, :conditions=>{ :order_not_in => %w(a c) } )
    assert_equal [g2], groups
  end
  
  def test_find_not_in_range
    developers = Developer.find( :all, :conditions=>{ :id_ne=>( 9998..9999 ) } )
    assert_equal( Developer.count, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :id_not=>( 9998..9999 ) } )
    assert_equal( Developer.count, developers.size )
    
    developers = Developer.find( :all, :conditions=>{ :id_not_in=>( 9998..9999 ) } )
    assert_equal( Developer.count, developers.size )
    
    developers = Developer.find( :all, :conditions=>{ :id_not_between=>( 9998..9999 ) } )
    assert_equal( Developer.count, developers.size )
  end
  
  def test_find_not_in_range_with_reserved_words
    now = Time.now
    Group.destroy_all
    g1 = Group.create! :created_at => now - 1
    g2 = Group.create! :created_at => now
    g3 = Group.create! :created_at => now + 1
    groups = Group.find( :all, :conditions=>{ :created_at_not_between => (now .. now+1) } )
    assert_equal [g1], groups
  end
  
  def test_find_not_matching_regex
    developers = Developer.find( :all, :conditions=>{ :id_ne=>/9999/ } )
    assert_equal( Developer.count, developers.size )
  
    developers = Developer.find( :all, :conditions=>{ :id_not=>/9999/ } )
    assert_equal( Developer.count, developers.size )
    
    developers = Developer.find( :all, :conditions=>{ :id_does_not_match=>/9999/ } )
    assert_equal( Developer.count, developers.size )
  end
  
  def test_find_not_matching_regex_with_reserved_words
    now = Time.now
    Group.destroy_all
    g1 = Group.create! :order => "abc"
    g2 = Group.create! :order => "def"
    g3 = Group.create! :order => "abcdef"
    groups = Group.find( :all, :conditions=>{ :order_ne => /abc/ } )
    assert_equal [g2], groups

    groups = Group.find( :all, :conditions=>{ :order_not => /def/ } )
    assert_equal [g1], groups

    groups = Group.find( :all, :conditions=>{ :order_does_not_match => /^a/ } )
    assert_equal [g2], groups
  end
  
  
  def test_find_with_string_and_hash
    developers = Developer.find( :all, 
      :conditions=>[ "name = 'Zach Dennis'", { :id=>1 } ] )
    assert_equal( 1, developers.size )
  end
  
  def test_find_with_string_and_hash_where_none_match
    developers = Developer.find( :all, 
      :conditions=>[ "id = 1", { :id=>2 } ] )
    assert_equal( 0, developers.size )
  end
  
  def test_find_with_string_and_hash_where_string_uses_hash_values
    developers = Developer.find( :all, 
      :conditions=>[ "id = :id", { :id=>1 } ] )
    assert_equal( 1, developers.size )
  end
  
  def test_find_where_value_is_null
    developers = Developer.find( :all,
                                 :conditions=>{ :name=>nil } )
    assert_equal( 1, developers.size )
  end
  
  
  def test_find_with_duck_typing_to_sql_for_an_id
    search_object = Object.new
    class << search_object
      def to_sql( caller )
        'id=1'
      end
    end
    
    developers = Developer.find( :all, 
      :conditions=>search_object )
    assert_equal( 1, developers.size )
  end
  
  def test_find_with_duck_typing_to_sql_for_multiple_conditions
    name = Object.new
    class << name
      def to_sql( caller )
        "name='Zach Dennis'"
      end
    end
    
    salary = Object.new
    class << salary
      def to_sql( caller )
        "salary='1'"
      end
    end
    
    developers = Developer.find( :all, 
                                 :conditions=>{ 
                                   :name=>name,
                                   :salary=>salary }
                                 )
    assert_equal( 1, developers.size )
  end
  
  def test_find_with_duck_typing_to_sql_for_multiple_conditions_find_nothing
    name = Object.new
    class << name
      def to_sql( caller )
        "name='Zach Dennis'"
      end
    end
    
    salary = Object.new
    class << salary
      def to_sql( caller )
        "salary='0'"
      end
    end
    
    developers = Developer.find( :all, 
                                 :conditions=>{ 
                                   :name=>name,
                                   :salary=>salary }
                                 )
    assert_equal( 0, developers.size )
  end
  
  def test_find_should_not_break_proper_string_escapes
    assert Book.find_or_create_by_title_and_publisher_and_author_name( "Book1%20Something", "Publisher%20", "%20Author%20" )
  end
  
  def test_find_should_not_break_boolean_searches
    Book.destroy_all
    book = Book.create! :title=>"Blah", :publisher=>"Del Rey", :author_name=>"Terry Brooks", :for_sale => false
    
    record = Book.find_by_author_name_and_for_sale('Terry Brooks', false)
    assert_equal book, record, "wrong record"
  end
  
  def test_find_should_not_break_with_question_marks
    Book.destroy_all
    book = Book.create! :title=>"Where's Waldo?", :publisher=>"Candlewick", :author_name=>"Martin Handford", :for_sale => false
    
    record = Book.find :first, :conditions => { :title_contains =>  '?' }
    assert_equal book, record, "wrong record"
  
    record = Book.find :first, :conditions => { :title_contains =>  'Waldo?' }
    assert_equal book, record, "wrong record 2"
  end
  
  def test_find_should_not_break_with_percent_signs
    Book.destroy_all
    book = Book.create! :title=>"Where's % Waldo", :publisher=>"Candlewick", :author_name=>"Martin Handford", :for_sale => false
  
    record = Book.find :first, :conditions => { :title_contains =>  '%' }
    assert_equal book, record, "wrong record"
  
    record = Book.find :first, :conditions => { :title_contains =>  '% Waldo' }
    assert_equal book, record, "wrong record 2"
  end
  
  def test_find_should_not_break_with_blank_conditions
    assert_equal Book.find(:first), Book.find(:first, :conditions => "")
    assert_equal Book.find(:first), Book.find(:first, :conditions => [""])
    assert_equal Book.find(:first), Book.find(:first, :conditions => ["",{}])
  end
    
end

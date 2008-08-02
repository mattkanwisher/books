# $Id: amazon.rb,v 1.17 2008/06/24 09:39:15 ianmacd Exp $
#

module Amazon

  NAME = 'Ruby/Amazon'
  @@config = {}

  # Prints debugging messages and works like printf, except that it prints
  # only when Ruby is run with the -d switch.
  #
  def Amazon.dprintf(format='', *args)
    $stderr.printf( format + "\n", *args ) if $DEBUG
  end


  # Encode a string, such that it is suitable for HTTP transmission.
  #
  def Amazon.url_encode(string)

    # Shamelessly plagiarised from Wakou Aoyama's cgi.rb.
    #
    string.gsub( /([^ a-zA-Z0-9_.-]+)/n ) do
      '%' + $1.unpack( 'H2' * $1.size ).join( '%' ).upcase
    end.tr( ' ', '+' )
  end


  # Convert a string from CamelCase to ruby_case.
  #
  def Amazon.uncamelise(str)
    # Avoid modifying by reference.
    #
    str = str.dup

    # Don't mess with string if all caps.
    #
    str.gsub!( /(.+?)(([A-Z][a-z]|[A-Z]+$))/, "\\1_\\2" ) if str =~ /[a-z]/

    # Convert to lower case.
    #
    str.downcase
  end


  # A Class for dealing with configuration files, such as
  # <tt>/etc/amazonrc</tt> and <tt>~/.amazonrc</tt>.
  #
  class Config < Hash

    def initialize

      config_files = [ File.join( 'amazonrc' ) ]
      if ENV.key?( 'HOME' )
        config_files << File.expand_path( File.join( '~', '.amazonrc' ) )
      end
    
      config_files.each do |cf|
	if File.exists?( cf ) && File.readable?( cf )

	  Amazon.dprintf( 'Opening %s ...', cf )
    
	  File.open( cf ) { |f| lines = f.readlines }.each do |line|
	    line.chomp!
    
	    # Skip comments and blank lines.
	    #
	    next if line =~ /^(#|$)/
    
	    Amazon.dprintf( 'Read: %s', line )
    
	    # Store these, because we'll probably find a use for these later.
	    #
	    begin
      	    match = line.match( /^(\S+)\s*=\s*(['"]?)([^'"]+)(['"]?)/ )
	      key, begin_quote, val, end_quote = match[1, 4]
	      raise ConfigError if begin_quote != end_quote
	    rescue NoMethodError, ConfigError
	      raise ConfigError, "bad config line: #{line}"
	    end
    
	    self[key] = val
    
	  end
	end

      end

    end
  end

end

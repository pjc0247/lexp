# lexecal parser

class Token
  attr_accessor :prev, :next
  
  attr_accessor :type
  attr_accessor :value
end

class Lexp
  def initialize(document)
    initialize_token_table
	parse document
  end

  def initialize_token_table
	@token_table = Hash.new

	@token_table.instance_eval do
		store " ", :t_sp
		store "	", :t_sp

		store "[", :t_left_bracket
		store "]", :t_right_bracket
		store "{", :t_left_brace
		store "}", :t_right_brace

		store ",", :t_comma

		store "int", :t_keyword
		store "int64", :t_keyword
		store "bool", :t_keyword
		store "string", :t_keyword
		store "char", :t_keyword
		store "binary", :t_keyword
		store "float", :t_keyword
		store "double", :t_keyword
	end
  end

  def get_token_type(value)
    case value
      when /^\"*.\"$/
	    return :t_const_string
	  when /^[0-9]+$/
	    return :t_const_number
	  when /^[0-9]*\\.[0-9]+$/
	    return :t_const_float
	  when /^[a-zA-Z0-9_]+$/
	    return :t_id
	  else
	    return :t_none
    end
  end

  def push_token(type, value)
	token = Token.new
	token.type = type
	token.value = value
	token.prev = @tokens.last

	@tokens.push token
  end

  def tokenize(document)
    @tokens = Array.new
	
	document.each_line do |line|
      line.lstrip!
	  line.rstrip!

	  offset = 0
	  i = 0
	  for i in 0..line.length-1
		@token_table.each do |k,v|

	      candidate = line.slice(i, k.length)
	      if k == candidate
		    if offset != i
		      t = line.slice(offset, i-offset)
		      push_token(
			      get_token_type(t), t)
		    end
		    if v != :t_sp
  		      push_token v, candidate
			end

		    i += k.length-1
		    offset = i+1
		  end
		end
	  end

	  if offset < i
		t = line.slice(offset, i-offset)
		push_token(
		    get_token_type(t), t)
	  end
	end

	@tokens.each do |k|
		puts "'%5s' - #{k.type}" % k.value
	end
  end
  def parse(document)
	tokenize document
  end

end

a = Lexp.new(
	"S2C packetname{
		int aee
		bool qww
	}"
)

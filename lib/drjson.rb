
# DrJson closes abruptly cut-off JSON strings.
#
#     $ echo '{"foo":nul' | drjson 
#     {"foo":null}
# 
# Regular, well-formed JSON is passed through untouched.
#
# Install with rubygems
#
#     $ gem install drjson
#
# Find the [source on GitHub][so].
#
# [so]: https://github.com/mat/drjson/

require 'strscan'

class DrJson

  ### repair(json)

  # Parses and repairs the possbily cut-off input `json_str`
  # in recursive descent fashion. Returns `json_str` with 
  # necesarry closing tags appended.
  def repair(json_str)
    @input = StringScanner.new(json_str)
    @result = ""
 
    begin
      # Real world JSON has arrays as top level elements, yep.
      parse_object || parse_array
      spaces
    rescue UnexpectedTokenError => e
      raise e if debug
    end
    result
  end
  class UnexpectedTokenError < StandardError ; end

  def initialize(options = {})
    @debug = options.fetch(:debug, false)
  end

  private
  attr_reader :input, :result, :debug

  #### Non-Terminal Symbols

  def parse_object
    spaces
    if next_is "{"
      spaces
      begin
        parse_members
      ensure # and recursively auto close
        must_see "}"
      end
      spaces
    end
  end

  def parse_members
    parse_pair
    spaces
    if next_is ","
      parse_members
    end
  end
  
  # An object's pair is the strictest of all
  # elements: It has to have all syntax elements
  # that's why we `&&`` them.
  def parse_pair
    parse_string &&
    spaces &&
    must_see(":") &&
    spaces &&
    # We may have to fill in a rhs *null*.
    (parse_value || append('null'))
  end

  def parse_array
    spaces
    if next_is "["
      spaces
      begin
        parse_elements || true
       ensure # and recursively auto close
         must_see "]"
      end
    end
  end

  def parse_elements
    spaces
    value_found = parse_value
    spaces
    while next_is ","
      spaces
      parse_value || append('null')
      spaces
    end

    value_found
  end

  def parse_value
    spaces
    parse_string || parse_number || parse_object || parse_array || consume(TRUE) || consume(FALSE) || consume(NULL)
  end
  NULL  = /null/
  FALSE = /false/
  TRUE  = /true/
 
  #### Terminal Symbols

  def parse_string
    spaces
    if next_is "\""
      consume CHAR_SEQUENCE

      # We don't need to `ensure` here because we
      # don't need to close strings recursively;
      # a string cannot contain another string.

      must_see "\""
    end
  end
  CHAR_SEQUENCE = /([^\"\\\n]|\\([tbrfn\"\/\\])|\\u[0-9a-f]{4,4})*/i

  def parse_number
    spaces
    number_found = parse_int
    parse_frac
    parse_exp

    number_found
  end

  def parse_int
    consume MINUS
    consume DIGITS
  end

  def parse_frac
    if next_is "."
      consume DIGITS
    end
  end

  def parse_exp
    if next_is("e") || next_is("E")
      consume(MINUS) || consume(PLUS)
      consume DIGITS
    end
  end
  MINUS = /-/
  PLUS = /[+]/
  DIGITS = /\d+/
 
  #### Helpers 

  def spaces
    consume ANY_WHITESPACE
  end
  ANY_WHITESPACE = /\s*/

  # `must_see` makes sure we add the necessary
  # amount of (closing) tags to the output
  def must_see(char)
    spaces
    if next_is char
      # All good, input as expected.
      char
    elsif input.eos?
      # Finally, the case we've been waiting for:
      # Input exhausted, but still elements to close.
      append char
    else
      append char
      # The magic trick:
      #   We implicitly use the stack to count how many closing tags we have/need.
      #   We pair with exception's `ensure` mechanism to actually write them out.
      if debug
        msg = "Seen so far: %s" % result.clone
        raise UnexpectedTokenError, msg
      else
        raise UnexpectedTokenError
      end
    end
  end
 
  # Checks whether the next char is `exptected_char`
  #
  # If it is, `expected_char` is consumed, `appended` and true is returned.
  # If not, this call is a no op and false is returned.
  def next_is(expected_char)
    next_char = input.peek(1)
    if next_char == expected_char
      append input.getch
    end
  end

  # `consume` is `next_is`'s sibling for arbitrary patterns
  # not single chars. Same behavior.
  def consume(pattern)
    if input.match?(pattern)
      append input.scan(pattern)
    end
  end

  def append(str)
    result << str
  end
end


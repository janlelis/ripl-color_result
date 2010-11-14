# Default colorization module:
#  Code taken from the (blackwinter) wirble gem, adjusted api. See COPYING for credits.

class << Ripl::ColorResult::Default = Module.new
  def tokenize(str)
    raise 'missing block' unless block_given?
    chars = str.split(//)

    # $stderr.puts "DEBUG: chars = #{chars.join(',')}"

    state, val, i, lc = [], '', 0, nil
    while i <= chars.size
      repeat = false
      c = chars[i]

      # $stderr.puts "DEBUG: state = #{state}"

      case state[-1]
      when nil
        case c
        when ':'
          state << :symbol
        when '"'
          state << :string
        when '#'
          state << :object
        when /[a-z]/i
          state << :keyword
          repeat = true
        when /[0-9-]/
          state << :number
          repeat = true
        when '{'
          yield :open_hash, '{'
        when '['
          yield :open_array, '['
        when ']'
          yield :close_array, ']'
        when '}'
          yield :close_hash, '}'
        when /\s/
          yield :whitespace, c
        when ','
          yield :comma, ','
        when '>'
          yield :refers, '=>' if lc == '='
        when '.'
          yield :range, '..' if lc == '.'
        when '='
          # ignore these, they're used elsewhere
          nil
        else
          # $stderr.puts "DEBUG: ignoring char #{c}"
        end
      when :symbol
        case c
        # XXX: should have =, but that messes up foo=>bar
        when /[a-z0-9_!?]/
          val << c
        else
          yield :symbol_prefix, ':'
          yield state[-1], val
          state.pop; val = ''
          repeat = true
        end
      when :string
        case c
        when '"'
          if lc == "\\"
            val[-1] = ?"
          else
            yield :open_string, '"'
            yield state[-1], val
            state.pop; val = ''
            yield :close_string, '"'
          end
        else
          val << c
        end
      when :keyword
        case c
        when /[a-z0-9_]/i
          val << c
        else
          # is this a class?
          st = val =~ /^[A-Z]/ ? :class : state[-1]

          yield st, val
          state.pop; val = ''
          repeat = true
        end
      when :number
        case c
        when /[0-9e-]/
          val << c
        when '.'
          if lc == '.'
            val[/\.$/] = ''
            yield state[-1], val
            state.pop; val = ''
            yield :range, '..'
          else
            val << c
          end
        else
          yield state[-1], val
          state.pop; val = ''
          repeat = true
        end
      when :object
        case c
        when '<'
          yield :open_object, '#<'
          state << :object_class
        when ':'
          state << :object_addr
        when '@'
          state << :object_line
        when '>'
          yield :close_object, '>'
          state.pop; val = ''
        end
      when :object_class
        case c
        when ':'
          yield state[-1], val
          state.pop; val = ''
          repeat = true
        else
          val << c
        end
      when :object_addr
        case c
        when '>'
        when '@'
          yield :object_addr_prefix, ':'
          yield state[-1], val
          state.pop; val = ''
          repeat = true
        else
          val << c
        end
      when :object_line
        case c
        when '>'
          yield :object_line_prefix, '@'
          yield state[-1], val
          state.pop; val = ''
          repeat = true
        else
          val << c
        end
      else
        raise "unknown state #{state}"
      end

      unless repeat
        i += 1
        lc = c
      end
    end
  end

  #
  # Terminal escape codes for colors.
  #
  COLORS = {
    :nothing => '0;0',
    :black => '0;30',
    :red => '0;31',
    :green => '0;32',
    :brown => '0;33',
    :blue => '0;34',
    :cyan => '0;36',
    :purple => '0;35',
    :light_gray => '0;37',
    :dark_gray => '1;30',
    :light_red => '1;31',
    :light_green => '1;32',
    :yellow => '1;33',
    :light_blue => '1;34',
    :light_cyan => '1;36',
    :light_purple => '1;35',
    :white => '1;37',
  }

  #
  # Return the escape code for a given color.
  #
  def get_color(key)
    COLORS.key?(key) && "\033[#{COLORS[key]}m"
  end

  #
  # Default Wirble color scheme.
  #
  DEFAULT_SCHEME = {
    # delimiter colors
    :comma => :blue,
    :refers => :blue,

    # container colors (hash and array)
    :open_hash => :green,
    :close_hash => :green,
    :open_array => :green,
    :close_array => :green,

    # object colors
    :open_object => :light_red,
    :object_class => :white,
    :object_addr_prefix => :blue,
    :object_line_prefix => :blue,
    :close_object => :light_red,

    # symbol colors
    :symbol => :yellow,
    :symbol_prefix => :yellow,

    # string colors
    :open_string => :red,
    :string => :cyan,
    :close_string => :red,

    # misc colors
    :number => :cyan,
    :keyword => :green,
    :class => :light_green,
    :range => :red,
  }

  #
  # Fruity testing colors.
  #
  TESTING_SCHEME = {
    :comma => :red,
    :refers => :red,
    :open_hash => :blue,
    :close_hash => :blue,
    :open_array => :green,
    :close_array => :green,
    :open_object => :light_red,
    :object_class => :light_green,
    :object_addr => :purple,
    :object_line => :light_purple,
    :close_object => :light_red,
    :symbol => :yellow,
    :symbol_prefix => :yellow,
    :number => :cyan,
    :string => :cyan,
    :keyword => :white,
    :range => :light_blue,
  }

  #
  # Set color map to hash
  #
  def scheme=(hash)
    @scheme = hash
  end

  #
  # Get current color map
  #
  def scheme
    @scheme ||= {}.update(DEFAULT_SCHEME)
  end

  #
  # Return a string with the given color.
  #
  def colorize_string(str, color)
    col, nocol = [color, :nothing].map { |key| get_color(key) }
    col ? "#{col}#{str}#{nocol}" : str
  end

  #
  # Colorize the results of inspect
  #
  def colorize_code(str)
    ret, nocol = '', get_color(:nothing)
    tokenize(str) do |tok, val|
      ret << colorize_string(val, scheme[tok])
    end
    ret
  rescue # catch any errors from the tokenizer (just in case)
    str
  end
end

# J-_-L

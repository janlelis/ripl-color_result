require 'ripl'

module Ripl
  module ColorResult
    VERSION = '0.1.1'
    COLORS = {
      :nothing      => '0;0',
      :black        => '0;30',
      :red          => '0;31',
      :green        => '0;32',
      :brown        => '0;33',
      :blue         => '0;34',
      :purple       => '0;35',
      :cyan         => '0;36',
      :light_gray   => '0;37',
      :dark_gray    => '1;30',
      :light_red    => '1;31',
      :light_green  => '1;32',
      :yellow       => '1;33',
      :light_blue   => '1;34',
      :light_purple => '1;35',
      :light_cyan   => '1;36',
      :white        => '1;37',
    }

    # def inspect_result(result)
    #   result.inspect
    # end

    def format_prompt(result)
      @result_prompt
    end

    def format_result(result)
      return super if !config[:color_result_engine]
      format_prompt(result) + inspect_result(result)
    end

    def inspect_result(result)
      # return super if !config[:color_result_engine]

      case config[:color_result_engine].to_sym
      when :coderay
        require 'coderay'
        CodeRay.scan( result.inspect, :ruby ).term
      when :ap, :awesome_print
        require 'ap'
        result.awesome_inspect
      else # :default
        require 'ripl/color_result/default_colorizer'
        DefaultColorizer.colorize_code( result.inspect )
      end

    end
  end
end

Ripl::Shell.send :include, Ripl::ColorResult if defined? Ripl::Shell

Ripl.config[:color_result_engine] ||= :default
Ripl.config[:color_result_scheme] ||= { # color scheme for default colorization, original from wirble
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

# J-_-L

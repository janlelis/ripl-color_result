require 'ripl'

module Ripl
  module ColorResult
    VERSION = '0.3.1'

    def format_result(result)
      return super if !config[:color_result_engine]

      @result_prompt + case config[:color_result_engine].to_sym
      when :coderay
        require 'coderay'
        CodeRay.scan( result.inspect, :ruby ).term
      when :ap, :awesome_print
        require 'ap'
        result.awesome_inspect( config[:color_result_ap_options] || {} )
      else # :default
        require 'wirb'
        Wirb.start
        Wirb.colorize_result result.inspect, Ripl.config[:color_result_default_schema]
      end
    end
  end
end

Ripl::Shell.include Ripl::ColorResult

Ripl.config[:color_result_engine] ||= :default
Ripl.config[:color_result_default_schema] ||= { # see Wirb::COLORS for a color list
    # container
    :open_hash        => :light_green,
    :close_hash       => :light_green,
    :open_array       => :light_green,
    :close_array      => :light_green,

    :open_set         => :green,
    :close_set        => :green,

    # delimiter colors
    :comma            => :green,
    :refers           => :green,

    # class
    :class            => :light_green,
    :class_separator  => :green,
    :object_class     => :light_green,

    # object
    :open_object               => :green,
    :object_description_prefix => :green,
    :object_description        => :brown,
    :object_address_prefi      => :brown_underline,
    :object_address            => :brown_underline,
    :object_line_prefix        => :brown_underline,
    :object_line               => :brown_underline,
    :object_line_number        => :brown_underline,
    :object_variable_prefix    => :light_purple,
    :object_variable           => :light_purple,
    :close_object              => :green,

    # symbol
    :symbol_prefix       => :yellow,
    :symbol              => :yellow,
    :open_symbol_string  => :brown,
    :symbol_string       => :yellow,
    :close_symbol_string => :brown,

    # string
    :open_string  => :light_gray,
    :string       => :dark_gray,
    :close_string => :light_gray,

    # regexp
    :open_regexp  => :light_blue,
    :regexp       => :dark_gray,
    :close_regexp => :light_blue,
    :regexp_flags => :light_red,

    # number
    :number => :cyan,
    :range  => :red,
    :open_rational      => :light_cyan,
    :rational_separator => :light_cyan,
    :close_rational     => :light_cyan,

    # misc
    :default => nil,
    :keyword => nil, # some lowercased word, merge with default?
    :time    => :purple,
    :nil     => :light_red,
    :false   => :red,
    :true    => :green,
}

# J-_-L

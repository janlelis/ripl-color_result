require 'ripl'

module Ripl
  module ColorResult
    VERSION = '0.1.1'

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
        require 'ripl/color_result/default'
        Default.colorize_code( result.inspect )
      end

    end
  end
end

Ripl::Shell.send :include, Ripl::ColorResult if defined? Ripl::Shell
Ripl.config[:color_result_engine] ||= :default

# J-_-L

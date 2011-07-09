require 'ripl'

module Ripl
  module ColorResult
    VERSION = '0.4.0'

    def before_loop
      if Ripl.config[:color_result_engine] == :default
        require 'wirb' unless defined?(Wirb)
        Ripl.config[:color_result_default_schema].merge! Wirb.schema
      end
    end

    def format_result(result)
      return super if !config[:color_result_engine]

      @result_prompt + case config[:color_result_engine].to_sym
      when :coderay
        require 'coderay' unless defined?(CodeRay)
        CodeRay.scan( result.inspect, :ruby ).term
      when :ap, :awesome_print
        require 'ap' unless defined?(AwesomePrint)
        result.awesome_inspect( config[:color_result_ap_options] || {} )
      else # :default
        require 'wirb' unless defined?(Wirb)
        Wirb.start unless Wirb.running?
        Wirb.colorize_result result.inspect, Ripl.config[:color_result_default_schema]
      end
    end
  end
end

Ripl::Shell.include Ripl::ColorResult

Ripl.config[:color_result_engine] ||= :default
Ripl.config[:color_result_default_schema] = Hash.new{ |h,k| h[k] = {} }

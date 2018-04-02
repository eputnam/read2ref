require 'puppet-lint'
require 'fileutils'
require 'rainbow'

module Read2ref
  class Manifest
    attr_reader :tokens, :path

    def initialize(path)
      @path = path
      lexer = PuppetLint::Lexer.new
      begin
	puts "Reading manifest at #{path}"
	file = File.read(path)
      rescue
	print Rainbow("Could not read manifest at ").red
	puts path
      end
      @tokens = lexer.tokenise(file)
      PuppetLint::Data.tokens = @tokens
    end

    def for_review?
      @for_review
    end

    # Gets class or defined type indexes from the manifest
    # @return [Array] 
    #   An array of indexes. See puppet-lint for more info.
    def indexes
      indexes = if PuppetLint::Data.class_indexes.empty?
                  PuppetLint::Data.defined_type_indexes
                else
                  PuppetLint::Data.class_indexes
                end
    end

    # Array of allowed token types. If a resource has a name like:
    #   class apache::vhost (...){..}
    # then the "apache::vhost" token has the type :NAME. However, if it looks like:
    #   class apache::vhost(...){...}
    # puppet-lint assumes it is a function and thus the token is of type :FUNCTION_NAME.
    # We allow both because sometimes the space before the parentheses doesn't happen for whatever reason.
    # @return [Array]
    def token_name_types
      [ :NAME, :FUNCTION_NAME ]
    end

    # Array of allowed token resource types
    # The token that contains the word "class" from the signature is of type :CLASS.
    # The token that contains the word "define" from the signature is of type :DEFINE.
    # @return [Array]
    def token_resource_types
      [ :CLASS, :DEFINE ]
    end

    # Finds the token with the resource name from the list of indexes
    # @return [PuppetLint::Token]
    #   Token containing the name of the resource
    def name_token
      indexes[0][:tokens].select { |token| token_name_types.include?(token.type) && token_resource_types.include?(token.prev_token.prev_token.type) }[0]
    end

    # Collection of parameter tokens
    # @return [Array]
    #   Collection of parameter tokens
    def parameter_tokens
      PuppetLint::Data.param_tokens(@tokens)
    end

    # not sure we need to do this validation, but we do anyway
    # @return [Boolean]
    #   Is the token of type :VARIABLE and is the next token either :WHITESPACE or :COMMA?
    def valid_parameter_token?(token)
      next_token_types = [ :WHITESPACE, :COMMA ]
      token.type == :VARIABLE && 
	next_token_types.include?(token.next_token.type) &&
	!token.value.match(/::/)
    end

    # Assembles an array of parameter names from the list of parameter tokens
    # @return [Array]
    #   Collection of parameter name strings
    def parameters_array
      return if parameter_tokens.nil?
      parameter_tokens.select { |token| token.value if valid_parameter_token?(token) }.map { |token| token.value }
    end

    # Writes Strings-style comments to a temporary file, then writes the original manifest below that and moves the temporary file back to the source_path
    # @param [String] source_path
    #   Path to original manifest
    # @param [Hash] hash
    #   Hash from README. See Read2ref::Readme class.
    def write(hash)
      array = parameters_array
      unless array.nil?
	@for_review = true
	name = name_token.value
	puts Rainbow("Writing comments for #{name}").green
	tmp_path = "#{File.dirname(@path)}/tmp#{File.basename(@path)}"
	File.open(tmp_path,'w') do |file|
	  unless array.empty?
	    file.puts "# @summary"
	    file.puts "#  "
	  end
	  array.each do |str|
	    file.puts "# @param #{str}"
	    file.puts "#  #{hash[name][str]}" if hash[name] && !hash[name].empty?
	  end
	  File.foreach(@path) do |line|
	    file.puts line
	  end
	end
	FileUtils.mv(tmp_path, @path)
      else
	puts Rainbow("No parameters for #{@path}, nothing to write.").yellow
      end
    end

  end
end

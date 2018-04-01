require 'puppet-lint'

module Read2ref
  class Manifest
    attr_reader :tokens

    def initialize(path)
      lexer = PuppetLint::Lexer.new
      file = File.read(path)
      @tokens = lexer.tokenise(file)
      PuppetLint::Data.tokens = @tokens
    end

    def indexes
      indexes = if PuppetLint::Data.class_indexes.empty?
                  PuppetLint::Data.defined_type_indexes
                else
                  PuppetLint::Data.class_indexes
                end
    end

    def token_name_types
      [ :NAME, :FUNCTION_NAME ]
    end

    def token_resource_types
      [ :CLASS, :DEFINE ]
    end

    def name_token
      indexes[0][:tokens].select { |token| token_name_types.include?(token.type) && token_resource_types.include?(token.prev_token.prev_token.type) }[0]
    end

    def parameter_tokens
      PuppetLint::Data.param_tokens(@tokens)
    end

    def valid_parameter_token?(token)
      next_token_types = [ :WHITESPACE, :COMMA ]
      token.type == :VARIABLE && next_token_types.include?(token.next_token.type)
    end

    def parameters_array
      parameter_tokens.select { |token| token.value if valid_parameter_token?(token) }.map { |token| token.value }
    end

    def write(source_path, hash=nil)
      array = parameters_array
      tmp_path = "#{File.dirname(source_path)}/tmp#{File.basename(source_path)}"
      name = name_token.value
      File.open(tmp_path,'w') do |file|
	puts "Opening temp file for #{source_path}"
	unless array.empty?
	  file.puts "# @summary"
	  file.puts "#  "
	end
	array.each do |str|
	  file.puts "# @param #{str}"
	  file.puts "#  #{hash[name][str]}" if hash[name] && !hash[name].empty?
	end
	File.foreach(source_path) do |line|
	  file.puts line
	end
      end
      FileUtils.mv(tmp_path, source_path)
    end

  end
end

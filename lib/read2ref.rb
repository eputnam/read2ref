require 'commonmarker'
require 'pp'
require 'pry'
require 'puppet-lint'

module Read2ref
  class << self
    attr_accessor :mdhash
    def parse_readme(path)
      puts "Processing readme #{path}"
      md_ast = CommonMarker.render_doc(File.read(path))
      hash_face = {}
      current_res = ""
      puts "Walking AST..."
      md_ast.walk do |node|
	if node.type == :header && node.header_level == 4
	  sc_header = node.first_child.string_content
	  current_res = sc_header
	  hash_face[current_res] = {}
	end
	if node.type == :header && node.header_level == 5
	  param = node.first_child.string_content
	  current_param = param
	  #binding.pry if param == 'databases'
	  hash_face[current_res][current_param] = node.next.collect do |child|
	    if child.type == :text
	      child.string_content
	    elsif child.type == :code
	      "`#{child.string_content}`"
	    elsif child.type == :link
	      "[#{child.first_child.string_content}](#{child.url})"
	    end 
	  end.join
	end
      end
      @mdhash = hash_face
    end

    def parse_manifest(path)
      puts "Processing manifest #{path}"
      l = PuppetLint::Lexer.new
      file = File.read(path)
      t = l.tokenise(file)
      PuppetLint::Data.tokens = t
      indexes = if PuppetLint::Data.class_indexes.empty?
		  PuppetLint::Data.defined_type_indexes
		else
		  PuppetLint::Data.class_indexes
		end
      token_ntypes = [ :NAME, :FUNCTION_NAME ]
      token_rtypes = [ :CLASS, :DEFINE ]
      name_token = indexes[0][:tokens].select { |token| token_ntypes.include?(token.type) && token_rtypes.include?(token.prev_token.prev_token.type) }
      puts "NAME TOKEN: #{name_token[0]}"
      name = name_token[0].value
      puts "Got class name: #{name}"
      params = PuppetLint::Data.param_tokens(t)
      strings_array = []
      params.each do |param_token|
	if param_token.type == :VARIABLE && param_token.next_token.type == :WHITESPACE
	  strings_array.push(param_token.value)
	end
      end unless params.nil?
      puts "Got params: #{strings_array}"
      tmp_file = "#{File.dirname(path)}/tmp#{File.basename(path)}"
      File.open(tmp_file,'w') do |file|
	puts "Opening temp file for #{path}"
	unless strings_array.empty?
	  file.puts "# @summary"
	  file.puts "#  "
	end
	strings_array.each do |str|
	  file.puts "# @param #{str}"
	  file.puts "#  #{@mdhash[name][str]}" if @mdhash[name] && !@mdhash[name].empty?
	end
	File.foreach(path) do |line|
	  file.puts line
	end
      end
      FileUtils.mv(tmp_file, path)
    end
  end
end

readme = ARGV[0]
manifests = Dir.glob(ARGV[1])
Read2ref.parse_readme(readme)
manifests.each do |manifest|
  Read2ref.parse_manifest(manifest) if manifest.match(/\.pp/) && !manifest.match(/tmp/)
end

# Read2ref.parse_readme("/Users/eric.putnam/src/puppetlabs-mysql/README.md")
# Read2ref.parse_manifest("/Users/eric.putnam/src/puppetlabs-mysql/manifests/backup/mysqlbackup.pp")


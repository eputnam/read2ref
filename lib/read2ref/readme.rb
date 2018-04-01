require 'commonmarker'

module Read2ref
  class Readme
    attr_reader :ast

    def initialize(path)
      @path = path
      @ast = CommonMarker.render_doc(File.read(path))
    end

    def to_hash
      hash_face = {}
      current_res = ""
      ast.walk do |node|
	if node.type == :header && node.header_level == 4
	  sc_header = node.first_child.string_content
	  current_res = sc_header
	  hash_face[current_res] = {}
	end
	if node.type == :header && node.header_level == 5
	  param = node.first_child.string_content
	  current_param = param
	  #binding.pry if param == 'databases'
	  param_desc = ""
	  loop do
	    node = node.next
	    break if node.type == :header
	    param_desc += " " + node.collect do |child|
	      if child.type == :text
		child.string_content unless child.string_content.match(/Data type.*/) || child.string_content.match(/Default value.*/)
	      elsif child.type == :code
		"`#{child.string_content}`"
	      elsif child.type == :link
		"[#{child.first_child.string_content}](#{child.url})"
	      end 
	    end.join
	  end
	  hash_face[current_res][current_param] = param_desc
	end
      end
      hash_face
    end
  end
end

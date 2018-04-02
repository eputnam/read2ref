require_relative 'read2ref/readme'
require_relative 'read2ref/manifest'

module Read2ref
  class << self

    attr_accessor :mdhash

    def run(readme_path, manifest_glob)
      readme = parse_readme(readme_path)
      mdhash = readme.to_hash

      manifests = Dir.glob(manifest_glob)
      manifests_for_review = []
      manifests.each do |manifest|
	if manifest.match(/\.pp/) && !manifest.match(/tmp/)
	  m = parse_manifest(manifest)
	  m.write(mdhash)
	  manifests_for_review.push(m.path) if m.for_review?
	end
      end
      puts Rainbow("\nComments were written to these manifests, please review for accuracy/completeness:").cyan
      puts manifests_for_review
    end

    # Parses README file at path
    # @param [String] path
    #   Absolute path to the README file for the module
    # @return [Hash]
    #   Hash structured by resource with parameters underneath
    def parse_readme(path)
      readme = Readme.new(path)
    end

    # Parses and writes to manifest at path
    # @param [String] path
    #   Absolute path to the manifest file
    # @return [void]
    def parse_manifest(path)
      Manifest.new(path)
    end

  end
end

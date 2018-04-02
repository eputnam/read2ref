require_relative 'read2ref/readme'
require_relative 'read2ref/manifest'

module Read2ref
  class << self

    attr_accessor :mdhash

    def run(readme_path, manifest_glob)
      readme = readme_path
      manifests = Dir.glob(manifest_glob)
      parse_readme(readme)
      manifests.each do |manifest|
        parse_manifest(manifest) if manifest.match(/\.pp/) && !manifest.match(/tmp/)
      end
    end

    # Parses README file at path
    # @param [String] path
    #   Absolute path to the README file for the module
    # @return [Hash]
    #   Hash structured by resource with parameters underneath
    def parse_readme(path)
      readme = Readme.new(path)
      @mdhash = readme.to_hash
    end

    # Parses and writes to manifest at path
    # @param [String] path
    #   Absolute path to the manifest file
    # @return [void]
    def parse_manifest(path)
      manifest = Manifest.new(path)
      name = manifest.name_token.value
      manifest.write(@mdhash)
    end
  end
end

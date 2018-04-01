require_relative 'read2ref/readme'
require_relative 'read2ref/manifest'

module Read2ref
  class << self

    attr_accessor :mdhash

    # Parses README file at path
    # @param [String] path
    #   Absolute path to the README file for the module
    # @return [Hash]
    #   Hash structured by resource with parameters underneath
    def parse_readme(path)
      puts "Processing readme #{path}"
      readme = Readme.new(path)
      puts "Walking AST..."
      @mdhash = readme.to_hash
    end

    # Parses and writes to manifest at path
    # @param [String] path
    #   Absolute path to the manifest file
    # @return [void]
    def parse_manifest(path)
      puts "Processing manifest #{path}"
      manifest = Manifest.new(path)
      puts "NAME TOKEN: #{manifest.name_token}"
      name = manifest.name_token.value
      manifest.write(@mdhash)
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


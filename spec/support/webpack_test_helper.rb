# Discussion Reference: https://github.com/rails/webpacker/pull/360
# Source modified from this closed PR: https://github.com/rails/webpacker/pull/341
# Taken from gist: https://gist.github.com/stevehanson/d51aa2e70dc0c9dac07c0fb6317644b4
class WebpackTestHelper
  class << self
    def compile_webpack_assets
      unless checksum_matches?
        write_checksum
        Webpacker.compile
      end
    end

    private

    def checksum
      files = Dir["app/javascript/**/*", "package.json", "yarn.lock"].reject { |f| File.directory?(f) }
      files.map { |f| File.mtime(f).utc.to_i }.max.to_s
    end

    def checksum_matches?
      last_checksum = File.exists?(checksum_file_path) ? File.read(checksum_file_path) : nil
      last_checksum == checksum
    end

    def write_checksum
      File.write(checksum_file_path, checksum)
    end

    def checksum_file_path
      Rails.root.join('tmp', '.webpack-checksum')
    end
  end
end

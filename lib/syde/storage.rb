module Syde
class Vault
  module Storage
    DefaultStorageFile = File.expand_path("~/.syde/storage_file.vault")
    FileUtils.touch(DefaultStorageFile) unless File.exist?(DefaultStorageFile)

    def self.valid_format?(data)
      data.is_a?(Hash) &&
      data.keys.include?(:encrypted) &&
      data.keys.include?(:plaintext) &&
      data[:plaintext].keys.include?(:iv) &&
      data[:plaintext].keys.include?(:secret_key_hash) &&
      data[:encrypted].keys.include?(:secret_key) &&
      data[:encrypted].keys.include?(:contents) &&
      data[:encrypted][:contents].is_a?(String)
    end

    def self.read(content)
      file { |f| f.read }
    end

    def self.write(content, file = nil)
      if file
        File.open(file, "w") do |f|
          f << content
        end
      else
        file("w") { |f| f << content }
      end
    end

    def self.file(mode = "r", &block)
      File.open(DefaultStorageFile, mode, &block)
    end
  end
end
end
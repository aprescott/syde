module Syde
class Vault
  module Crypto
    def self.random_bytes(length)
      File.open("/dev/urandom") { |f| f.read(length) }
    end

    def self.new_iv
      cipher.random_iv
    end

    def self.aes(mode, key, iv, text)
      c = cipher.send(mode)
      c.key = digest(key)
      c.iv = iv
      c.update(text) << c.final
    end

    def self.encrypt(key, iv, plaintext)
      aes(:encrypt, key, iv, plaintext)
    end

    def self.decrypt(key, iv, ciphertext)
      aes(:decrypt, key, iv, ciphertext)
    end

    def self.digest(input)
      OpenSSL::Digest::SHA256.digest(input)
    end

    private

    def self.cipher
      OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    end
  end
end
end

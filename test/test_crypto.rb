class TC_Syde_Crypto < Test::Unit::TestCase  
  def setup
    FileUtils.rm(TEST_STORAGE_FILE)
    @vault = Syde::Vault.create("test_password", TEST_STORAGE_FILE)
  end

  def tear_down
    FileUtils.rm(TEST_STORAGE_FILE)
  end

  def iv
    @vault.iv
  end

  def encrypt(key, plaintext)
    Syde::Vault::Crypto.encrypt(key, iv, plaintext)
  end

  def decrypt(key, ciphertext)
    Syde::Vault::Crypto.decrypt(key, iv, ciphertext)
  end

  def test_invertible
    assert_equal "test_plaintext", decrypt("test_key", encrypt("test_key", "test_plaintext"))
  end

  def test_secret_key_length
    Syde::Vault::Crypto.random_bytes(1024).size == 1024
  end
end
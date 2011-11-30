class TC_Syde_Storage < Test::Unit::TestCase
  TEST_DATA = { :plaintext => { :iv => "test iv", :secret_key_hash => "test secret key hash" },
                :encrypted => { :secret_key => "test secret key",
                                :contents => "" } }

  def setup
    FileUtils.rm(TEST_STORAGE_FILE) if File.exist?(TEST_STORAGE_FILE)
    @vault = Syde::Vault.create("test_password", TEST_STORAGE_FILE)
  end

  def valid_format?(d)
    Syde::Vault::Storage.valid_format?(d)
  end

  def test_valid_format
    assert valid_format?(TEST_DATA), "data intended to be in correct format was found invalid"
  end

  def test_internal_valid_format
    @vault.unlock!("test_password")
    assert valid_format?(@vault.data), "internal inconsistency"
  end

  def test_data_copy
    Marshal.load(Marshal.dump(TEST_DATA))
  end  

  def test_invalid_format
    invalid_formats = {
      [] => "annot be an array",
      nil => "cannot be nil",
      {} => "contains nothing",
    }

    invalid_formats.each do |d, result|
      assert !valid_format?(d), result
    end
  end

  def test_missing_plaintext
    d = test_data_copy
    d.delete(:plaintext)
    assert !valid_format?(d), "data is incorrect format: :plaintext key is missing"
  end

  def test_missing_encrypted
    d = test_data_copy
    d.delete(:encrypted)
    assert !valid_format?(d), "data is incorrect format: :encrypted key is missing"
  end
  def test_missing_encrypted_contents
    d = test_data_copy
    d[:encrypted].delete(:contents)
    assert !valid_format?(d), "data is incorrect format: missing encrypted :contents"
  end
  def test_encrypted_contents_is_string
    d = test_data_copy
    d[:encrypted][:contents] = {}
    assert !valid_format?(d), "data is incorrect format: encrypted contents must be a string"

    d = test_data_copy
    d[:encrypted][:contents] = []
    assert !valid_format?(d) => "data is incorrect format: encrypted contents must be a string"
  end
  def test_missing_encrypted_secret_key
    d = test_data_copy
    d[:encrypted].delete(:secret_key)
    assert !valid_format?(d), "data is incorrect format: missing encrypted :secret_key"
  end
  def test_missing_plaintext_iv
    d = test_data_copy
    d[:plaintext].delete(:iv)
    assert !valid_format?(d), "data is incorrect format: missing plaintext :iv"
  end
  def test_missing_secret_key_hash
    d = test_data_copy
    d[:plaintext].delete(:secret_key_hash)
    assert !valid_format?(d), "data is incorrect format: missing secret key hash"
  end

  def test_open_storage_file
    assert Syde::Vault.open(TEST_STORAGE_FILE)
  end

  def test_empty_data_failure
    assert_raise ArgumentError do
      Syde::Vault.new("")
    end
  end
end
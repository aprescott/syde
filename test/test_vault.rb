class TC_Syde_Vault < Test::Unit::TestCase  
  def setup
    FileUtils.rm(TEST_STORAGE_FILE) if File.exist?(TEST_STORAGE_FILE)
    @vault = Syde::Vault.create("test_password", TEST_STORAGE_FILE)
  end
  
  def tear_down
    FileUtils.rm(TEST_STORAGE_FILE) if File.exist?(TEST_STORAGE_FILE)
  end
  
  def test_initial_contents_empty
    @vault.unlock!("test_password")
    assert @vault.contents.empty?
  end
  
  def test_vault_add
    @vault.unlock!("test_password")
    assert @vault.add("1")
    assert @vault.contents == ["1"]
  end
  
  def test_vault_multiple_add
    @vault.unlock!("test_password")
    assert @vault.add("1", 3, /regex/)
    @vault.contents.each do |e|
      assert [/regex/, 3, "1"].include?(e)
    end
  end
  
  def test_begins_locked
    assert @vault.locked?
  end
  
  def test_non_override_of_storage_file
    File.open(TEST_STORAGE_FILE, "w") do |f|
      f.write "test"
    end
    assert_raise RuntimeError do
      Syde::Vault.create("test_password", TEST_STORAGE_FILE)
    end
  end
  
  def test_unlock_incorrect_password
    assert_raise OpenSSL::Cipher::CipherError, Syde::Errors::PasswordIncorrectError do
      @vault.unlock!("incorrect_password")
    end
    assert @vault.locked?
  end
  
  def test_unlock_correct_password
    @vault.unlock!("test_password")
    assert !@vault.locked?
  end
  
  def test_auto_locks
    assert @vault.locked?
    @vault.unlock("test_password", 1)
    assert !@vault.locked?
    sleep 2
    assert @vault.locked?
  end
  
  def test_instant_lock
    assert @vault.locked?
    @vault.unlock("test_password", 0)
    assert @vault.locked?
  end

  def test_contents_not_overridable
    @vault.unlock!("test_password")
    @vault << "foo"
    assert @vault.contents.last == "foo"
    @vault.contents.last.replace("bar")
    assert @vault.contents.last == "foo"
    assert @vault.contents.last != "bar"
  end
end

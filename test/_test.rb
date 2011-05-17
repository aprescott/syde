require "test/unit"

TEST_STORAGE_FILE = File.expand_path(File.join("", *%w[tmp test_vault]))

require "syde"
require "test_vault"
require "test_storage"
require "test_crypto"

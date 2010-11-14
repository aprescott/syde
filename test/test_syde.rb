require "test/unit"

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), ".."))) unless
    $:.include?(File.join(File.dirname(__FILE__), "..")) || $:.include?(File.expand_path(File.join(File.dirname(__FILE__), "..")))

TEST_STORAGE_FILE = File.expand_path(File.join("", *%w[tmp test_vault]))

require "syde"
require "test/syde/test_vault"
require "test/syde/test_storage"
require "test/syde/test_crypto"
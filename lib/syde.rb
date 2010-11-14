$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "syde/crypto"
require "syde/errors"
require "syde/storage"
require "syde/vault"

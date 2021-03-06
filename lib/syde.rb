# Copyright (c) 2010 Adam Prescott
# Licensed under the MIT license. See LICENSE.

require "openssl"
require "yaml"
require "fileutils"

# http://snippets.dzone.com/posts/show/576
# http://snippets.dzone.com/posts/show/4975

FileUtils.mkdir(File.expand_path("~/.syde")) unless File.exist?(File.expand_path("~/.syde"))

module Syde
  SYDE_VERSION_MAJOR = "0"
  SYDE_VERSION_MINOR = "0"
  SYDE_VERSION_TINY  = "2"

  SYDE_VERSION = [SYDE_VERSION_MAJOR, SYDE_VERSION_MINOR, SYDE_VERSION_TINY].join(".")

  SYDE_VERSION_DATE  = nil
end

require "syde/crypto"
require "syde/errors"
require "syde/storage"
require "syde/vault"

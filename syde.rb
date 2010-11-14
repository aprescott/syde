require "openssl"
require "yaml"
require "fileutils"

# http://snippets.dzone.com/posts/show/576
# http://snippets.dzone.com/posts/show/4975

FileUtils.mkdir(File.expand_path("~/.syde")) unless File.exist?(File.expand_path("~/.syde"))

module Syde
	SYDE_VERSION_MAJOR = "0"
	SYDE_VERSION_MINOR = "0"
	SYDE_VERSION_TINY  = "0"
	
	SYDE_VERSION = [SYDE_VERSION_MAJOR, SYDE_VERSION_MINOR, SYDE_VERSION_TINY].join(".")
	
	SYDE_VERSION_DATE	= nil
end

$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "lib/syde"
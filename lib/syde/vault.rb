module Syde
class Vault
	include Errors
	
	attr_accessor	:plaintext_secret_key
	attr_reader		:file

	def self.open(file = Storage::DefaultStorageFile)
	  file = File.expand_path(file)
	  FileUtils.touch(file) unless File.exist?(file)
	  
		Vault.new(YAML.load_file(file) || "", file)
	end
	
	def self.create(password, file = Storage::DefaultStorageFile)
	  file = File.expand_path(file)
	  
		raise "#{file} contains content -- refusing to override." if File.exist?(file) && File.size(file) > 0
		
		FileUtils.touch(file) unless File.exist?(file)
		
		h = {}
		[:plaintext, :encrypted].each { |e| h[e] = {} }
		
		h[:plaintext][:iv] = Crypto.new_iv
		new_secret_key = Vault.new_secret_key(password, h[:plaintext][:iv])
		encrypted_key = new_secret_key[:encrypted_key]
		hash = new_secret_key[:plaintext_key_hash]
		plaintext_key = new_secret_key[:plaintext_key]
		
		h[:encrypted][:secret_key] = encrypted_key
		h[:plaintext][:secret_key_hash] = hash
		
		h[:encrypted][:contents] = Crypto.encrypt(plaintext_key, h[:plaintext][:iv], YAML.dump([]))
		h[:plaintext][:contents] = []
				
		File.open(file, "w") do |f|
			f << YAML.dump(h)
		end
		
		Vault.new(h, file)
	end
	
	def initialize(data, file)
		@data = data
		@file = file.freeze
				
		raise ArgumentError, "unable to find any stored data." if @data.empty?
		raise ArgumentError, "data is not valid." unless Storage.valid_format?(@data)
	end
	
	def data
    if locked?
      public_data
    else
      internal_data
    end
	end
	
	def public_data
	  public_data = YAML.load(YAML.dump(internal_data))
	  public_data[:plaintext].delete(:contents)
	  public_data
	end
	
	private
	
	def internal_data
	  @data
	end
	
	public
		
	def iv
		internal_data[:plaintext][:iv]
	end
	
	def secret_key_hash
		internal_data[:plaintext][:secret_key_hash]
	end
	
	def decrypt_secret_key(password)
		Crypto.aes(:decrypt, password, iv, internal_data[:encrypted][:secret_key])
	end
	
	def lock
	  internal_data[:encrypted][:contents] = Crypto.encrypt(@plaintext_secret_key, iv, YAML.dump(internal_data[:plaintext][:contents]))
	  internal_data[:plaintext][:contents] = nil
		@plaintext_secret_key = nil
	end
	
	def unlock!(password = nil)
  	raise MissingPasswordError, "no password given." unless password

  	plaintext_secret_key = decrypt_secret_key(password)
  	if Crypto.digest(plaintext_secret_key) != secret_key_hash
  		raise PasswordIncorrectError
  	else
  		@plaintext_secret_key = plaintext_secret_key
  		internal_data[:encrypted][:contents] ||= Crypto.encrypt(@plaintext_secret_key, iv, YAML.dump([]))
  		internal_data[:plaintext][:contents] = YAML.load(Crypto.decrypt(@plaintext_secret_key, iv, internal_data[:encrypted][:contents]))
  	end
	end
	
	def unlock(password = nil, timeout = 5 * 60)
	  return false unless timeout > 0
	  unlock!(password)
    start_locking_timer(timeout)
		true
	end
	
	def start_locking_timer(seconds)
	  Thread.new do
	    sleep seconds
	    self.lock
	  end
	end
	
	def locked?
		if plaintext_secret_key
			false
		else
			true
		end
	end
	
	def plaintext_contents
	  raise AccessError, "vault is locked; unable to access vault contents." if locked?
	  
    YAML.load(YAML.dump(internal_contents))
	end
	
	private
	
	def internal_contents
	  internal_data[:plaintext][:contents]
	end
	
	public
	
	def contents
    if locked?
      public_contents
    else
      plaintext_contents
    end
  end

	def public_contents
	  raise AccessError, "vault is locked; unable to access vault contents." if locked?
	  
	  public_data[:plaintext][:contents]
	end
	
	private
	
	def update_contents(new_content)
    internal_data[:encrypted][:contents] = Crypto.encrypt(@plaintext_secret_key, iv, YAML.dump(internal_contents))

    Storage.write(YAML.dump(public_data), file)
    
    plaintext_contents
	end
	
	public
	
	def contents=(new_content)
	  raise AccessError, "vault is locked; unable to modify vault contents." if locked?
	  
	  internal_contents.replace(new_content)
	  
	  update_contents(new_content)
	end
	
	def add(*contents)
	  raise AccessError, "vault is locked; unable to add content to vault." if locked?
	  
	  contents.each do |content|
	    internal_contents << content
	  end

    update_contents(internal_contents)
	end
	alias_method :<<, :add
	
	def remove(*contents)
	  raise AccessError, "vault is locked; unable to remove content from vault." if locked?
	  
	  contents.each do |content|
	    internal_contents.delete(content)
	  end
	  
	  update_contents(internal_contents)
	end
	
	def status
		locked? ? "locked" : "unlocked"
	end
	
	def inspect
		%Q{#<Vault (#{status})>}
	end
		
	def self.new_secret_key(password, iv)
		plaintext = Crypto.digest(Crypto.random_bytes(4096))
		new_key = Crypto.aes(:encrypt, password, iv, plaintext)
		#? plaintext = nil
		#? GC.start
		{ :encrypted_key => new_key,
		  :plaintext_key_hash => Crypto.digest(plaintext),
		  :plaintext_key => plaintext	}
	end
end
end
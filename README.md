Syde
====

Syde is a *sy*mmetric *d*ata *e*ncryption library written in Ruby, licensed under the MIT license. It provides a saved encrypted data storage under a single password.

# How do I use this thing?

To install from RubyGems:

    gem install syde

To get the source:

    git clone https://github.com/aprescott/syde.git

To run the tests with the source:

    rake test

To contribute:

* Fork it
* Make a new feature branch: `git checkout -b some-new-thing master`
* Hack away and add tests
* Pull request

Basic usage
-----------

    require "syde"

    vault = Syde::Vault.create("password")
    vault #=> #<Vault (locked)>
    vault.unlock!("password")
    vault #=> #<Vault (unlocked)>
    vault.contents #=> []
    vault << "something important"
    vault.contents #=> ["something important"]
    vault.lock
    vault #=> #<Vault (locked)>

### Reopening the vault

When you call Vault.create your vault is saved to disk, in a default location. To reopen the vault using the default location, you can use `Vault.open`. Adding contents to the vault will cause it to be saved automatically, without needing to `Vault#lock`.

### Auto-locking

By default, there is a 5-minute auto-lock timeout period. After 5 minutes has passed since unlocking the vault, the vault will automatically lock itself. It is possible to set the time manually:

    vault.unlock("password", 2 * 60)

will set the timeout period to 2 minutes. Using a non-positive length of time will not unlock the vault. To unlock the vault indefinitely, use `unlock!`.

### Deleting contents of the vault

To delete something in the vault, use `delete`:

    vault << "foo"
    vault.contents
    vault.delete("foo")
    vault.contents

### Modifying contents in-place

    vault.contents #=> ["foo"]
    string = vault.contents.first #=> "foo"
    string.replace("bar")
    vault.contents #=> ["foo"]

Objects in the vault are serialised and then deserialised and as such are not modifiable.

### Available data

To see the data being stored in the vault file, use `data`. When the vault is unlocked, the contents are visible via `data`; otherwise, only the encrypted contents are visible.

### Specifying a different file

By default the file used for vault storage is ~/.syde/storage_file.vault. To change this, when calling `create`, pass a `String` as the second argument, for the filepath to be used.

Some details
------------

The password you give is used to encrypt, using the OpenSSL standard library, a random 4096-bit secret key generated from /dev/urandom. This secret key is then used for the encryption and decryption of the vault contents. When a vault is created it will by default have its information stored in ~/.syde/storage_file.vault. Vault contents, and the secret 4096-bit key are kept in this file in encrypted form only, and never written to the file as plaintext; when the vault is unlocked the plaintext is available to the running application.

Modifying the contents of the .vault file is not recommended, as it will cause Syde::Vault to be unable to open it.

### Vault contents

The contents of a vault are currently a simple Array, and are serialised with YAML before being encrypted. When the vault is opened and unlocked, the ciphertext is decrypted and then deserialised back to Ruby objects.

### Forgotten passwords

If your password is forgotten it's unlikely that you'll be able to retrieve any of the data stored in encrypted form as plaintext.

Tests
-----

`rake test` will run the set of unit tests.

Ruby versions
-------------

Should work without incident on 1.8.7.

TODO/issues
-----------

Fix encoding problems to get 1.9 support.

The intention is to have future versions support storing data associated to keys, allowing you to use

    vault.add :password => "important"

This can be done with the current design by setting the contents of the vault to be just a hash.

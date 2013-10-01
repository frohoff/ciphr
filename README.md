# Ciphr

Ciphr is a CLI tool for performing and composing encoding, decoding, encryption,
decryption, hashing, and other various operations on streams of data. It takes
provided data, file data, or data from stdin, and executes a pipeline of 
functions on the data stream, writing the resulting data to stdout. It was 
designed primarily for use in the information security domain, mostly for quick, 
casual data manipulation for forensics, penetration testing, or capture-to-flag
events; it likely could have other unforseen uses, but should be presumed to be
very experimental and no effort was made to make included cryptographic 
functions robust against attacks (timing attacks, etc), so it is recommended not
to use them in any on-line security mechanisms.

## Installation

Must be cloned and installed until it gets into rubygems.org after being cleaned
up

Requires bundler to be installed (`gem install bundler`)

```shell
git clone https://github.com/frohoff/ciphr.git
cd ciphr
bundle install
rake install
```

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

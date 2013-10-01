# Ciphr

Ciphr is a CLI tool for performing and composing encoding, decoding, encryption,
decryption, hashing, and other various operations on streams of data. It takes
provided data, file data, or data from stdin, and executes a pipeline of 
functions on the data stream, writing the resulting data to stdout. It was 
designed primarily for use in the information security domain, mostly for quick, 
casual data manipulation for forensics, penetration testing, or capture-to-flag
events; it likely could have other unforseen uses, but should be presumed to be
an experimental toy as no effort was made to make included cryptographic 
functions robust against attacks (timing attacks, etc), and it is recommended 
not to use any included functions in any on-line security mechanisms.

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

See examples below to get a feel until I have some time to write up more general
usage instructions.

## Examples

```shell
$ ciphr '"abc"'
abc
$ ciphr '"abc"|hex'
616263
$ ciphr '"abc"|hex|~hex'
abc
$ ciphr '0x616263'
abc
$ ciphr '0x616263|hex'
616263
$ ciphr '0b10101010|bin'
10101010
$ ciphr '0b10101010|hex'
aa
$ ciphr '255|hex'
ff
$ ciphr '65'
A
$ ciphr '""|md5|hex'
d41d8cd98f00b204e9800998ecf8427e
$ echo -n "" | ciphr 'md5|hex'
d41d8cd98f00b204e9800998ecf8427e
$ ciphr '"abc"|sha1|hex'
a9993e364706816aba3e25717850c26c9cd0d89d
$ echo -n "abc" | ciphr 'sha1' | xxd -ps
a9993e364706816aba3e25717850c26c9cd0d89d0a
$ echo -n "abc" | ciphr 'xor("abc")|hex'
000000
$ echo -n "abc" | ciphr 'xor(0x01)|hex'
606362
$ echo -n "abc" | ciphr 'xor(0x01)'
`cb
$ echo -n "abc" | ciphr 'xor(0x020304)'
cag
$ echo -n "abc" | ciphr 'aes128cbc("super secret key")|hex'
8ad54a1a16c4963a231beb69e0888a8f
$ echo -n "abc" | ciphr 'aes128cbc("super secret key")|hex|~hex|~aes128cbc("super secret key")'
abc
```

## Developing
Check out code:
```shell
git clone https://github.com/frohoff/ciphr.git
cd ciphr
```

Run command from exploded gem/project directory:
```shell
ruby -Ilib bin/ciphr [args]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

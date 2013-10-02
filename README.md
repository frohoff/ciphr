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

```shell
$ ciphr -h -v
Usage: ciphr [options] [spec]
    -h, --help
    -v, --verbose
    -n, --no-newline
Available Functions:
	cat, noop (input)
	md2 (input)
	md4 (input)
	md5 (input)
	sha (input)
	sha1 (input)
	sha224 (input)
	sha256 (input)
	sha384 (input)
	sha512 (input)
	hmacmd2 (input, key)
	hmacmd4 (input, key)
	hmacmd5 (input, key)
	hmacsha (input, key)
	hmacsha1 (input, key)
	hmacsha224 (input, key)
	hmacsha256 (input, key)
	hmacsha384 (input, key)
	hmacsha512 (input, key)
	b64, base64 (input)
	hex, hexidecimal, b16, base16 (input)
	dec, decimal, b10, base10 (input)
	oct, octal, b8, base8 (input)
	bin, binary, b2, b2 (input)
	aes128cbc (input, key)
	aes128cfb (input, key)
	aes128cfb1 (input, key)
	aes128cfb8 (input, key)
	aes128ecb (input, key)
	aes128ofb (input, key)
	aes192cbc (input, key)
	aes192cfb (input, key)
	aes192cfb1 (input, key)
	aes192cfb8 (input, key)
	aes192ecb (input, key)
	aes192ofb (input, key)
	aes256cbc (input, key)
	aes256cfb (input, key)
	aes256cfb1 (input, key)
	aes256cfb8 (input, key)
	aes256ecb (input, key)
	aes256ofb (input, key)
	aes128 (input, key)
	aes192 (input, key)
	aes256 (input, key)
	bf (input, key)
	bfcbc (input, key)
	bfcfb (input, key)
	bfecb (input, key)
	bfofb (input, key)
	cast (input, key)
	castcbc (input, key)
	cast5cbc (input, key)
	cast5cfb (input, key)
	cast5ecb (input, key)
	cast5ofb (input, key)
	des (input, key)
	descbc (input, key)
	descfb (input, key)
	descfb1 (input, key)
	descfb8 (input, key)
	desecb (input, key)
	desede (input, key)
	desedecbc (input, key)
	desedecfb (input, key)
	desedeofb (input, key)
	desede3 (input, key)
	desede3cbc (input, key)
	desede3cfb (input, key)
	desede3cfb1 (input, key)
	desede3cfb8 (input, key)
	desede3ofb (input, key)
	desofb (input, key)
	des3 (input, key)
	desx (input, key)
	desxcbc (input, key)
	rc2 (input, key)
	rc240cbc (input, key)
	rc264cbc (input, key)
	rc2cbc (input, key)
	rc2cfb (input, key)
	rc2ecb (input, key)
	rc2ofb (input, key)
	rc4 (input, key)
	rc440 (input, key)
	rc5 (input, key)
	rc5cbc (input, key)
	rc5cfb (input, key)
	rc5ecb (input, key)
	rc5ofb (input, key)
	seed (input, key)
	seedcbc (input, key)
	seedcfb (input, key)
	seedecb (input, key)
	seedofb (input, key)
	blowfish (input, key)
```

## Examples

```shell
$ ciphr '"abc"'
abc
$ ciphr '"abc"|hex'
616263
$ ciphr '"abc"|hex|~hex'
abc
$ ciphr '"616263"|~hex'
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

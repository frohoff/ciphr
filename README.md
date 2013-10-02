# Ciphr

Ciphr is a CLI tool for performing and composing encoding, decoding, encryption,
decryption, hashing, and other various operations on streams of data. It takes
provided data, file data, or data from stdin, and executes a pipeline of 
functions on the data stream, writing the resulting data to stdout. It was 
designed primarily for use in the information security domain, mostly for quick
or casual data manipulation for forensics, penetration testing, or 
capture-the-flag events; it likely could have other unforseen uses, but should 
be presumed to be an experimental toy as no effort was made to make included 
cryptographic functions robust against attacks (timing attacks, etc), and it is 
recommended not to use any included functions in any on-line security 
mechanisms.

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
Available Functions: aliases ([args])
	cat, noop (input)
	b2, base2, bin, binary (input)
	b8, base8, oct, octal (input)
	b10, base10, dec, decimal (input)
	b16, base16, hex, hexidecimal (input)
	b64, base64 (input)
	and (input, input)
	or (input, input)
	xor (input, input)
	md2 (input)
	md4 (input)
	md5 (input)
	sha (input)
	sha1 (input)
	sha224 (input)
	sha256 (input)
	sha384 (input)
	sha512 (input)
	hmac-md2, hmacmd2 (input, key)
	hmac-md4, hmacmd4 (input, key)
	hmac-md5, hmacmd5 (input, key)
	hmac-sha, hmacsha (input, key)
	hmac-sha1, hmacsha1 (input, key)
	hmac-sha224, hmacsha224 (input, key)
	hmac-sha256, hmacsha256 (input, key)
	hmac-sha384, hmacsha384 (input, key)
	hmac-sha512, hmacsha512 (input, key)
	aes-128-cbc, aes128cbc (input, key)
	aes-128-cfb, aes128cfb (input, key)
	aes-128-cfb1, aes128cfb1 (input, key)
	aes-128-cfb8, aes128cfb8 (input, key)
	aes-128-ecb, aes128ecb (input, key)
	aes-128-ofb, aes128ofb (input, key)
	aes-192-cbc, aes192cbc (input, key)
	aes-192-cfb, aes192cfb (input, key)
	aes-192-cfb1, aes192cfb1 (input, key)
	aes-192-cfb8, aes192cfb8 (input, key)
	aes-192-ecb, aes192ecb (input, key)
	aes-192-ofb, aes192ofb (input, key)
	aes-256-cbc, aes256cbc (input, key)
	aes-256-cfb, aes256cfb (input, key)
	aes-256-cfb1, aes256cfb1 (input, key)
	aes-256-cfb8, aes256cfb8 (input, key)
	aes-256-ecb, aes256ecb (input, key)
	aes-256-ofb, aes256ofb (input, key)
	aes128 (input, key)
	aes192 (input, key)
	aes256 (input, key)
	bf (input, key)
	bf-cbc, bfcbc (input, key)
	bf-cfb, bfcfb (input, key)
	bf-ecb, bfecb (input, key)
	bf-ofb, bfofb (input, key)
	cast (input, key)
	cast-cbc, castcbc (input, key)
	cast5-cbc, cast5cbc (input, key)
	cast5-cfb, cast5cfb (input, key)
	cast5-ecb, cast5ecb (input, key)
	cast5-ofb, cast5ofb (input, key)
	des (input, key)
	des-cbc, descbc (input, key)
	des-cfb, descfb (input, key)
	des-cfb1, descfb1 (input, key)
	des-cfb8, descfb8 (input, key)
	des-ecb, desecb (input, key)
	des-ede, desede (input, key)
	des-ede-cbc, desedecbc (input, key)
	des-ede-cfb, desedecfb (input, key)
	des-ede-ofb, desedeofb (input, key)
	des-ede3, desede3 (input, key)
	des-ede3-cbc, desede3cbc (input, key)
	des-ede3-cfb, desede3cfb (input, key)
	des-ede3-cfb1, desede3cfb1 (input, key)
	des-ede3-cfb8, desede3cfb8 (input, key)
	des-ede3-ofb, desede3ofb (input, key)
	des-ofb, desofb (input, key)
	des3 (input, key)
	desx (input, key)
	desx-cbc, desxcbc (input, key)
	rc2 (input, key)
	rc2-40-cbc, rc240cbc (input, key)
	rc2-64-cbc, rc264cbc (input, key)
	rc2-cbc, rc2cbc (input, key)
	rc2-cfb, rc2cfb (input, key)
	rc2-ecb, rc2ecb (input, key)
	rc2-ofb, rc2ofb (input, key)
	rc4 (input, key)
	rc4-40, rc440 (input, key)
	rc5 (input, key)
	rc5-cbc, rc5cbc (input, key)
	rc5-cfb, rc5cfb (input, key)
	rc5-ecb, rc5ecb (input, key)
	rc5-ofb, rc5ofb (input, key)
	seed (input, key)
	seed-cbc, seedcbc (input, key)
	seed-cfb, seedcfb (input, key)
	seed-ecb, seedecb (input, key)
	seed-ofb, seedofb (input, key)
	blowfish (input, key)
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

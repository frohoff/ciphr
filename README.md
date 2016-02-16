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

```console
$ ciphr '"abc"'
abc
$ ciphr '"abc"' hex
616263
$ ciphr '"abc"' hex ~hex
abc
$ ciphr '"616263"' ~hex
abc
$ ciphr 0x616263
abc
$ ciphr 0x616263 hex
616263
$ ciphr 0b10101010 bin
10101010
$ ciphr 0b10101010 hex
aa
$ ciphr 255 hex
ff
$ ciphr 65
A
$ ciphr '""' md5 hex
d41d8cd98f00b204e9800998ecf8427e
$ echo -n "" | ciphr md5 hex
d41d8cd98f00b204e9800998ecf8427e
$ ciphr '"abc"' sha1 hex
a9993e364706816aba3e25717850c26c9cd0d89d
$ echo -n "abc" | ciphr sha1 | xxd -ps
a9993e364706816aba3e25717850c26c9cd0d89d
$ echo -n "abc" | ciphr 'xor["abc"] hex'
000000
$ echo -n "abc" | ciphr xor[0x01] hex
606362
$ echo -n "abc" | ciphr xor[0x01]
`cb
$ echo -n "abc" | ciphr xor[0x020304]
cag
$ echo -n "abc" | ciphr 'aes128cbc["super secret key"] hex'
1e98110410ea0aa59a31ddc462d720d07e1e01268e405ee9fba29b3f91752e0c
$ echo -n "abc" | ciphr 'aes128cbc["super secret key"] hex ~hex ~aes128cbc["super secret key"]'
abc
$ ciphr @/etc/hosts
127.0.0.1       localhost
$ ciphr @/etc/hosts md5 hex
8f4491642052129e98cc211b4f32d9c5
$ ciphr @/etc/hosts xor[0x01]
036/1/1/mnb`minru
$ ciphr @/etc/hosts aes-128-cbc[@/etc/hosts] hex
3033c8627781ae2152d0b25f1acd3397161d5e8462164716539502ad908163e13eec1a73ee03ba89a877ac49fd04d7a3
$ ciphr @/etc/hosts aes-128-cbc[@/etc/hosts] ~aes-128-cbc[@/etc/hosts]
127.0.0.1       localhost
$ ciphr @/etc/hosts aes-128-cbc[0xdeadbeefdeadbeefdeadbeefdeadbeef] hex
92638d3f10a303938b48bd4a108744ed4216c99b005ddc19cce752af53ef089be1e43a446fda55c4e76036f31612459f
$ ciphr @/etc/hosts aes-128-cbc[0xdeadbeefdeadbeefdeadbeefdeadbeef] ~aes-128-cbc[0xdeadbeefdeadbeefdeadbeefdeadbeef]
127.0.0.1       localhost
```

## Installation

#### Rubygems

```shell
$ gem install ciphr
Fetching: ciphr-0.0.1.gem (100%)
Successfully installed ciphr-0.0.1
Parsing documentation for ciphr-0.0.1
Installing ri documentation for ciphr-0.0.1
Done installing documentation for ciphr after 2 seconds
1 gem installed
```

#### Source

Requires bundler to be installed (`gem install bundler`)

```shell
git clone https://github.com/frohoff/ciphr.git
cd ciphr
bundle install
bundle exec rake install
```

## Usage

```shell
$ ciphr -v -h
Usage: ciphr [options] [spec]
    -h, --help
    -v, --verbose
    -n, --no-newline
    -N, --newline
    -x, --xargs-mode
    -0, --null
Available Functions: aliases ([args])
  md4 (input)
  md5 (input)
  sha (input)
  sha1 (input)
  sha224 (input)
  sha256 (input)
  sha384 (input)
  sha512 (input)
  hmac-md4, hmacmd4 (input, key)
  hmac-md5, hmacmd5 (input, key)
  hmac-sha, hmacsha (input, key)
  hmac-sha1, hmacsha1 (input, key)
  hmac-sha224, hmacsha224 (input, key)
  hmac-sha256, hmacsha256 (input, key)
  hmac-sha384, hmacsha384 (input, key)
  hmac-sha512, hmacsha512 (input, key)
  aes-128-cbc, aes128cbc (input, key)
  aes-128-cbc-hmac-sha1, aes128cbchmacsha1 (input, key)
  aes-128-cbc-hmac-sha256, aes128cbchmacsha256 (input, key)
  aes-128-cfb, aes128cfb (input, key)
  aes-128-cfb1, aes128cfb1 (input, key)
  aes-128-cfb8, aes128cfb8 (input, key)
  aes-128-ctr, aes128ctr (input, key)
  aes-128-ecb, aes128ecb (input, key)
  aes-128-ofb, aes128ofb (input, key)
  aes-128-xts, aes128xts (input, key)
  aes-192-cbc, aes192cbc (input, key)
  aes-192-cfb, aes192cfb (input, key)
  aes-192-cfb1, aes192cfb1 (input, key)
  aes-192-cfb8, aes192cfb8 (input, key)
  aes-192-ctr, aes192ctr (input, key)
  aes-192-ecb, aes192ecb (input, key)
  aes-192-ofb, aes192ofb (input, key)
  aes-256-cbc, aes256cbc (input, key)
  aes-256-cbc-hmac-sha1, aes256cbchmacsha1 (input, key)
  aes-256-cbc-hmac-sha256, aes256cbchmacsha256 (input, key)
  aes-256-cfb, aes256cfb (input, key)
  aes-256-cfb1, aes256cfb1 (input, key)
  aes-256-cfb8, aes256cfb8 (input, key)
  aes-256-ctr, aes256ctr (input, key)
  aes-256-ecb, aes256ecb (input, key)
  aes-256-ofb, aes256ofb (input, key)
  aes-256-xts, aes256xts (input, key)
  aes128 (input, key)
  aes192 (input, key)
  aes256 (input, key)
  bf (input, key)
  bf-cbc, bfcbc (input, key)
  bf-cfb, bfcfb (input, key)
  bf-ecb, bfecb (input, key)
  bf-ofb, bfofb (input, key)
  camellia-128-cbc, camellia128cbc (input, key)
  camellia-128-cfb, camellia128cfb (input, key)
  camellia-128-cfb1, camellia128cfb1 (input, key)
  camellia-128-cfb8, camellia128cfb8 (input, key)
  camellia-128-ecb, camellia128ecb (input, key)
  camellia-128-ofb, camellia128ofb (input, key)
  camellia-192-cbc, camellia192cbc (input, key)
  camellia-192-cfb, camellia192cfb (input, key)
  camellia-192-cfb1, camellia192cfb1 (input, key)
  camellia-192-cfb8, camellia192cfb8 (input, key)
  camellia-192-ecb, camellia192ecb (input, key)
  camellia-192-ofb, camellia192ofb (input, key)
  camellia-256-cbc, camellia256cbc (input, key)
  camellia-256-cfb, camellia256cfb (input, key)
  camellia-256-cfb1, camellia256cfb1 (input, key)
  camellia-256-cfb8, camellia256cfb8 (input, key)
  camellia-256-ecb, camellia256ecb (input, key)
  camellia-256-ofb, camellia256ofb (input, key)
  camellia128 (input, key)
  camellia192 (input, key)
  camellia256 (input, key)
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
  rc4-hmac-md5, rc4hmacmd5 (input, key)
  seed (input, key)
  seed-cbc, seedcbc (input, key)
  seed-cfb, seedcfb (input, key)
  seed-ecb, seedecb (input, key)
  seed-ofb, seedofb (input, key)
  aes-128-ccm, aes128ccm (input, key)
  aes-128-gcm, aes128gcm (input, key)
  aes-192-ccm, aes192ccm (input, key)
  aes-192-gcm, aes192gcm (input, key)
  aes-256-ccm, aes256ccm (input, key)
  aes-256-gcm, aes256gcm (input, key)
  blowfish (input, key)
  id-aes128-ccm, idaes128ccm (input, key)
  id-aes128-gcm, idaes128gcm (input, key)
  id-aes128-wrap, idaes128wrap (input, key)
  id-aes192-ccm, idaes192ccm (input, key)
  id-aes192-gcm, idaes192gcm (input, key)
  id-aes192-wrap, idaes192wrap (input, key)
  id-aes256-ccm, idaes256ccm (input, key)
  id-aes256-gcm, idaes256gcm (input, key)
  id-aes256-wrap, idaes256wrap (input, key)
  id-smime-alg-cms3deswrap, idsmimealgcms3deswrap (input, key)
  b2, base2, bin, binary (input)
  b8, base8, oct, octal (input)
  b16, base16, hex, hexidecimal (input)
  b32, base32, b32-std, base32-std (input)
  b64, base64, b64-psq, b64-std, base64-psq, base64-std (input)
  b64-ps, b64-utf7, base64-ps, base64-utf7 (input)
  b64-ph, b64-file, base64-ph, base64-file (input)
  b64-hu, b64-url, base64-hu, base64-url (input)
  b64-duh, b64-yui, base64-duh, base64-yui (input)
  b64-dh, b64-xml-name, base64-dh, base64-xml-name (input)
  b64-uc, b64-xml-id, base64-uc, base64-xml-id (input)
  b64-uh, b64-prog-id-1, base64-uh, base64-prog-id-1 (input)
  b64-du, b64-prog-id-2, base64-du, base64-prog-id-2 (input)
  b64-xh, b64-regex, base64-xh, base64-regex (input)
  r2, rad2, radix2 (input)
  r3, rad3, radix3 (input)
  r4, rad4, radix4 (input)
  r5, rad5, radix5 (input)
  r6, rad6, radix6 (input)
  r7, rad7, radix7 (input)
  r8, rad8, radix8 (input)
  r9, rad9, radix9 (input)
  r10, rad10, radix10 (input)
  r11, rad11, radix11 (input)
  r12, rad12, radix12 (input)
  r13, rad13, radix13 (input)
  r14, rad14, radix14 (input)
  r15, rad15, radix15 (input)
  r16, rad16, radix16 (input)
  r17, rad17, radix17 (input)
  r18, rad18, radix18 (input)
  r19, rad19, radix19 (input)
  r20, rad20, radix20 (input)
  r21, rad21, radix21 (input)
  r22, rad22, radix22 (input)
  r23, rad23, radix23 (input)
  r24, rad24, radix24 (input)
  r25, rad25, radix25 (input)
  r26, rad26, radix26 (input)
  r27, rad27, radix27 (input)
  r28, rad28, radix28 (input)
  r29, rad29, radix29 (input)
  r30, rad30, radix30 (input)
  r31, rad31, radix31 (input)
  r32, rad32, radix32 (input)
  r33, rad33, radix33 (input)
  r34, rad34, radix34 (input)
  r35, rad35, radix35 (input)
  r36, rad36, radix36 (input)
  deflate (input)
  gzip, gz (input)
  and-trunc (input, input)
  or-trunc (input, input)
  xor-trunc (input, input)
  and (input, input)
  or (input, input)
  xor (input, input)
  not (input)
  url, uri, cgi (input)
  cat, catenate (input)
  repack (input, ch1, ch2)
  tr, translate (input, ch1, ch2)
  repl, replace (input, search, replace)
  rc4-ruby (input, key)
```

## Developing
Check out code:
```shell
git clone https://github.com/frohoff/ciphr.git
cd ciphr
```

Run command from exploded gem/project directory:
```shell
bundle exec ruby -Ilib bin/ciphr [args]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

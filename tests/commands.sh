cat | while read line; do subline=`echo $line | sed -r "s/ciphr/bundle exec ruby -Ilib bin\/ciphr/g"`; echo '$' $line; eval "$subline"; done << EOF
ciphr '"abc"'
ciphr '"abc"' hex
ciphr '"abc"' hex ~hex
ciphr '"616263"' ~hex
ciphr 0x616263
ciphr 0x616263 hex
ciphr 0b10101010 bin
ciphr 0b10101010 hex
ciphr 255 hex
ciphr 65
ciphr '""' md5 hex
echo -n "" | ciphr md5 hex
ciphr '"abc"' sha1 hex
echo -n "abc" | ciphr sha1 | xxd -ps
echo -n "abc" | ciphr 'xor["abc"] hex'
echo -n "abc" | ciphr xor[0x01] hex
echo -n "abc" | ciphr xor[0x01]
echo -n "abc" | ciphr xor[0x020304]
echo -n "abc" | ciphr 'aes128cbc["super secret key"] hex'
echo -n "abc" | ciphr 'aes128cbc["super secret key"] hex ~hex ~aes128cbc["super secret key"]'
ciphr @/etc/hosts
ciphr @/etc/hosts md5 hex
ciphr @/etc/hosts xor[0x01]
ciphr @/etc/hosts aes-128-cbc[@/etc/hosts]
ciphr @/etc/hosts aes-128-cbc[@/etc/hosts] hex
ciphr @/etc/hosts aes-128-cbc[@/etc/hosts] ~aes-128-cbc[@/etc/hosts]
ciphr @/etc/hosts aes-128-cbc[0xdeadbeefdeadbeefdeadbeefdeadbeef] hex
ciphr @/etc/hosts aes-128-cbc[0xdeadbeefdeadbeefdeadbeefdeadbeef] ~aes-128-cbc[0xdeadbeefdeadbeefdeadbeefdeadbeef]
EOF

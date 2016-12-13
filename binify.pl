#!/usr/bin/perl
# binify
#
# passed a file, it will output binary data that represents the file.
# in one long stream
#
# passed binary data, it will convert to raw data...
#
# ./binify.pl sample.jpg > sample.txt
# cat sample.txt
# 001000110010000100101111011101010111001101110010001011110110001001101001
# 01101110001011110111000001100101011100100110110000001010
#
# ./binify.pl < sample.txt > sample.jpg
#
# a second command line arg can be used to say wrap after x characters
# remember that x characters is x * 8 columns
#
# You can also run without arguments and past data, hitting ^D when finished
# 
#
$wrap = $ARGV[1]?$ARGV[1]:9;
if ( -e $ARGV[0]) {
  open(BIN, "$ARGV[0]");
  @data = <BIN>;
  close(BIN);
  my $i = 1;
  for $line (@data) {
    for $char (split '', $line) {
      print unpack("B*", $char);
      if ($i % $wrap == 0) {
        print "\n";
      }
      $i++;
    }
  }
  print "\n";
} else {
  @data = <STDIN>;
  while ($data[0]) {
    push @array, substr($data[0], 0, 8, '');
  }
  for (@array) { 
    if (/^[01]{8}$/) {
      print pack('B8', $_) 
    }
  }
}
print "\n";

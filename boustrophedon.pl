#!/usr/bin/perl
# bou·stro·phe·don
# ˌbo͞ostrəˈfēdn
# adjective & adverb
# (of written words) from right to left and from left to right in alternate lines.
#
#  ./boustrophedon.pl file
#
#  From a discuussion on the dc-stuff mailing list many years back
# about being able to reverse every other line.
#
#  Here is the result.  Easy, yes.
#
while (<>) {
  $i++;
  chomp;
  if ($i % 2 == 0) {
    $data = reverse $_;
    print "$data\n";
  } else {
    print "$_\n";
  }
}

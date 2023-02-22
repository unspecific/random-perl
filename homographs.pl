#!/usr/bin/perl -w

binmode(STDOUT, ':utf8');
binmode(STDOUT, ":encoding(UTF-8)");
my $used;

for my $x (0..255) {
  my $pre = sprintf("%02X", $x);
  for my $y (0..255) {
    my $post = sprintf("%02X", $y);
    my $uni = chr($x . $y);
    my $unim = $uni;
    next if ($uni =~ /[^\p{L}]/); # removed characters we don't need right now
    $unim .= "^L" if ($uni =~ /\p{L}/); # Letter
    $unim .= "^M" if ($uni =~ /\p{M}/); # accents, modifers to be added to another character
    $unim .= "^Z" if ($uni =~ /\p{Z}/); # whitespace character
    $unim .= "^S" if ($uni =~ /\p{S}/); # Symbol character
    $unim .= "^C" if ($uni =~ /\p{C}/); # Control character
    $unim .= "^P" if ($uni =~ /\p{P}/); # punctuation character
    $unim .= "^N" if ($uni =~ /\p{N}/); # Number character
    $used++;
    # print "unicode of $pre$post is $uni\n";
    #print "\n$x |" if ($used % 8 == 0);
    print "$pre$post, $uni\n";
    #my $format = "@|||||| - @|||||| %%";
    #$^A = "";
    #formline($format, $pre . $post, $uni);
    #print $^A;
  }
}
print "\n$used characters available\n";

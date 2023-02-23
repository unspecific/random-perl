#!/usr/bin/perl -w
use strict;
use warnings;
use Imager;
use Data::Dump qw(dump);

my $DEBUG = 1;


# initial testing of comparing images
# Will use this process to create a config that has how much alike each of the
# letters are the most alike for testing strings

binmode(STDOUT, ':utf8');
binmode(STDOUT, ":encoding(UTF-8)");
my $used;
my %data;
my $saved;
my $generated;

my $xsize = 70;
my $ysize = 100;
my $text_size = 120;
# my $font_filename = '/usr/share/fonts/truetype/ubuntu/UbuntuMono-R.ttf';
my $font_filename = '/usr/share/fonts/truetype/freefont/FreeMono.ttf';


# generate list of characters to test
for my $x (0..1) {
  my $pre = sprintf("%02X", $x);
  for my $y (0..255) {
    my $post = sprintf("%02X", $y);
    my $uni = chr($x . $y);
    next if ($uni =~ /[^\p{L}]/); # removed characters we don't need right now
                                  # Specifically only allow "Letters" to be added
    # next if ($uni =~ /\p{Ea=W}/); # remove wide characters
    $used++;
    print STDERR "$pre$post, $uni\n" if ($DEBUG > 5);
    $data{'chars'}{"$pre:$post"} = $uni;
  }
}
print "\n$used characters available\n";

for my $origHex (sort keys %{$data{'chars'}}) {
  my $origUnicode = $data{'chars'}{$origHex};
  print STDERR "Starting with $origUnicode\n" if ($DEBUG);
  for my $compHex (sort keys %{$data{'chars'}}) {
    my $compUnicode = $data{'chars'}{$compHex};
    my $accuracy = &compare($origUnicode, $compUnicode);
    $data{'accuracy'}{$origHex}{$compHex} = $accuracy;
  }
}

print "$saved images saved\n" if ($DEBUG);

print STDERR dump(\%data) if ($DEBUG);


sub compare {
  my ($origTxt, $compTxt) = @_;
  my $origImage;
  my $compImage;
  if ($data{'img'}{$origTxt}) {
    $origImage = $data{'img'}{$origTxt};
    $saved++;
  } else {
    $origImage = &generateImage($origTxt);
    $data{'img'}{$origTxt} = $origImage;
    $generated++;
  }
  if ($data{'img'}{$compTxt}) {
    $compImage = $data{'img'}{$compTxt};
    $saved++;
  } else {
    $compImage = &generateImage($compTxt);
    $data{'img'}{$compTxt} = $compImage;
    $generated++;
  }

  my $diff = $origImage->difference(other=>$compImage);
  if ($DEBUG > 5) {
    $origImage->write(file=>"$origTxt-orig1.png", type=>'png')
       or die "Cannot write: ",$origImage->errstr;
    $compImage->write(file=>"$compTxt-comp1.png", type=>'png')
      or die "Cannot write: ",$compImage->errstr;
    $diff->write(file=>"diff-$origTxt-$compTxt.png", type=>'png')
      or die "Cannot write: ",$diff->errstr;
  }

  for my $x (1..$xsize - 1) {
    for my $y (1..$ysize - 1) {
      my $colors = $diff->getpixel(x=> $x , y=> $y );
      my $curColor = $colors->rgba();
      print STDERR "$origTxt vs $compTxt: $x,$y: $curColor\n" if ($DEBUG > 8);
      $data{'total'}++;
      if ($curColor == 0) {
        $data{'match'}++;
      } else {
        $data{'diff'}++;
      }
    }
  }

  $data{'diff'} = 0 if (!$data{'diff'});
  my $accuracy = sprintf("%.6f", ($data{'diff'} / $data{'total'}) * 100);
  if ($DEBUG > 5) {
    $origImage->write(file=>"$origTxt-orig.png", type=>'png')
       or die "Cannot write: ",$origImage->errstr;
    $compImage->write(file=>"$compTxt-comp.png", type=>'png')
      or die "Cannot write: ",$compImage->errstr;
    print STDERR "$origTxt vs $compTxt: $accuracy\n" if ($DEBUG > 2);
  }
  return($accuracy);
}

sub generateImage {
  my($text) = @_;
  my $image = Imager->new(xsize => $xsize, ysize => $ysize);
  my $font = Imager::Font->new(file=>$font_filename)
    or die "Cannot load $font_filename: ", Imager->errstr;

  $font->align(string => $text,
     size => $text_size,
     color => 'white',
     x => 10,
     y => $image->getheight/2,
     halign => 'left',
     valign => 'center',
     image => $image);

  return $image;
}

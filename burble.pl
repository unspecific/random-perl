#!/usr/bin/perl
#---------------------------------------
#   Writen by MadHat (madhat@unspecific.com)
# http://www.unspecific.com/
#
# burble.pl
# This is another app that stemmed from a discussion on dc-stuff
# Blame 'chuck
# It reads standard mbox file and will randomize phrases
# pull data from websites and write a new email as the person
# specificed on the command line.  Used to gain knowledge
# of peoples inner workings.  Has been know ot piss people off,
# make people cry and/or unscribe.
#
# burble - 0.2 - by: MadHat<madhat@unspecific.com>
# Usage:
#   burble -e <email> [-f <date>] [-t <date>] [-v] [-n#] /path/to/mbox
# 
# Required:
#   -e  From address to 'burble' the messages from
# 
# Recomended:
#   -f  From Date mm/dd/yy[yy]
#   -t  To Date mm/dd/yy[yy]
# 
# Optional:
#   -v  Verbose output
#   -n  number of sentences per paragraph (default 10)
# 
# Not Recomended:
#   -D  Debug level 1-5
# 
#
# Copyright (c) 2001-2002, MadHat (madhat@unspecific.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the distribution.
#   * Neither the name of MadHat Productions nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#---------------------------------------
use Getopt::Std;
use Date::Manip;
use Mail::MboxParser;
use LWP::Simple;
local ($opt_L, $opt_N, $opt_G);
$VERSION = '0.2';

getopts('D:e:f:hn:t:v');
if ($opt_D) { $opt_v = 1; }

if ( !($opt_e) or $opt_h ) { &usage }

$opt_n = 10 unless ($opt_n);
$opt_t = 'today' unless ($opt_t);
$opt_f = 'Dec 31, 1969' unless ($opt_f);
print "$opt_f - $opt_t\n" if ($opt_v);
$date1 = &ParseDate("$opt_f 00:00:00");
$date2 = &ParseDate("$opt_t 23:59:59");
$mailbox = $ARGV[0];
if ($mailbox =~ /^http\:/) {
  print "Using LWP to fect mailbox\n" if ($opt_v);
  eval {
    if ($mailbox =~ /gz$/) {
      $tmpfile = "/tmp/.count" . time . ".gz";
    } else {
      $tmpfile = "/tmp/.count" . time;
    }
    mirror($mailbox, $tmpfile);
    $tmpbox = 1;
    $mailbox = $tmpfile;
  }
}
if ( ! -e $mailbox ) {
  print "There appears to be a problem.  Mailbox not found\n";
  exit;
}
if ($mailbox =~ /\.gz$/) {
  print "Decompresing mailbox\n" if ($opt_v);
  $gzip = `which gunzip 2>/dev/null`;
  if ( !$gzip ) {
    print "Unable to find gunzip to decompress file.\n" if ($opt_v);
    $gzip = `which gzip 2>/dev/null`;
    if ( !$gzip ) {
      print "Unable to find gzip to decompress file.\n" if ($opt_v);
      print "ERROR: Unable to decompress mailbox.\n";
      exit;
    }
  }
  chomp $gzip;
  `$gzip -d $mailbox`;
  $mailbox =~ s/\.gz$//;
}
print "Opening mailbox $mailbox\n" if ($opt_v);
$mbx = Mail::MboxParser->new($mailbox);
$mbx->make_index;
$msgc = 0;
print "Evaluating messages\n" if ($opt_v);
MESSAGE: for $msg ($mbx->get_messages) {
  printf STDERR '-' x 72 . "\nMSG Num: %6.5d\nMSG Start Pos: %10.10d\n", 
    $msgc, $mbx->get_pos($msgc) . "\n" if ($opt_D);
  my $lines = $new_lines = $html = $toppost = $quotes = $footer = $PGP = $PGPSig = 0;
  $date = $msg->header->{'date'};
  $date3 = &ParseDate($date);
  $start = &Date_Cmp($date1,$date3);
  $end = &Date_Cmp($date2,$date3);
  print STDERR "Date_Cmp: $date1 < $date3 > $date2\n" if ($opt_D > 1);
  print STDERR "Date_Cmp: $start <= 0 => $end\n" if ($opt_D > 1);
  if ( $start <= 0 and $end >= 0) {
    printf STDERR "Matched MSG Num: %6.5d\n", $msgc if ($opt_D);
    $email = $msg->from->{'email'};
    print STDERR "From: $email\n" if ($opt_D > 1);
    $email =~ tr/[A-Z]/[a-z]/;
    $email =~ s/[\<\>]//g;
    $email =~ s/ \(.+\)$//g;
    $email =~ s/^\".+\"//;
    if ($email !~ /$opt_e/i) {
      print STDERR "Not the right person\n" if ($opt_D);
      $msgc++;
      next MESSAGE;
    }
    my $sub = $msg->header->{'subject'};
    for my $entry (split ' ', $sub) {
      next if ($entry =~ /^re\:?$/i);
      next if ($entry =~ /^fwd?\:?$/i);
      next if ($entry =~ /^\[[\w\s]+\]$/);
      $entry =~ s/[\.\[\]\:]//g;
      next if ($entry =~ /of|the|or|re|on/i);
      print STDERR "Subject Entry $entry\n" if ($opt_D > 4);
      $subject{$entry}++;
    }
    my $body = $msg->body($msg->find_body);
    @msg_body = $body->as_lines(strip_sig => 1);
    print STDERR "Checking lines @$msg_body\n" if ($opt_D);
    LINE: for (@msg_body) {
      next LINE if ( m/^$/ );
      #  Need to check for footers and Sigs and stuff
      if (/^__________________________________________________$/) {
        print STDERR "Possible Footer\n" if ($opt_D > 1);
        $footer++;
      } elsif ($footer and /^Do You Yahoo!\?$/) {
        print STDERR "Yep, its a Yahoo footer, Skipping to next Message\n" 
          if ($opt_D > 1);
        next MESSAGE;
      } elsif (/^-----BEGIN PGP SIGNED MESSAGE-----$/) {
        print STDERR "PGP Signed Message\n" if ($opt_D > 1);
        print STDERR "PGP::$who $_" if ($opt_D > 4);
        $PGP++;
        next LINE;
      } elsif ($PGP and /^Hash: (\w+)$/) {
        print STDERR "PGP Hash Type ($1)\n" if ($opt_D > 1);
        print STDERR "PGP::$who $_" if ($opt_D > 4);
        next LINE;
      } elsif (/^-----BEGIN PGP SIGNATURE-----$/) {
        print STDERR "Begin PGP Signature\n" if ($opt_D > 1);
        print STDERR "PGP::$who $_" if ($opt_D > 4);
        $PGPsig++;
        next LINE;
      } elsif ($PGPsig and ! /^-----END PGP SIGNATURE-----$/) {
        print STDERR "PGP::$who $_" if ($opt_D > 4);
        next LINE;
      } elsif ($PGPsig and /^-----END PGP SIGNATURE-----$/) {
        print STDERR "END PGP Signature\n" if ($opt_D > 1);
        print STDERR "PGP::$who $_" if ($opt_D > 4);
        $PGPsig--;
        next LINE;
      }
      #####################################
      $lines++;
      if ( ! m/^[ \t]*$|^[ \t]*[>:|]|^\.\s\:\s/ ) {
        if (
           m/^[\w\s\,\@\.\-\:\/\+]+ wrote:\s*$/
           or m/^[\w\s\,\@\.\-\:\/]+ wrote >\s*$/
           or m/\w{3}, \d{1,2} \w{3} \s{4} \d{2}:\d{2}:\d{2} [\+\-]\s{4}/
           or m/^[\w\-]+\: /
           or m/^[\d\s]+\: /
           or m/^--/) {
          print STDERR "Attribution\n" if ($opt_D);
          print STDERR "-$_\n" if ($opt_D > 4);
          next LINE;
        }
      
        print STDERR "Adding line to \@total_lines\n" if ($opt_D > 2);
        print STDERR "+$_\n" if ($opt_D > 4);
        push @total_lines, $_;
      } else {
        print STDERR "Quoted\n" if ($opt_D);
        print STDERR "-$_\n" if ($opt_D > 4);
      }
    }
  } 
  print STDERR '-' x 75 . "\n" if ($opt_D);
  $msgc++;
}
print "Removing temporary mailbox\n" if ($opt_v and $tmpbox);
unlink($mailbox) if ($tmpbox);

print "$#total_lines lines found from $opt_e\n";
@keys = sort {
    $subject{$b} <=> $subject{$a} || length($b) <=> length($a) || $a cmp $b
} keys %subject;

my $count = 1;
for (@keys) {
  # print "$_ -> $subject{$_}\n";
  push @keywords, $_;
  last if ($count > 2);
  $count++;
}
$keywords = join('+', @keywords);
$url = "http://www.google.com/search?hl=en&ie=UTF-8&oe=UTF-8&q=$keywords";

print "$url\n";
$content = `lynx -dump '$url'`;
# print "$content\n\n";
my $total_urls = 1;
LINE: for my $line (split "\n", $content) {
print "$line ::";
  $line =~ /^  1[369]\. (http\S+)/;
  my $url = $1;
  last LINE if (!$url);
  print "lynx -dump '$url'\n";
  my $data = `lynx -dump '$url'`;
  # print $data;
  $data =~ s/[\n\r\"]/ /sg;
  $data =~ s/\s+/ /g;
  my @sent = split /[\|\.\,\?\:\!\(\)\;\*\[\]\=\/\-\#\|\\]/, $data;
  my $i = 0;
  while ($i < 10) {
    my $rand = int rand ($#sent) + 1;
    my $line = $sent[$rand];
    $line =~ s/^\s*//;
    if ($line =~ /^http/
        or $line =~ /^[\d\s]+$/
        or $line =~ m{^//}
        or $line =~ /^com$/
        or $line =~ /^$/
        or $line =~ /^__/
        or $line =~ /^shtml|html|htm|cgi|pl|cfm|php$/
        or $line =~ /^\S+$/
        or $line =~ /^[\d\s]$/
        or $line eq $dup{$line}
        ) {
       next;
    }
    # print STDERR "SALT:: $line ::\n";
    $dup{$line}++;
    push @total_lines, $line;
    $i++;
  }
  if ($total_urls > 2) {
    last LINE;
  } else {
    $total_urls++;
  }
}

undef %saw;
@out = grep(!$saw{$_}++, @total_lines);  

$data = join ' ', @out;
$data =~ s/[\n\r]/ /sg;
# print $data;
@new = split(' ', $data);
for $word (@new) {
  if ($word =~ m{http://}
      or length($word) > 15) {
    next;
  } 
  push @data, $word;
}

$string = join ' ', @data;
$string =~ s/\"//gs;
@sent = split /[\.\,\?\:\!\(\)\;\*\[\]\=\>\<\|\#\-\\]/, $string;

print "$#sent sentences\n";

for my $i (1..$#sent) {
  my $rand = int rand ($i+1);
  @sent[$i,$rand] = @sent[$rand,$i];
}


format STDOUT = 
^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ~~
$para
.

my $part++;

for $out (@sent) { 
  $out =~ s/\s+$//gs;
  $out =~ s/^\s+//gs;
  next if ($out =~ /^$/); 
  
  if ($out =~ /^[\d\w\']+$/) {
    if (!$case) {
      $out = ucfirst $out;
      $case++;
    }
    $para .= "$out, ";
  } else {
    if (!$case) {
      $out = ucfirst $out;
    }
    $para .= "$out.  ";
    $line++;
    undef $case;
    undef $part;
  }
  if ($line % $opt_n == 0 and !$part) {
    write;
    $para = '';
    print "\n";
    $part++;
  }
}

sub usage {
  print "burble - $VERSION - by: MadHat<madhat\@unspecific.com>\n

Usage:

  burble -e <email> [-f <date>] [-t <date>] [-v] [-n#] /path/to/mbox

Required:
  -e  From address to 'burble' the messages from

Recomended:
  -f  From Date mm/dd/yy[yy]
  -t  To Date mm/dd/yy[yy]

Optional:
  -v  Verbose output
  -n  number of sentences per paragraph (default 10)

Not Recomended:
  -D  Debug level 1-5



";
  exit;
}

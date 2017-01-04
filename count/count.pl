#!/usr/bin/perl
#---------------------------------------
#
# Email Counter
#   Writen by MadHat (madhat@unspecific.com)
# http://www.unspecific.com/count/
#
# count.pl is to keep score on some of the mailing lists I have been
# on for a while. What it does is count the emails, domains or suffixes
# to tell how many emails, lines and new lines have been posted to the
# list. It reads a standard mbox format files.
# I have tested it with mutt, pine, evolution, and Eudora.
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
#
# modification sa1 - 2011-05-01 - sentimental-asshole@dotorg.org
# Specifies subject lines to ignore during URL rollup

use warnings;
use Getopt::Std;
use Date::Manip;
use Mail::MboxParser;
use Data::Dumper;
$VERSION = '2.4.16';

#######################################################

our $opt_D = 0;
our ($opt_L, $opt_N, $opt_G, $opt_T, $PGPSig);

getopts('edsMhluELNGTHD:m:f:t:S:v');
if ($opt_D) { print "DEBUG\n"; $opt_v = 1; }

if ( !($opt_e xor $opt_d xor $opt_s xor $opt_M) or $opt_h ) { &usage }

print "<pre>\n" if ($opt_H);

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
    use LWP::Simple;
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
    if ($opt_D > 4) {
      $headers = $msg->header;
      for $head (sort keys %$headers) {
        if (@{$msg->header->{$head}}) {
          for $value (@{$msg->header->{$head}}) {
            print STDERR "HEADER:::$head => $value\n"
          }
        } else {
          print STDERR "HEADER::$head => " . $msg->header->{$head} . "\n"
        }
      }
      print STDERR "-_" x 30 . "\n"
    }
    my $msgid = $msg->header->{'message-id'};
    $msgid =~ s/[\<\>]//g;
    my $to;
    if ($to = $msg->header->{'to'}) {
      $to =~ s/^[\s\S]*\<([\w\d\-\$\+\.\@\%\]\[]+)\>.*$/$1/;
      $to =~ /^([\w\.\-]+)\@.*\.\w+$/;
      my $sto = $1;
      print STDERR "To: $to ($sto)\n" if ($opt_D > 1);
    } else {
      print STDERR "No To\n" if ($opt_D > 1);

    }
    my $sub = $msg->header->{'subject'};
    if ($opt_l and ($sub eq '(no subject)' or $sub eq '') ) { $html++; $bad++ }
    print STDERR "Subject: $sub\n" if ($opt_D > 1);
    my $references;
    if ($references = $msg->header->{'references'}) {
      $references =~ s/\s*//g;
      $references =~ s/\<([\w\d\-\$\.\@\%\]\[]+)\>/$1\n/g;
    }
    my $replyto;
    if ($replyto = $msg->header->{'in-reply-to'}) {
      $replyto =~ s/\s*//g;
      $replyto =~ s/^\s*\<([\w\d\-\$\.\@\%\]\[]+)\>.*$/$1/;
    }
    print STDERR "Message-ID: $msgid\n" if ($opt_D > 1);
    print STDERR "In-Reply-To: $replyto\n" if ($opt_D > 1 and $replyto);
    print STDERR "References: $references\n" if ($opt_D > 1 and $references);
    if ( $msgid{$msgid} ) {
      print STDERR "Duplicate Message: $msgid\n" if ($opt_D);
      next;
    } else {
      $msgid{$msgid}++;
    }
    $count2++;
    $email = $msg->from->{'email'};
    print STDERR "From: $email\n" if ($opt_D > 1);
    $email =~ tr/[A-Z]/[a-z]/;
    $email =~ s/[\<\>]//g;
    $email =~ s/ \(.+\)$//g;
    $email =~ s/^\".+\"//;
    if ($opt_e) {
      $who = $email;
    } elsif ($opt_d) {
      $email =~ /^[\w\.\-]+\@(.*\.\w+)$/;
      $who = $1;
    } elsif ($opt_s) {
      $email =~ /^[\w\.\-]+\@.*(\.\w+)$/;
      $who = $1;
    }
    if ($opt_M) {
      $Mcounter++;
      my $mailer;
      if ($mailer = $msg->header->{'x-mailer'}) {
        print STDERR "X-Mailer: $mailer\n" if ($opt_D > 1);

      } elsif ($mailer = $msg->header->{'x-mimeole'}) {
        print STDERR "User-Agent: $mailer\n" if ($opt_D > 1);

      } elsif ($mailer = $msg->header->{'user-agent'}) {
        print STDERR "User-Agent: $mailer\n" if ($opt_D > 1);

      } elsif ($msgid =~ /\@mail\.gmail\.com$/) {
        $mailer{'GMail (Google)'}++;
        print STDERR "MSGID $msgid -> Google GMail\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.LNX\.\d\.\d{1,3}/) {
        $mailer{'Pine (Linux)'}++;
        print STDERR "MSGID $msgid -> Pine (Linux)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.CYG\.\d\.\d{1,3}/) {
        $mailer{'Pine (Windows)'}++;
        print STDERR "MSGID $msgid -> Pine (Windows)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.CYG\.\d\.\d{1,3}/) {
        $mailer{'Pine (Cygwin)'}++;
        print STDERR "MSGID $msgid -> Pine (Cygwin)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.BSF\.\d\.\d{1,3}/) {
        $mailer{'Pine (FreeBSD)'}++;
        print STDERR "MSGID $msgid -> Pine (FreeBSD)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.BSO\.\d\.\d{1,3}/) {
        $mailer{'Pine (OpenBSD)'}++;
        print STDERR "MSGID $msgid -> Pine (OpenBSD)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.BSD\.\d\.\d{1,3}/) {
        $mailer{'Pine (BSD)'}++;
        print STDERR "MSGID $msgid -> Pine (BSD)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.SUN\.\d\.\d{1,3}/) {
        $mailer{'Pine (SunOS)'}++;
        print STDERR "MSGID $msgid -> Pine (SunOS)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.SOL\.\d\.\d{1,3}/) {
        $mailer{'Pine (Solaris)'}++;
        print STDERR "MSGID $msgid -> Pine (Solaris)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.NEB\.\d\.\d{1,3}/) {
        $mailer{'Pine (NetBSD)'}++;
        print STDERR "MSGID $msgid -> Pine (NetBSD)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.BSI\.\d\.\d{1,3}/) {
        $mailer{'Pine (BSDi)'}++;
        print STDERR "MSGID $msgid -> Pine (BSDI)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /^Pine\.\w{3}\.\d\.\d{1,3}/) {
        $mailer{'Pine'}++;
        print STDERR "MSGID $msgid -> Pine (Other)\n" if ($opt_D > 1);

      } elsif ($msgid =~ /\@webbox\.com/) {
        $mailer{'WebBox'}++;
        print STDERR "MSGID $msgid -> WebBox\n" if ($opt_D > 1);

      } elsif ($msgid =~ /\@onebox\.com/) {
        $mailer{'OneBox'}++;
        print STDERR "MSGID $msgid -> OneBox\n" if ($opt_D > 1);

      } elsif ($msgid =~ /yahoo\.com/) {
        $mailer{'Yahoo'}++;
        print STDERR "MSGID $msgid -> Yahoo\n" if ($opt_D > 1);
      } elsif ($msgid =~ /hotmail\.com/) {
        $mailer{'HotMail'}++;
        print STDERR "MSGID $msgid -> HotMail\n" if ($opt_D > 1);
      } elsif ($msgid =~ /hushmail\.com/) {
        $mailer{'HushMail'}++;
        print STDERR "MSGID $msgid -> HushMail\n" if ($opt_D > 1);
      } else {
        $mailer{'UNKNOWN'}++;
        print STDERR "MSGID $msgid -> Unknown\n" if ($opt_D);
      }
      if ($mailer) {
        &init();
        for $agent (keys %mailer_agent) {
          if ($mailer =~ /^$agent/) {
            print STDERR "$mailer -> $agent -> $mailer_agent{$agent}\n"
              if ($opt_D > 1);
            $mailer{$mailer_agent{$agent}}++;
            next MESSAGE;
          }
        }
        print STDERR "No Match: $mailer\n" if ($opt_D);
      } else {
        # print STDERR "No Mailer Found\n" if ($opt_D);
      }
      next MESSAGE;
    }
    if (!$who) {
      print STDERR "Unable to find _who_\n" if ($opt_D > 1);
      print STDERR '-' x 75 . "\n" if ($opt_D);
      $msgc++;
      next MESSAGE;
    } else {
      print STDERR "Matched: $who\n" if ($opt_D > 1);
    }
    if (
         $msg->header->{'x-originating-ip'}
       and
         $track{$msg->header->{'x-originating-ip'}}
       and
         $track{$msg->header->{'x-originating-ip'}} ne $who
       ) {
      print STDERR "TRACE::" . $track{$msg->header->{'x-originating-ip'}}
        . " and $who using " . $msg->header->{'x-originating-ip'} . "\n"
        if ($opt_D > 4);
    } elsif ($msg->header->{'x-originating-ip'}) {
      $track{$msg->header->{'x-originating-ip'}} = $who;
      print STDERR "IP::" . $msg->header->{'x-originating-ip'} . " => $who\n"
        if ($opt_D > 4);
    }
    my $body = $msg->body($msg->find_body);
    @msg_body = $body->as_lines;
    if ($msg->is_multipart) {
      @parts = $msg->parts;
      if (@parts and $opt_l and !$html) {
        print STDERR "Message $count2 has multiple parts\n" if ($opt_D);
        print STDERR "Testing message $count2 for 'bad' parts\n" if ($opt_D);
        my $i;
        PARTS: for $i (0..$#parts) {
          my $part_type = $parts[$i]->effective_type;
          if ($part_type =~ /^text\/html|enriched/i
              or $part_type =~ /^image|audio|application\/[^pgp-]/i
             ) {
            print STDERR "MIME-Type: $part_type (*co*loser*ugh*)\n" if ($opt_D > 1);
            $html++;
            $bad++;
            last PARTS;
          } else {
            print STDERR "MIME-Type: $part_type looks ok\n" if ($opt_D > 1);
          }
        }
      }
    }
    my $body_count = $#msg_body;
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
      } elsif (/^--\s*$/ and $lines <= ($body_count - 6)) {
        print STDERR "Possible Footer\n" if ($opt_D > 1);
        last LINE;
      }
      #####################################
      $lines++;
      if ( ! m/^[ \t]*$|^[ \t]*[>:]|^\.\s\:\s/ ) {
        $new_lines++;
        # print STDERR "LINES:$lines NEW_LINES:$new_lines QUOTES:$quotes\n" if ($opt_D > 6);
        if ($new_lines > 1 and !$quotes) {
          print STDERR "TOPPOST:$toppost\n" if ($opt_D > 6);
          $toppost++;
        } elsif ($quotes and $toppost) {
          print STDERR "TOPPOST:! $toppost\n" if ($opt_D > 6);
          $toppost = 0;
        }
        if ($opt_u) {
          if (/(https?\:\/\/\S+)/) {
					  my $site = $1;
					  chomp $site;
					  $site =~ s/[\>\.\)]*$//;
					  $sub =~ s/^re\:\s//i;
					  $sub =~ s/^\[[\w\-\d\:]+\]\s//i;
					  if ($site =~ /(yahoo|msn|hotjobs|hotmail|your\-name|pgp|excite)\.com\/?$/
			    			or $site =~ /(promo|click|docs)\.yahoo\.com/
					    	or $site =~ /(join|explorer|messenger|mobile)\.msn\.com/
		    				or ($sto and $site =~ /mailman\/listinfo\/$sto$/)
				    		or $skipped{$site}
				    		or (defined($opt_S) and $sub =~ /$opt_S/)) {
							$skipped{$site}++;
							print STDERR "Skipping $site ($skipped{$site})\n"
							. " - from message '$sub'\n - from $who\n\n"
							if ($opt_D > 1);
						} else {
							if (!$urls{$site}) {
								print STDERR "Adding $site\n from message '$sub'\n from $who\n\n"
								if ($opt_D > 1);
								$contrib{$who}++;
								$urls{$site} = $sub;
								push @{$url_list{$sub}}, $site;
							} else {
								print STDERR "Skipping (duplicate) $site\n  from message '$sub'\n  from $who\n\n"
								if ($opt_D > 1);
							}
						}
          }
        }
        print STDERR "NEW($new_lines, $lines) $_" if ($opt_D > 2);
      } else {
        print STDERR "QUOT($lines) $_" if ($opt_D > 2);
        $quotes++;
      }
    }
    $tracker{$msgid} = $who;
    if ($unordered{$msgid} and @{$unordered{$msgid}}) {
      my %counted = ();
      print STDERR "Matched MSGID to Previous Reference\n"
        if ( $opt_D > 1 );
      REF: for my $ordered (@{$unordered{$msgid}}) {
        if ($counted{$ordered}) {
          print STDERR " `-Already Incremented for $who ($ordered)\n"
            if ( $opt_D > 1 );
          next REF;
        } else {
          $counted{$ordered}++;
          $replyto{$who}++;
          print STDERR " `-Incrimenting $who Troll Rating ($ordered)\n"
            if ( $opt_D > 1 );
        }
      }
    }
    if ($replyto and $tracker{$replyto}) {
      $replyto{$tracker{$replyto}}++;
      print STDERR "Replying to: $tracker{$replyto} ($replyto{$tracker{$replyto}})\n"
        if ( $opt_D > 1 );
    } elsif ($replyto) {
      push @{$unordered{$replyto}}, $msgid;
      print STDERR "Replying to: Unknown Reference\n"
        if ( $opt_D > 1 );
    }
    if ($references) {
      my $rmsgidc = 1;
      RMSGID: foreach my $rmsgid ( split("\n", $references) ) {
        next RMSGID unless ( $rmsgid );
        print STDERR "Reference MSGID ($rmsgidc): $rmsgid\n"
          if ($opt_D > 1);
        if ($rmsgid ne $replyto and $tracker{$rmsgid}) {
          $replyto{$tracker{$rmsgid}}++;
          print STDERR "Referencing ($rmsgidc): $tracker{$rmsgid} ($replyto{$tracker{$rmsgid}})\n"
            if ( $opt_D > 1 );
        } elsif ($tracker{$rmsgid}) {
          print STDERR "Referenced In-Reply-To Duplicate ($rmsgidc): $tracker{$rmsgid} ($replyto{$tracker{$rmsgid}})\n"
            if ( $opt_D > 1 );
        } else {
          push @{$unordered{$rmsgid}}, $msgid;
          print STDERR "Referencing ($rmsgidc): Unknown Reference\n"
            if ($opt_D > 1);
        }
        $rmsgidc++;
      }
    }
    if ($new_lines * 10 < $lines - $new_lines and !$html) {
      $html++;
      $bad++;
      print STDERR "$sub) New lines ($new_lines) is less that 10% of quoted lines("
        . ($lines - $new_lines) . ") by $who\n" if ($opt_D);
    } elsif (!$html and $toppost and $quotes) {
      $html++;
      $bad++;
      print STDERR "$sub) Top Post from $who\n" if ($opt_D);
    }
    for my $line ($body->signature) {
      print STDERR "SIG::$who => $line\n" if ($line !~ /^\s*$/ and $opt_D > 2);
    }
    $count{$who}++;
    $lines{$who} += $lines;
    $new_lines{$who} += $new_lines;
    $html{$who} += $html;
    $counter++;
    if ($html{$who} > $count{$who}) {
      die "ERROR: Bad Mails outnumbers Total Mails
    $who: $html{$who} > $count{$who}
    This should NEVER happen.\n"
    }
  }
  print STDERR '-' x 75 . "\n" if ($opt_D);
  $msgc++;
}
print "Removing temporary mailbox\n" if ($opt_v and $tmpbox);
unlink($mailbox) if ($tmpbox);

if ($opt_M) {
  print "Start Date: " . UnixDate($date1, "%b %e, %Y") . "\n"
    if ($opt_f);
  print "End Date:   " . UnixDate($date2, "%b %e, %Y") . "\n"
    if ($opt_f or $opt_t);
  @keys = sort {
    $mailer{$b} <=> $mailer{$a}
  } keys %mailer;
  $count = @keys;
  print "EMails Found: $Mcounter\n";
  print "Unique Agents: $count\n\n";
  print "  #    %    Client\n";
  for my $client (@keys ) {
    my $perc = sprintf("%.1f", $mailer{$client}/$Mcounter*100);
    print swrite(<<'END', $mailer{$client}, $perc, $client);
@>>>  @>>>  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
END
  }
  exit;
}

if ( $opt_L ) {
  print "Sorting by total number of lines sent\n" if ($opt_v);
  @keys = sort {
    $lines{$b} <=> $lines{$a} || $a cmp $b
  } keys %lines;
} elsif ( $opt_N ) {
  print "Sorting by total number of new lines sent\n" if ($opt_v);
  @keys = sort {
    $new_lines{$b} <=> $new_lines{$a} || length($b) <=> length($a) || $a cmp $b
  } keys %new_lines;
} elsif ( $opt_G ) {
  print "Sorting by total number of noise sent\n" if ($opt_v);
  @keys = sort {
    ($lines{$a} / $new_lines{$a}) <=> ($lines{$b} / $new_lines{$b})
  } keys %count;
} else {
  print "Sorting by total number of emails sent\n" if ($opt_v);
  @keys = sort {
    $count{$b} <=> $count{$a} || length($b) <=> length($a) || $a cmp $b
  } keys %count;
}

&load_formats;


die $@ if $@;

print '-' x 75 . "\n" if ($opt_v);
print "count v$VERSION by MadHat(at)Unspecific.com - [[|%^)
    http://www.unspecific.com/.go/count/
--\n\n"
  if ($opt_v);
print "Total emails checked: $count2\n" if ($opt_v);
print "Start Date: " . UnixDate($date1, "%b %e, %Y") . "\n"
  if ($opt_f);
print "End Date:   " . UnixDate($date2, "%b %e, %Y") . "\n"
  if ($opt_f or $opt_t);
print "Total emails matched: $counter\n"; # if ($counter != $count2);
print "Total emails from losers: $bad\n" if ($bad and $opt_l);
$number = keys %count;
print "Total Unique Entries: $number\n";
$max_count = $opt_m?$opt_m:50;
for $id (@keys) {
  $perc = 0;
  $loser = 0;
  $replyto{$id} = $replyto{$id}?$replyto{$id}:'0';
  $current_number++;
  last if ($current_number > $max_count);
  $perc = $new_lines{$id} / $lines{$id} * 100 if ($lines{$id});
  $loser = $html{$id} / $count{$id} * 100 if ($html{$id} > 0);
  write;
}
if ($opt_u) {
  print "\n--\n\n";
  print "Contributers                            URLs\n";
  print "------------                            ----\n";
  for (sort {$contrib{$b} <=> $contrib{$a}} keys %contrib) {
    $contribc++;
    printf "%2d) %-35s %3d\n", $contribc, $_, $contrib{$_};
  }
  print "\nURLs Found\n-------------\n";
  for (sort keys %url_list) {
    print "$_\n";
    for $URL (@{$url_list{$_}}) {
      print " $URL\n";
    }
    print "\n";
  }
}

print "</pre>\n" if ($opt_H);

0;
#---------------------------------------

sub usage {
  print "count - $VERSION - The email counter by: MadHat<madhat\@unspecific.com>\n
$0 <-e|-d|-s|-M> [-ENLGTlu] [-m#] [-f <from_date> -t <to_date>] <mailbox | http://domain.com/archive/mailbox>\n"
  . "\t-h Full Help";
  print " (not just this stuff)" if (!$opt_h);
  print "\n\t-e email address\n"
  . "\t-d count domains\n"
  . "\t-s count suffix (.com, .org, etc...)\n"
  . "\t-M count Mailer Agents\n"
  . "\t-l Add loser rating\n"
  . "\t-T Add troll rating\n"
  . "\t-u Add list of URLs found in the date range\n"
  . "\t\t-Ssubject ignore messages with specified subject header\n"
  . "\t-v Verbose output (DEBUG Output)\n"
  . "\t-E sort on emails (DEFAULT)\n"
  . "\t-L sort on total lines\n"
  . "\t-N sort on numer of NEW lines (not part of reply)\n"
  . "\t-G sort on Garbage (quoted lines)\n"
  . "\t-m# max number of entries to show\n"
  . "\t-fmm/dd/yyyy From date.  Start checking on this date [01/01/1970]\n"
  . "\t-tmm/dd/yyyy To date. Stop checking after this date [today]\n"
  . "\t<mailbox> is the mailbox to count in...\n\n";

  if ($opt_h) {
    print "
'count' will open the disgnated mailbox and sort through the emails counting
on the specified results.

-e, -d or -s are required as well as a mailbox.  All other flags are optional.

 -e will count on the whole email address
 -d will count only on the domain portion of the email (everything after the \@)
 -s will count on the suffix (evertthing past the last . - .com, .org...)
 -M will count the Mailers, (PINE, mutt, OutLook), most options do not work
    with this Counter

Present reporting fields include the designated count field (see above),
Total EMails Posted, Total Lines Posted, Total New Lines and Sig/Noise Ratio.

- Total EMails Pasted is just that, the total number of emails posted by
  that counted field.

- Total Lines Posted is the total number of messages lines, not including
  any header fields, posted by that counted field.

- Total New Lines is the total number of lines. not including any header
  fields, that are not part of a reply ot forward.  The way a line is
  determined to be new line, is that it is not started by one of the common
  characters for replied lines, > | # : or <TAB>.

  WARNING:  This is not accurate on some email client (some MS Clients) because
  they do not properly attribute lines in replies.

- Sig/Noise Ratio is the % of new info as compaired to total lines posted.
  This is calculated by taking the total new lines, deviding it by the total
  number of lines and multiplying by 100 (for percentage).

Other Options:

The default sort order is by Total Number of Emails (-E), but you can also
sort by other fields:

 -L to sort on total number of Lines posted.
 -N to sort on total number of New Lines posted.
 -G to sort on Garbage. Garbage is the number of non-new lines.

By default the maximum number of counted fields shown is 50.  This can be
changed with the -m flag.

By default the date range is from January 1, 1970 through 'today'.  You can
specify a date range using the -f and -t options

 -f From date.  Format is somewhat forgiving, but recomended is mm/dd/yyyy
 -t To date.  This is the date to stop on.  Same for format as above.

 -u Add list of URLs found in the date range
    create a list of URLs found, with Subject of the email listed for each URL
	-Ssubject will ignore any messages with the specified subject.

 -l Add loser rating.  I added this because I use this on mailing lists.
      Most mailing lists I am on, consider it bad to post HTML or attachments
      to the list, so this counts the number of HTML posting and attachments
      (other than things like PGP Sigs) and generates a number from 0 to 100
      which is the % of the mails that fall into this catagory.

 -T Add Troll rating.  I added this because some lists didn't have any
      obvious losers ;^) and didn't want to leave those lists out.
      This is simply the number of emails referencing a previous email
      The information is gathered from the 'In-Reply-To' and
      'Reference' headers.

";
  }
  exit;
}

sub load_formats {
  $flt0 = "format STDOUT_TOP =";
  $flt2 = "    Address                     EMails  Lines   New   S/N ";
  $flt3 = "                                Posted  Posted Lines Ratio";
  $flt4 = ".";
  $fl0 =  "format STDOUT = ";
  $fl1 =  "@>> @<<<<<<<<<<<<<<<<<<<<<<<<<<< @>>>>  @>>>> @>>>>> @## ";
  $fl2 =  "\$current_number, \$id, \$count{\$id}, \$lines{\$id},\$new_lines{\$id}, \$perc";
  $fl3 =  ".";

  if ($opt_l) {
    print "Displaying Loser Ratings\n" if ($opt_v);
    $flt2 .= "   L  ";
    $fl1 .=  "  @## ";
    $fl2 .=  ", \$loser";
  }
  if ($opt_T) {
    print "Displaying Troll Ratings\n" if ($opt_v);
    $flt2 .= "  T   ";
    $fl1 .=  "@>>>> ";
    $fl2 .=  ", \$replyto{\$id}";
  }
  $format = join ("\n", $flt0, "\n", $flt2, $flt3, $flt4, $fl0, $fl1, $fl2, $fl3);

  eval $format;
}

sub swrite {
  my $format = shift;
  $^A = "";
  formline($format,@_);
  return $^A;
}

sub init {
  %mailer_agent = ('Apple Mail' =>'Apple Mail', 'ELM ' => 'ELM',
    'QUALCOMM Windows Eudora' => 'Eudora (Windows)',
    'Windows Eudora' => 'Eudora (Windows)', 'KMail' => 'KMail',
    'Microsoft-Outlook-Express-Macintosh-Edition' => 'Outlook Express (Mac)',
    'AT\&T Message Center' => 'AT&T Message Center', 'AOL ' => 'AOL',
    'SquirrelMail' => 'SquirrelMail', 'Opera/' => 'Opera',
    'WWW-Mail' => 'Global Message Exchange',
    'Mutt' => 'Mutt', 'PIPEX NetMail' => 'PIPEX', 'Calypso' => 'Calypso',
    'Infinite Mobile Delivery' => 'Hydra', 'Netscape' => 'Netscape',
    'Microsoft Outlook Express' => 'Outlook Express',
    'Internet Mail Service' => 'Outlook Internet Mail Service',
    'Microsoft Outlook \d\.' => 'Outlook',
    'Microsoft Outlook\, ' => 'Outlook',
    'Microsoft Exchange\, ' => 'Outlook',
    'Microsoft-Entourage\/' => 'Microsoft-Entourage',
    'Microsoft Outlook IMO' => 'Outlook Internet Mail Only',
    'Microsoft Outlook CW' => 'Outlook Corporate/Workgroup',
    # 'Microsoft ' => 'Microsoft (other)',
    'Mozilla/\d\.\d \(Windows' => 'Mozilla (Windows)',
    'Mozilla/\d\.\d \(Macintosh' => 'Mozilla (Macintosh)',
    'Mozilla/\d\.\d \(X11; \w; Linux' => 'Mozilla (Linux)',
    'Mozilla \d\.\d{1,2} \[\w{2}\] \(Win' => 'Mozilla (Windows)',
    'Mozilla \d\.\d{1,2} \[\w{2}\-\w{2}\] \(Win' => 'Mozilla (Windows)',
    'Mozilla \d\.\d{1,2} \[\w{2}\][\w\-\s]+ \(Win' => 'Mozilla (Windows)',
    'Mozilla \d\.\d{1,2} \[\w{2}\][\{\}\w\-\s]+ \(Win' => 'Mozilla (Windows)',
    'Mozilla \d\.\d{1,2} \[\w{2}\-\w{2}\][\w\-\s]+ \(Win' => 'Mozilla (Windows)',
    'Mozilla \d\.\d{1,2} \[\w{2}\] \(X11; \w; Linux ' => 'Mozilla (Linux)',
    'Mozilla \d\.\d{1,2} \[\w{2}\] \(X11; \w; FreeBSD ' => 'Mozilla (FreeBSD)',
    'Mozilla \d\.\d{1,2} \[\w{2}\] \(X11; U; OpenBSD' => 'Mozilla (OpenBSD)',
    'Mozilla \d\.\d{1,2} \[\w{2}\] \(X11; U; SunOS' => 'Mozilla (Solaris)',
    'GoldMine' => 'GoldMine', 'WebMail' => 'WebMail', '<IMail ' => 'IMail',
    'Ximian Evolution' => 'Evolution', 'Evolution' => 'Evolution',
    'Pegasus Mail' => 'Pegasus', 'Forte Agent' => 'Forte',
    'Sylpheed ' => 'Sylpheed', 'MailCity ' => 'MailCity',
    'Endymion ' => 'Endymion MailMan', 'CommuniGate ' => 'CommuniGate',
    'VisualMail ' => 'VisualMail', 'Lotus Notes ' => 'Lotus Notes',
    'Gnus v\d\.\d\/Emacs ' => 'Emacs',
    'Gnus\/\d\.\d+ \([\w\s\.\d]+\) X?Emacs' => 'Emacs',
    'InterChange \(Hydra' => 'Hydra', 'Microsoft CDO ' => 'Microsoft CDO',
    'Foxmail ' => 'Foxmail', 'NeoMail ' => 'NeoMail',
    'Claris Emailer ' => 'Claris Emailer',
    'KNode\/' => 'KNode', 'PocoMail ' => 'PocoMail',
    'mPOP Web-Mail ' => 'mPOP Web-Mail', 'Balsa ' => 'Balsa',
    'MIME-tools ' => 'Entity', 'Opera ' => 'Opera',
    'NeoMail ' => 'NeoMail', 'Phoenix ' => 'Phoenix Mail',
    'CompuServe ' => 'CompuServe', 'MSN Explorer ' => 'MSN Explorer',
    'WorldClient ' => 'Alt-N WorldClient',
    'Atlas ' => 'Atlas Mailer',
    'The Bat' => 'The Bat', 'Web Mail' => 'WebMail',
    'IMP\/PHP3?' => 'IMP', 'Internet Messaging Program' => 'IMP',
    # 'Mozilla' => 'Mozilla',
  );

}

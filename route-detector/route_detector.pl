#!/usr/bin/perl
#   Written by MadHat (madhat@unspecific.com)
# http://www.unspecific.com/
#
#
# Copyright (c) 2003, MadHat (madhat@unspecific.com)
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
use Net::RawIP qw(:pcap);
use Digest::MD5 qw(md5_hex);
use Socket;
if ($> != 0 or $) != 0) {
  print "\n****** MUST BE RUN AS ROOT ******\n\n";
  &usage;
}

$VERSION = 0.9;

getopts('c:D:d:hi:k:ln:s:S:t:v');

##################################################################
&usage if ($opt_h);

print "Route Detector v$VERSION by MadHat (at) Unpsecific.com\n" if ($opt_v);

local $SIG{'ALRM'} = sub { 
  print "Finished Listening for $opt_t Seconds\n" if ($opt_v); 
  exit; 
};

$opt_s = $opt_s?$opt_s:'172.23.35.206';
$opt_i = $opt_i?$opt_i:'eth0';
$opt_c = $opt_c?$opt_c:'-1';
$opt_t = $opt_t?$opt_t:'0';
$opt_S = $opt_S?$opt_S:'0';

if ($opt_l) {
  $listen = new Net::RawIP({icmp =>{}});
  my $pcap = $listen->pcapinit($opt_i,"icmp[icmptype] = icmp-echoreply",1500,30);
  # my $pcap = $listen->pcapinit($opt_i,"ip proto \\icmp",1500,30);
  alarm($opt_t);
  loop $pcap, $opt_c, \&match, \@listen;
  print "Caught $opt_c Packets.  Exiting\n" if ($opt_v);
} elsif ($opt_d) {
  my $Marconi=0;
  eval 'use Marconi';
  if ($@) {
    $Marconi=0;
    if (-e 'Marconi.pm') {
      eval 'require "./Marconi.pm"';
      if (!$@) {
        $Marconi++;
      }
    }
  } else {
    $Marconi++;
  }
  if (!$Marconi) {
      print "ERROR:\tMarconi not found/installed.\n";
      exit;
  }
  my @nets = split(',', $opt_d);
  foreach $net (@nets){
    chomp $net;
    next if ($net =~ /^#/ or $net =~ /^$/);
    print "scanning $net\n" if (defined($opt_v));
    @iplist = Marconi::CalculateIPRange($net);
    push(@totallist, @iplist);
  }
  print "Sending Packets to $#totallist IPs\n" if ($opt_d);
  for ( $i = 0; $i<=$#totallist; $i++ ){
    my $date = time;
    my $ipaddr = $totallist[$i];
    chomp $ipaddr;
    print "Sending to $ipaddr\n" if ($opt_v);
    my $send = new Net::RawIP({icmp =>{}});
    $send->set({ip => {saddr => $opt_s,
                 daddr => $ipaddr},
 	         icmp => {type => 8, id => $$}
 	 });  
    $check = md5_hex($opt_s . $opt_k);
    $data = "$ipaddr:$check:$date";
    $send->set({icmp => {sequence => 1, data => $data }});
    if ($opt_D) {
      print "saddr:   $opt_s\n";
      print "daddr:   $ipaddr\n";
      print "check:   $check\n";
      print "data:   $data\n";
    }
    $send->send($opt_S);
  }
} else {
   &usage;
}

sub match {
  my $time = timem();
  $listen->bset(substr($_[2],14));
  my @data = $listen->get({ip => [qw(saddr daddr)], icmp=>[qw(data)]});
  my $date = time;
  $dest = inet_ntoa(pack("N",$data[1]));
  ($sendto_ip, $check, $stime) = split(':', $data[2]);
  $source = inet_ntoa(pack("N",$data[0]));

  if (md5_hex($dest . $opt_k) eq $check) {
    if ($opt_D) {
      print "Packet Received from: $source\n";
      print "Original IP Sent to:  $sendto_ip\n";
    }
    if ($source ne $sendto_ip) {
      if ($opt_v) {
        print "New Packet";
        $sdnsaddr = inet_aton($source);
        $sdnsname = gethostbyaddr($sdnsaddr, AF_INET);
        $sdnsname = $sdnsname?$sdnsname:'NOT_IN_DNS';
        $stdnsaddr = inet_aton($sendto_ip);
        $stdnsname = gethostbyaddr($stdnsaddr, AF_INET);
        $stdnsname = $stdnsname?$stdnsname:'NOT_IN_DNS';
        my $ttime = $date - $stime;
        if ($ttime) {
          $time = "$ttime sec"
        } else {
          $time = "less than 1 sec"
        }
        print "
  From: $source ($sdnsname)
  To:   $sendto_ip ($stdnsname)
  Time: $time\n\n";
      } else {
        print "Packet from: $source, Sent to: $sendto_ip\n";
      } 
    }
  }
  if ($opt_D) {
    print "saddr:  " . inet_ntoa(pack("N",$data[0])) . "\n";
    print "daddr:  " . inet_ntoa(pack("N",$data[1])) . "\n";
    print "data:   $data[2]\n";
    print "Sendto: $sendto_ip\n";
    print "check:  $check\n";
    print "\n";
  }
}

sub usage {
  print "Route Detector v$VERSION by MadHat (at) Unpsecific.com\n";
  print "Usage: \n$0 -l | -d <remote_ip> [-s <source_ip>] [-v] [-k key]\\
        [-t <sec>] [-c <pact_count>] [-S <sec_delay>\n";
  print "
    -l  Listen Mode  Sniffing for ICMP packets and looking for the right data.
    -d <remote_ip>   Send Mode, sending 'signed' ICMP packets to <remote_ip>
    -s <source_ip>   Spoofed Source IP, to be used with -d
    -k <key>         Key used to 'sign' the data in the ICMP packet
    -i <interface>   Interface, default eth0
    -t <sec>         Number of seconds to listen (-l) before exiting
    -S <sec_delay>   Number of seconds to wait (0) between each packet sent
    -c <pact_count>  Number of packets to listen for (-l) before exiting
    -v  Verbose      Add moe info about what is going on\n";
  exit;
}

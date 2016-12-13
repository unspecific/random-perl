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
use Socket;

$VERSION = 0.4;

getopts('d:l:n:t:vV');

##################################################################
&usage if ($opt_h);

print "NBTScan v$VERSION by MadHat (at) Unpsecific.com\n" if ($opt_v);

$opt_l = $opt_l?$opt_l:$ARGV[0];
$opt_t = $opt_t?$opt_t:'1';
$opt_n = $opt_n?$opt_n:'16';
$opt_v = $opt_V?'1':$opt_v;


&usage if (!$opt_l);

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
if ($opt_l eq '-') {
  print "\nEnter your IPs now (end with ^D):\n";
  $opt_l = join(',', <STDIN>);
}
my @nets = split(',', $opt_l);
foreach $net (@nets){
  chomp $net;
  next if ($net =~ /^#/ or $net =~ /^$/);
  print "scanning $net\n" if (defined($opt_v));
  @iplist = Marconi::CalculateIPRange($net);
  push(@totallist, @iplist);
}
print "Sending Packets to $#totallist IPs\n" if ($opt_d);
print "IP Address       Host Name        Mac Address         User           Domain
-------------------------------------------------------------------------------\n" 
   if ($opt_v and ($#totallist > 0 and !$opt_V));
for ( $i = 0; $i<=$#totallist; $i++ ){
  my $ipaddr = $totallist[$i];
  chomp $ipaddr;
  print "Sending to $ipaddr\n" if ($opt_d);
  my ($host, $mac, $user, $domain, @data) = Marconi::NBTScan($ipaddr, $opt_t, $opt_d);
  if ($host and ($#totallist > 0 and !$opt_V)) {
    my $output = Marconi::swrite("@<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<  @<<<<<<<<<<\n", $ipaddr, $host, $mac, $user, $domain);
    print $output;
  } elsif ($host and ($#totallist == 0 or $opt_V)) {
    print "IP Address       Name              Group       Type
-----------------------------------------------------------------------------\n" if ($opt_v);
    for my $item (@data) {
      my ($name, $type, $group) = split (',', $item);
      my $output = Marconi::swrite("@<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<  @<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<\n", $ipaddr, $name, $group, $type);
      print $output;
    }
    print "MAC Address: $mac\n";
  }
}

sub usage {
  print "NBTScan v$VERSION by MadHat (at) Unpsecific.com\n";
  print "Usage: \n$0 [-vV] [-t <sec>] <ip_range>\n";
  print "
    <ip_range>   Range of IPs you want to scan.  Supported formats listed below
    -t <sec>     Timeout for each host waiting for a response
    -v  Verbose  Add moe info about what is going on
    -V  Really Verbose This will show all information returned when 
                 scanning a subnet.

    a.b.c.d/n       - 10.0.0.1/25
    a.b.c.*         - 10.0.0.*
    a.b.c.d/w.x.y.z - 10.0.0.0/255.255.224.0 (standard format)
    a.b.c.d/w.x.y.z - 10.0.0.0/0.0.16.255    (cisco format)
    a.b.c.d-z       - 10.1.2.0-12
    a.b.c-x.*       - 10.0.0-3.*
    a.b.c-x.d       - 10.0.0-3.0
    hostname        - unspecific.com
    hostname[1-3]   - host[1-3].unspecific.com
\n";
  exit;
}

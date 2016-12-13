#---------------------------------------
#
# Basic scanner Modules.`
#   Writen by MadHat (madhat@unspecific.com)
# http://www.unspecific.com/scanner/
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

=head1 NAME

Marconi

=cut

package Marconi;
use v5.6.0;
$Marconi::VERSION = '1.4';

use Socket qw(:DEFAULT :crlf);

#---------------------------------------

=head1 SYNOPSIS

 $ips = <STDIN>;
 @iplist = CalculateIPRange($ips);
 for $ipaddr (@iplist) {
   print "$ipaddr\n";
 }

=head1 DESCRIPTION

C<Marconi> perl module is a simple set of routines used thoughout the suite of
Unspecific.com security and network tools.


=head1 METHODS

The following methods are available:

=over 4

=item @list = CalculateIPRange($iplist, [$errno, [$maxip]])


CalculateIPRange takes 3 possible parameters and returns an array reference

$iplist

  formats allowed include
    a.b.c.d/n       - 10.0.0.1/25
    a.b.c.*         - 10.0.0.*
    a.b.c.d/w.x.y.z - 10.0.0.0/255.255.224.0 (standard format)
    a.b.c.d/w.x.y.z - 10.0.0.0/0.0.16.255    (cisco format)
    a.b.c.d-z       - 10.1.2.0-12
    a.b.c-x.*       - 10.0.0-3.*
    a.b.c-x.d       - 10.0.0-3.0
    hostname        - unspecific.com
    hostname[1-3]   - host[1-3].unspecific.com

$errorno

whether or not to return an error message
default is to return nothing on error

$maxip

max number IPs to return 
default max is 65536 and can not be raised at this time

=cut


sub CalculateIPRange {
  # 1st IP scalar
  #  formats allowed include
  #    a.b.c.d/n       - 10.0.0.1/25
  #    a.b.c.*         - 10.0.0.*
  #    a.b.c.d/w.x.y.z - 10.0.0.0/255.255.224.0 (standard format)
  #    a.b.c.d/w.x.y.z - 10.0.0.0/0.0.16.255    (cisco format)
  #    a.b.c.d-z       - 10.1.2.0-12
  #    a.b.c-x.*       - 10.0.0-3.*
  #    a.b.c-x.d       - 10.0.0-3.0
  #    hostname        - unspecific.com
  # 2nd whether or not to return an error message or nothing 
  #    default is to return nothing on error
  # 3rd is max number IPs to return 
  #    default max is 65536 and can not be raised at this time
  my ($ip, $return_error, $max_ip, $debug) = @_;
  my @msg = ();
  my $err = '';
  my $port;
  $max_ip = $max_ip || 65536;
  my $a, $b, $c, $d, $sub_a, $sub_b, $sub_c, $sub_d, $num_ip,
      $nm, $d_s, $d_f, $c_s, $c_f, @msg, $err, $num_sub,
      $start_sub, $count_sub;
  # let's start now...
  # does it look just like a single IP address?
  if ($ip =~ s/^(.+):(\d{1,5})/$1/) { $port = $2 }
  if ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
    print STDERR "$cli_exec ($$): x.x.x.x format $ip\n" if ($debug);
    $a = $1; $b = $2; $c = $3; $d = $4;
    if ( $a > 255 or $a < 0 or $b > 255 or $b < 0 or $c > 255 or $c < 0 or 
         $d > 255 or $d < 0) {
      $err = "ERROR: Appears to be a bad IP address ($ip)";
    } else {
      if ($port) { push (@msg, "$ip:$port"); 
        } else { push (@msg, $ip); }
    }
  # does it look like the format x.x.x.x/n
  } elsif ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\/(\d{1,2})$/) {
    print STDERR "$cli_exec ($$): x.x.x.x/n format $ip\n" if ($debug);
    $a = $1; $b = $2; $c = $3; $d = $4; $nm = $5;
    if ( $a > 255 or $a < 0 or $b > 255 or $b < 0 or $c > 255 or $c < 0 or 
         $d > 255 or $d < 0 or $nm > 32 or $nm < 0) {
      $err = "ERROR: Something appears to be wrong ($ip)";
    } else {
      $num_ip = 2**(32-$nm);
      if ($num_ip > $max_ip) {
        $err = "ERROR: Too many IPs returned ($num_ip)";
      } elsif ($num_ip <= 256) {
        $num_sub = 256/$num_ip;
        SUBNET: for $count_sub (0..($num_sub - 1)) {
          $start_sub = $count_sub * $num_ip;
          if ($d > $start_sub and $d < ($start_sub + $num_ip)) {
            $d = $start_sub;
            last SUBNET;
          }
        }
        for $d ($d..($d + $num_ip - 1)) {
          $ip = "$a.$b.$c.$d";
          if ($port) { push (@msg, "$ip:$port"); 
            } else { push (@msg, $ip); }
        }
      } elsif ($num_ip <= 65536) {
        $num_sub = 256/($num_ip/256); $num_ip = $num_ip/256;
        SUBNET: for $count_sub (0..($num_sub - 1)) {
          $start_sub = $count_sub * $num_ip;
          if ($c > $start_sub and $c < ($start_sub + $num_ip)) {
            $c = $start_sub;
            last SUBNET;
          }
        }
        for $c ($c..($c + $num_ip - 1)) {
          for $d (0..255) {
            $ip = "$a.$b.$c.$d";
            if ($port) { push (@msg, "$ip:$port"); 
              } else { push (@msg, $ip); }
          }
        }
      }
    }
  # does it look like the format x.x.x.x-y
  } elsif ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\-(\d{1,3})$/) {
    print STDERR "$cli_exec ($$): x.x.x.x-y format $ip\n" if ($debug);
    $a = $1; $b = $2; $c = $3; $d_s = $4; $d_f = $5;
    if ( $d_f > 255 or $d_s > 255 or $d_s < 0 or $d_f < 0 or $a < 0 or 
         $a > 255 or $b < 0 or $b > 255 or $c < 0 or $c > 255 ) {
      $err = "ERROR: Something appears to be wrong ($ip).";
    } elsif ($d_f < $d_s) {
      LOOP: for $d ($d_f .. $d_s) {
        if ($#msg > $max_ip) { 
          $err = "ERROR: Too many IPs returned ($#msg+)"; 
          last LOOP;
        }
        $ip = "$a.$b.$c.$d";
        if ($port) { push (@msg, "$ip:$port"); 
          } else { push (@msg, $ip); }
      }
      # $err = "Sorry, we don't count backwards.";
    } elsif ($d_f == $d_s) {
      $ip = "$a.$b.$c.$d_s";
      if ($port) { push (@msg, "$ip:$port"); 
        } else { push (@msg, $ip); }
    } else {
      LOOP: for $d ($d_s .. $d_f) {
        if ($#msg > $max_ip) { 
          $err = "ERROR: Too many IPs returned ($#msg+)"; 
          last LOOP;
        }
        $ip = "$a.$b.$c.$d";
        if ($port) { push (@msg, "$ip:$port"); 
          } else { push (@msg, $ip); }
      }
    }
      # does it look like the format x.x.x-y.*
  } elsif ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\-(\d{1,3})\.(.*)$/) {
    print STDERR "$cli_exec ($$): x.x.x-y.* format $ip\n" if ($debug);
    $a = $1; $b = $2; $c_s = $3; $c_f = $4; $d = $5;
    if ( $c_f > 255 or $c_s > 255 or $c_s < 0 or $c_f < 0 or 
         $a < 0 or $a > 255 or $b < 0 or $b > 255 or 
         ( ($d < 0 or $d > 255) and $d ne "*") ) {
      $err = "ERROR: Something appears to be wrong ($ip)";
    } elsif ($c_f < $c_s) {
      LOOP: for $c ($c_f .. $c_s) {
        for $d (0..255) {
          if ($#msg > $max_ip) { 
            $err = "ERROR: Too many IPs returned ($#msg+)"; 
            last LOOP;
          }
          $ip = "$a.$b.$c.$d";
          if ($port) { push (@msg, "$ip:$port"); 
            } else { push (@msg, $ip); }
        }
      }
    } elsif ($c_f == $c_s) {
      $ip = "$a.$b.$c_s.$d";
      if ($port) { push (@msg, "$ip:$port"); 
        } else { push (@msg, $ip); }
    } else {
      LOOP: for $c ($c_s .. $c_f) {
        for $d (0..255) {
          if ($#msg > $max_ip) { 
            $err = "ERROR: Too many IPs returned ($#msg+)"; 
            last LOOP;
          }
          $ip = "$a.$b.$c.$d";
          if ($port) { push (@msg, "$ip:$port"); 
            } else { push (@msg, $ip); }
        }
      }
    }
  # does it look like the format x.x.x.*
  } elsif ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.\*$/) {
    print STDERR "$cli_exec ($$): x.x.x.* format $ip\n" if ($debug);
    $a = $1; $b = $2; $c = $3;
    if ( $a < 0 or $a > 255 or $b < 0 or $b > 255 or $c < 0 or $c > 255 ) {
      $err = "ERROR: Something appears to be wrong ($ip)";
    } else {
      LOOP: for $d (0 .. 255) {
        if ($#msg > $max_ip) { 
          $err = "ERROR: Too many IPs returned ($#msg+)"; 
          last LOOP;
        }
        $ip = "$a.$b.$c.$d";
        if ($port) { push (@msg, "$ip:$port"); 
          } else { push (@msg, $ip); }
      }
    }
  # does it look like the format x.x.x.x/y.y.y.y
  } elsif ($ip =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\/(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
    print STDERR "$cli_exec ($$): x.x.x.x/y.y.y.y format $ip\n" if ($debug);
    $a = $1; $b = $2; $c = $3; $d = $4; 
    $sub_a = $5; $sub_b = $6; $sub_c = $7; $sub_d = $8;
    # if it appears to be in "cisco" format, convert it
    if ($sub_a == 0 and $sub_b == 0) {
      $sub_a = 255 - $sub_a; $sub_b = 255 - $sub_b;
      $sub_c = 255 - $sub_c; $sub_d = 255 - $sub_d;
    }
    # check to see if the input looks valid
    if ( $a > 255 or $a < 0 or $b > 255 or $b < 0 or $c > 255 or $c < 0 or 
         $d > 255 or $d < 0 or $sub_a > 255 or $sub_a < 0 or
         $sub_b > 255 or $sub_b < 0 or $sub_c > 255 or $sub_c < 0 or 
         $sub_d > 255 or $sub_d < 0 or ($sub_d < 255 and $sub_c != 255 and 
         $sub_b != 255 and $sub_a != 255) or ($sub_d != 0 and 
         $sub_c == 0 and $sub_b < 255 and $sub_a == 255) or 
         ($sub_d != 0 and $sub_c < 255 and $sub_b == 255 and 
         $sub_a == 255)) {
      $err = "ERROR: Something appears to be wrong ($ip)";
    # if it looked valid, but it appears to be an IP, return that IP
    } elsif ($sub_d == 255) {
      $ip = "$a.$b.$c.$d";
      if ($port) { push (@msg, "$ip:$port"); 
        } else { push (@msg, $ip); }
    # if the range appears to be part of a class C
    } elsif ($sub_d < 255 and $sub_d >= 0 and $sub_c == 255) {
      $num_ip = 256 - $sub_d; $num_sub = 256/$num_ip;
      if ($num_ip > $max_ip) {
        $err = "ERROR: Too many IPs returned ($num_ip)";
      } else {
        SUBNET: for $count_sub (0..($num_sub - 1)) {
          $start_sub = $count_sub * $num_ip;
          if ($d > $start_sub and $d < ($start_sub + $num_ip)) {
            $d = $start_sub;
            last SUBNET;
          }
        }
        LOOP: for $d ($d..($d + $num_ip - 1)) {
          if ($#msg > $max_ip) { 
            $err = "ERROR: Too many IPs returned ($#msg+)"; 
            last LOOP;
          }
          $ip = "$a.$b.$c.$d";
          if ($port) { push (@msg, "$ip:$port"); 
            } else { push (@msg, $ip); }
        }
      }
      # if the range appears to be part of a class B
    } elsif ($sub_c < 255 and $sub_c >= 0) {
      $num_ip = 256 - $sub_c; $num_sub = 256/$num_ip;
      if ($num_ip > $max_ip) {
        $err = "ERROR: Too many IPs returned ($num_ip)";
      } else {
        SUBNET: for $count_sub (0..($num_sub - 1)) {
          $start_sub = $count_sub * $num_ip;
          if ($c > $start_sub and $c < ($start_sub + $num_ip)) {
            $c = $start_sub;
            last SUBNET;
          }
        }
        LOOP: for $c ($c..($c + $num_ip - 1)) {
          for $d (0..255) {
            if ($#msg > $max_ip) { 
              $err = "ERROR: Too many IPs returned ($#msg+)"; 
              last LOOP;
            }
            $ip = "$a.$b.$c.$d";
            if ($port) { push (@msg, "$ip:$port"); 
              } else { push (@msg, $ip); }
          }
        }
      }
    }
  } elsif ($ip =~ /[\w\.]+/)  {
    print STDERR "$cli_exec ($$): DNS name $ip\n" if ($debug);
    if ($ip =~ /^(\w+)\[(\d{1,})\-(\d{1,})\]([\w\.]+)$/) {
      print "$1, $2, $3, $4\n" if ($debug);
      if ($3 <= $2) {
        return 0;
      } else {
        for $current ($2..$3) {
          my $ip = "$1$current$4";
          my ($name,$aliases,$type,$len,@thisaddr) = gethostbyname($ip);
          my ($a,$b,$c,$d) = unpack('C4',$thisaddr[0]);
          if ($a and $b and $c and $d) {
            if (CalculateIPRange("$a.$b.$c.$d")) {
              print STDERR "$cli_exec ($$): $ip points to $a.$b.$c.$d\n"
                if ($debug);
              $ip = "$a.$b.$c.$d";
              if ($port) { push (@msg, "$ip:$port"); 
                } else { push (@msg, $ip); }
            }
          } else {
            $err = "ERROR: Something appears to be wrong ($ip)";
          }
        }
      }
    } else {
      my ($name,$aliases,$type,$len,@thisaddr) = gethostbyname($ip);
      my ($a,$b,$c,$d) = unpack('C4',$thisaddr[0]);
      if ($a and $b and $c and $d) {
        if (CalculateIPRange("$a.$b.$c.$d")) {
          print STDERR "$cli_exec ($$): $ip points to $a.$b.$c.$d\n" 
            if ($debug);
          $ip = "$a.$b.$c.$d";
          if ($port) { push (@msg, "$ip:$port"); 
            } else { push (@msg, $ip); }
        }
      } else {
        $err = "ERROR: Something appears to be wrong ($ip)";
      }
    }
  # if it doesn't match one of those...
  } else {
    print STDERR "$cli_exec ($$): Not Recognised $ip\n" if ($debug);
    $err = "ERROR: Something appears to be wrong ($ip)";
  }
  if ($err and $return_error) { 
    return "$err\n"; 
  } elsif (@msg) {
    return @msg;
  } else {
    return;
  }
}

=pod

=item ($name, $mac) = NBTScan( $ipaddr, [$timeout, [$DEBUG]])

NBTScan takes 3 porrible paramiters and returns 5 vaules.
NetBIOS Name is the firect Item returned.
Second item is the MAC address
Third is the Username of the person logged in (this is a guess and mae be the amchine name).
Forth item returned is the domain or workgroup the box is a member of.
Last item is a comma sperated list of everything returned by the NBTSTAT packet from the machine being queried. The 3 fields returned per line are the Name returned, the description of what thet name reqpresnts and the "Group or Unique" field that denotes wether it is a domain/workgroup related item of local to the box.

    * $ipaddr
            The IP address you wish to scan. At this point only 
            IPv4 is supported and hostname will not be accepted. 
    * $timeout
            The number of seconds to wait for a reply before giving 
            up and moving on. 
    * $DEBUG
            DEBUG vaue is an integer from 1 to 3, 
            where 3 is the most verbose. 

=cut

sub NBTScan {
  $/ = CRLF;
  my ($ip, $timeout, $debug) = @_;
  my %group = (
               '04', 'UNIQUE', 
               '24', 'UNIQUE', 
               '44', 'UNIQUE', 
               'a4', 'GROUP',
               'c4', 'GROUP',
               '4c', 'UNIQUE_CONFLICT',
              );
  my %ident = (
              UNIQUE => {
                '00', 'Workstation/Redirector',
                '01', 'Browser',
                '02', 'Workstation/Redirector',
                '03', 'Messenger Service',
                '05', 'Forwarded Name',
                '06', 'RAS Server',
                '1b', 'Domain Master Browser',
                '1c', 'Domain Controler',
                '1d', 'Local Master Browser',
                '1e', 'Browser Election Service',
                '1f', 'NetDDE',
                '20', 'Server Service',
                '21', 'RAS Client',
                '22', 'MS Exchange Interchange',
                '23', 'MS Exchange Store',
                '24', 'MS Exchange Directory',
                '2b', 'Lotus Notes Server',
                '30', 'Modem Sharing Server',
                '31', 'Modem Sharing Client',
                '43', 'SMS Client Remote Control',
                '44', 'SMS Remote Control Tool',
                '45', 'SMS Client Remote Chat',
                '46', 'SMS Client Remote Transfer',
                '4c', 'DEC Pathworks TCPIP',
                '52', 'DEC Pathworks TCPIP',
                '6a', 'MS Exchange IMC',
                '87', 'MS Exchange MTA',
                'be', 'Netmon Agent',
                'bf', 'Netmon Analyzer',
                },
            GROUP => {
                '00', 'Domain Name',
                '01', 'Master Browser',
                '1c', 'Domain Controler',
                '1e', 'Browser Election Service',
                },
            UNIQUE_CONFLICT => {
                '00', 'Workstation/Redirector',
                '01', 'Browser',
                '02', 'Workstation/Redirector',
                '03', 'Messenger Service',
                '05', 'Forwarded Name',
                '06', 'RAS Server',
                '1b', 'Domain Master Browser',
                '1c', 'Domain Controler',
                '1d', 'Local Master Browser',
                '1e', 'Browser Election Service',
                '1f', 'NetDDE',
                '20', 'Server Service',
                '21', 'RAS Client',
                '22', 'MS Exchange Interchange',
                '23', 'MS Exchange Store',
                '24', 'MS Exchange Directory',
                '2b', 'Lotus Notes Server',
                '30', 'Modem Sharing Server',
                '31', 'Modem Sharing Client',
                '43', 'SMS Client Remote Control',
                '44', 'SMS Remote Control Tool',
                '45', 'SMS Client Remote Chat',
                '46', 'SMS Client Remote Transfer',
                '4c', 'DEC Pathworks TCPIP',
                '52', 'DEC Pathworks TCPIP',
                '6a', 'MS Exchange IMC',
                '87', 'MS Exchange MTA',
                'be', 'Netmon Agent',
                'bf', 'Netmon Analyzer',
                },
            );

  print STDERR "Marconi::NBTScan $ip\n" if ($debug > 1);
  # my $senddata = "\x01\x4d\x00\x10\x00\x01\x00\x00\x00\x00\x00\x00\x20\x43\x4b\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x00\x00\x21\x00\x01";
  my $senddata = "\x91\x87\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x20\x43\x4b\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x00\x00\x21\x00\x01";
  my $nbtdata ='';
  my $machinename ='';
  my $domain ='';
  my $user ='';
  my $mac = '';
  my $node = '';
  my @dump = ();

  eval {
    local $SIG{__WARN__};
    local $SIG{'__DIE__'} = "DEFAULT";
    local $SIG{'ALRM'} = sub { die "ERROR Time Out @rawdata" };
    print STDERR "Marconi::NBTScan Creating Socket $ip\n" if ($debug > 2);
    alarm($timeout);
    socket(SOCK, AF_INET, SOCK_DGRAM, getprotobyname('udp') )
      or die "Error: $!";
    my $dest_addr = sockaddr_in( '137', inet_aton($ip) );
    print STDERR "Marconi::NBTScan Sending Request $ip\n" if ($debug > 2);
    send(SOCK,$senddata,0,$dest_addr)
      or die "Error: $!";
    print STDERR "Marconi::NBTScan Receiving Data $ip\n" if ($debug > 2);
    recv(SOCK,$nbtdata,220,0)
      or die "Error: $!";
    close (SOCK);
    alarm(0);
  };
  if ($nbtdata and $@ !~ /^Error/) {
    if ($debug > 9) {
      my $i = 1;
      for (split '', $nbtdata) {
        print "$i . $_ - " . unpack('H*',$_) .  "\n";
        $i++;
      }
    }

    print STDERR "Marconi::NBTScan NBTScan Data returned\n"
      if ($debug > 2);
    $length = substr $nbtdata, 55, 1;
    $num_names = substr $nbtdata, 56, 1;
    $length = ord($length);
    $num_names = unpack('H*', $num_names);
    print STDERR "Marconi::NBTScan DataLength: $length - Entries: $num_names\n" 
      if ($debug > 2);
    for ($i=57; $i<(57+$num_names*17); $i+=18) {
      my $start = $i;
      my $info = $i + 15;
      my $type1_pos = $i + 16;
      my $name =  substr $nbtdata, $start, 15;
      $name =~ s/^([\w\-\~\$]+)\s*$/$1/g;
      my $info =  substr $nbtdata, $info, 1;
      my $type1 =  substr $nbtdata, $type1_pos, 1;
      # set the group first
      my $no_group = unpack('H*',$type1);
      $group = $group{$no_group};
      # Then set the item in the group
      my $no_info =  unpack('H*',$info);
      $info = $ident{$group}{$no_info};
      print STDERR "Marconi::NBTScan $i)$name - $info($no_info) - $group($no_group)\n" 
        if ($debug > 2);
      if ($no_group eq '24' and !$node) {
        push @dump, "NODE-TYPE, Point-to-Point Node, UNIQUE";
        $node = 1;
      } elsif ($no_group eq '44' and !$node) {
        push @dump, "NODE-TYPE, Mixed Node, UNIQUE";
        $node = 1;
      } elsif ($no_group eq '04' and !$node) {
        push @dump, "NODE-TYPE, Broadcast Node, UNIQUE";
        $node = 1;
      } elsif (!$node) {
        print "UNKNOWN NODE TYPE $no_group FROM $ip\n" if ($debug);
      }
      push @dump, "$name, $info, $group";
      $domain = $name if ($info eq 'Domain Name');
      $machinename = $name if ($info eq 'Workstation/Redirector' 
                                and !$machinename);
      $user = $name if ($info eq 'Messenger Service' and $name !~ /\$$/);
    }
    my $MAC0 = substr $nbtdata, $i, 1;
    my $MAC1 = substr $nbtdata, $i + 1, 1;
    my $MAC2 = substr $nbtdata, $i + 2, 1;
    my $MAC3 = substr $nbtdata, $i + 3, 1;
    my $MAC4 = substr $nbtdata, $i + 4, 1;
    my $MAC5 = substr $nbtdata, $i + 5, 1;
    $mac = unpack('H*', $MAC0) . "-" .
           unpack('H*', $MAC1) . "-" .
           unpack('H*', $MAC2) . "-" .
           unpack('H*', $MAC3) . "-" .
           unpack('H*', $MAC4) . "-" .
           unpack('H*', $MAC5);
  }
  print STDERR "Marconi::NBTScan NBTData $machinename\n"
    if ($debug and $machinename);
  print STDERR "Marconi::NBTScan NBTData $domain\n"
    if ($debug and $domain);
  print STDERR "Marconi::NBTScan MAC $mac\n"
    if ($debug and $mac);
  print STDERR "Marconi::NBTScan USER $user\n"
    if ($debug and $user);
  return ($machinename, $mac, $user, $domain, @dump);
}

######################################################################
#
#
#
##########################################
=pod

=item $rc = CheckPort( $ipaddr, $port, $proto, [$timeout, [$DEBUG]])

CheckPort takes 5 possible paramaters and returns a binary vaule. It 
will return true if the port is open and false if it is not. The 5 
vaules sent are IP address, port, protocol by name, timeout in seconds 
and a debug vaule.

    * $ipaddr
            The IP address you wish to scan. At this point only IPv4 
            is supported and hostname will not be accepted. 
    * $port
            The port you wish to scan. Valid port are 1-65535, 
            0 is not supported at this time. 
    * $proto
            'TCP' or 'UDP' 
    * $timeout
            The number of seconds to wait for a reply before giving 
            up and moving on. 
    * $DEBUG
            DEBUG vaue is an integer from 1 to 3, 
            where 3 is the most verbose. 

=cut

sub CheckPort {
  # sent IP, port, proto('byname') and timeout
  # returns 1 or 0, 1 for open, 0 for not open
  my($ip, $port, $proto, $timeout,$debug) = @_;
  $0 = "Marconi::CheckPort $ip:$port - PortScan";
  print STDERR "$cli_exec ($$): $ip:$port - PortScan\n"
    if ($debug);
  my $p_addr = sockaddr_in($port, inet_aton($ip) );
  my $type;
  my $exitstatus;
  if ($proto =~ /^udp$/i) {
    $type = SOCK_DGRAM;
  } elsif ($proto =~ /^tcp$/i) {
    $type = SOCK_STREAM;
  }
  print STDERR "$cli_exec ($$): creating socket ($ip, $port, $proto)\n"
    if ($debug > 1);
  ##################################################################
  eval {
    local $SIG{__WARN__};
    local $SIG{'__DIE__'} = "DEFAULT";
    local $SIG{'ALRM'} = sub { die "Timeout Alarm" };
    socket(TO_SCAN,PF_INET,$type,getprotobyname($proto))
      or die "Error: Unable to open socket: $@";
    alarm($timeout);
    print STDERR "$cli_exec ($$): connecting to port $port on $ip\n"
      if ($debug > 1);
    connect(TO_SCAN, $p_addr)
      or die "Error: Unable to open socket: $@";
    close (TO_SCAN);
    alarm(0);
  };
  if ($@ =~ /^Error:/) {
    print STDERR "$cli_exec ($$): Unable to connect to $port on $ip\n"
      if ($debug > 1);
    $exitstatus = 0;
  } elsif (!$@) {
    print STDERR "$cli_exec ($$): $port on $ip is open\n"
      if ($debug > 1);
    $exitstatus = 1;
  }
  print STDERR "$cli_exec ($$): Returning ($exitstatus)\n"
    if ($debug > 1);
  return($exitstatus);
}

######################################################################
#
#
#
##########################################
=pod

=item $content = RawRequest( $ipaddr, $port, $request, [$timeout, [$ssl, [$DEBUG]]])


RawRequest takes 6 possible paramaters and returns a string for success 
and nothing for failure. The 6 values sent are IP address, port, request, 
timeout, ssl and a debug value.

    * $ipaddr
            The IP address you wish to scan. At this point only IPv4 
            is supported and hostname will not be accepted. 
    * $port
            The port you wish to send the request to. Valid port are 
            1-65535, 0 is not supported at this time. 
    * $request
            The request can be a simple newline, or a full HTTP 
            request or something more complicated like HEX values 
            for binary. 
    * $timeout
            The number of seconds to wait for a reply before giving 
            up and moving on. 
    * $ssl
            If set to true, SSL will be used. Specifically 
            Net::SSLeay:sslcat is the function used. 
    * $DEBUG
            DEBUG vaue is an integer from 1 to 3, 
            where 3 is the most verbose. 

=cut

sub RawRequest {
  my ($ip, $port, $request, $timeout, $ssl, $debug) = @_;
  my $rawdata = @rawdata = ();
  my $senddata = "$request\r\n\r\n";
  my $EOT = "\015\012";
  print STDERR "$cli_exec ($$): RAW request of '$request' being sent\n"
    if ($debug > 1);
  if ($ssl) {
    print STDERR "$cli_exec ($$): RAW request using Net::SSLeay\n"
      if ($debug > 1);
    eval {
      local $SIG{__WARN__};
      local $SIG{'__DIE__'} = "DEFAULT";
      local $SIG{'ALRM'} = sub { die "Timeout Alarm" };
      alarm($timeout);
     $rawdata = sslcat($ip, $port, $senddata);
      alarm(0);
    };
    print STDERR "$cli_exec ($$): $rawdata\n"
      if ($debug > 2);
  } else {
    eval {
      local $SIG{__WARN__};
      local $SIG{'__DIE__'} = "DEFAULT";
      local $SIG{'PIPE'}='IGNORE';
      local $SIG{'ALRM'} = sub { die (join '', @rawdata) };
# die "Timeout Alarm" };
      alarm($timeout);
      print STDERR "$cli_exec ($$): Creating RAW Socket\n"
        if ($debug > 1);
      socket(SOCK, AF_INET, SOCK_STREAM, getprotobyname('tcp') ) ;
      my $dest_addr = sockaddr_in( $port, inet_aton($ip) );
      print STDERR "$cli_exec ($$): Connection to RAW Socket\n"
        if ($debug > 1);
      connect(SOCK, $dest_addr) or die ($!);
      print STDERR "$cli_exec ($$): Sending request to RAW Socket\n"
        if ($debug > 1);
      send(SOCK,$senddata,0,$dest_addr) or die ($!);
      print STDERR "$cli_exec ($$): Reading response from RAW Socket\n"
        if ($debug > 1);
      READSOCK: while (!eof(SOCK)) {
        read(SOCK,$rawdata,1);
        push @rawdata, $rawdata;
        if ($senddata =~ /RTSP/
              and $rawdata eq "\n"
              and $rawdata[-2] eq "\r"
              and $rawdata[-3] eq "\n"
              and $rawdata[-4] eq "\r"
           ) {
          die (join '', @rawdata);
        }
      }
      print STDERR "$cli_exec ($$): Closing RAW Socket\n"
        if ($debug > 1);
      close (SOCK);
      alarm(0);
      $rawdata = join('', @rawdata);
    };
  }
  if ($@) {
    if ( $@ =~ /Server:/ or $@ =~ /SMTP/ ) {
      $rawdata = $@;
    } else {
      $rawdata = '.';
    }
    print STDERR "$cli_exec ($$): RAW request error ($@)\n"
      if ($debug > 1);
  }
  $raw_length = length($rawdata);
  print STDERR "$cli_exec ($$): RAW RETURN ($raw_length bytes)\n"
    if ($debug > 1);
  print STDERR "$cli_exec ($$): $rawdata\n\n"
    if ($debug > 2);
  return ($rawdata);
}

=pod

=item $content = swrite($format, @strings);

Stolen directly from the perlform perldoc page.

    $string = swrite(<<'END', 1, 2, 3);
  Check me out
  @<<<  @|||  @>>>
  END
    print $string;

=cut

sub swrite {
  my ($format,@strings) = @_;
  $^A = "";
  formline($format,@strings);
  return $^A;
}

=pod

=head1 COPYRIGHT

  Copyright 2003, MadHat (at) Unspecific.com

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AVAILABILITY

The latest version of this library is available from: 

  http://www.unspecific.com/marconi/

=cut


1;



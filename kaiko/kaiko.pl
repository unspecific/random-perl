use strict;
use vars qw(%IRSSI %conf $LOG $LOGFILE $DEBUG $md5 $c_md5 %last
           $self $VERSION $md5_cmd %memory);

use Irssi qw(command_bind signal_add);
use POSIX "strftime";
use LWP::Simple;
use FileHandle;
use Socket;

my $dict_server = "dict.org";
my $dict_port   = 2628;

%IRSSI = (
  author        => 'MadHat Unspecific',
  contact       => 'madhat@unspecific.com',
  name          => 'Kaiko',
  descriotion   => 'The entertaining SILC bot.',
  version       => '.25',
  license       => 'GPL',
);

# md5 command
# Linux
$md5_cmd = '/usr/bin/md5sum';
# FreeBSD
# $md5_cmd = '/sbin/md5 -q';

load_conf("$ENV{HOME}/.silc/kaiko.conf");
load_memory();
$| = 42;
if ($conf{config}{log} and $conf{config}{logfile}[0]) {
  $LOG = 1;
}
if ($conf{config}{debug} and $conf{config}{logfile}[0]) {
  $DEBUG = 1;
  $LOG = 1;
}

if ($LOG) {
  open(LOG,">>$conf{config}{logfile}[0]") or die ("Unable to open log($conf{config}{logfile}[0]):$!");
  my $now = strftime "%X %D", localtime;
  print LOG "[$now] Kaiko Initialized\n";
}

$md5 = `$md5_cmd $ENV{HOME}/.silc/scripts/kaiko.pl`;
$c_md5 = `$md5_cmd $ENV{HOME}/.silc/kaiko.conf`;
chomp $md5;
chomp $c_md5;
add_log("MD5 => $md5") if ($DEBUG);
add_log("Conifg_MD5 => $c_md5") if ($DEBUG);

add_log("Adding Signals") if ($DEBUG);
signal_add("message public", "public_message");
signal_add("message private", "private_message");
signal_add("message join", "join");
signal_add("gui print text","check_output");

sub load_conf {
  my ($file) = @_;
  my $group = '';
  add_log('Clearing Config') if ($LOG);
  undef %conf;
  open(CONF, $file) or die ("Unable to open config($file): $!");
  while(<CONF>) {
    chomp;
    next if (/^#/ or /^\s*$/);
    if (/^\[([\w\:\#\!]+)\]/) {
      $group = $1;
    } elsif ($group) {
      my ($key, $value) = split('=');
      if ($value =~ /^([\w\s\-\,\:]*)\<([^\>]+)\>$/) {
        my $intro = $1;
        my $file = $2;
        if (-e $file) {
          $file = $file;
        } elsif (-e "$ENV{HOME}/.silc/$file") {
          $file = "$ENV{HOME}/.silc/$file";
        } else {
          $file = '';
        }
        if ($file) {
          open(FH, $file) or die("Unable to open config($file): $!");
          my @data = <FH>;
          close(FH);
          if ($data[0] eq "\%\n") {
            my $c = -1;
            my $entry = "$intro\n";
            my @fort = ();
            for my $line (@data) {
              $line =~ s/\t/  /g;
              if ($line eq "\%\n") {
                push @fort, $entry;
                $c++;
                $entry = "$intro\n";
              } else {
                $entry .= $line;
              }
            }
            chomp @fort;
            push @{$conf{$group}{$key}}, @fort;
          } else {
            chomp @data;
            push @{$conf{$group}{$key}}, @data;
          }
        }
      } else {
        push @{$conf{$group}{$key}}, $value;
      }
    }
  }
  close(CONF);
  $self = $conf{config}{nick}[0];
  $VERSION = $conf{config}{version}[0];
}

sub add_log {
  my ($log) = @_;
  my $now = strftime "%X %D", localtime;
  print LOG "[$now] $log\n";
}

sub public_message { 
  my ($server, $msg, $nick, $address, $channel) = @_;
  add_log("public_message => $msg, $nick, $address, $channel") if ($DEBUG);
  $memory{$nick}{'last'} = localtime;
  $memory{channels}{$channel} = $last{'message'} = time;
  if ($msg =~ /^$self sleep (\d+)$/) {
    if (!$memory{'sleep_till'}) {
      my $sleep = $1;
      if ($sleep > 0 and $sleep < 30) {
        $memory{'sleep_till'} = time + ($sleep * 60);
        for my $ch (sort keys %{$memory{channels}}) {
          if ($sleep == 1) {
            $server->command("action -channel $ch decides to sleep for $sleep minute");
          } else {
            $server->command("action -channel $ch decides to sleep for $sleep minutes");
          }
        }
        return 0;
      } else {
        $server->command("action -channel $channel decides that she can't sleep that long");
      }
    } else {
      my $tleft = $memory{'sleep_till'} - time;
      if ($tleft > 60) {
        my $mleft = int($tleft/60);
        if ($mleft == 1) {
          $server->command("action -channel $channel will wake up in about $mleft minute");
        } else {
          $server->command("action -channel $channel will wake up in about $mleft minutes");
        }
      } else {
        $server->command("action -channel $channel will wake up in $tleft seconds");
      }
    }
  }
  if ($memory{'sleep_till'}) {
    if ($memory{'sleep_till'} < time) {
      undef $memory{'sleep_till'};
    } else {
      return 0;
    }
  }
  $address =~ /\@(.+)$/;
  $memory{$nick}{'from'} = $1;
  if ($msg =~ /^$self version$/) {
    $server->command("action -channel $channel is Version $VERSION");
    return 0;
  }
  if ($msg =~ /^$self broadcast (.*)$/) {
    my $message = $1;
    for my $ch (sort keys %{$memory{channels}}) {
      $server->command("action -channel $ch heard $message");
    }
    return 0;
  }
  if ($msg =~ /^$self info (\S+)$/) {
    my $user = $1;
    if ($memory{$user}) {
      $server->command("action -channel $channel last saw $user on $memory{$user}{last} from $memory{$user}{from}");
    }
    return 0;
  }
  if ($msg =~ /^$self define ([\"\w\-\s\']+)/) {
    my $word = $1;
    my $def = define($word, 'wn');
    if ($def) {
      $server->command("action -channel $channel has been told '$word' means\n $def");
    } else {
      $server->command("action -channel $channel doesn't know what '$word' means");
    }
    return 0;
  }
  if ($msg =~ /^$self jargon ([\"\w\-\s\']+)/) {
    my $word = $1;
    my $def = define($word, 'jargon');
    if ($def) {
      $server->command("action -channel $channel has been told '$word' means\n $def");
    } else {
      $server->command("action -channel $channel doesn't know what '$word' means");
    }
    return 0;
  }
  if ($msg =~ /^$self reload$/) {
    reload($server, $nick);
    return 0;
  }
  #
  # responses from the conf file
  #
  for my $match (keys %{$conf{responses}}) {
    my $key = $match;
    $match =~ s/\$self/$self/g;
    if ($msg =~ /$match/i) {
      my $quote = $conf{responses}{$key}[int(rand(@{$conf{responses}{$key}}))];
      $nick =~ s/^([^\@]+)\@?.*$/$1/;
      $quote =~ s/\$nick/$nick/g;
      $server->command("action -channel $channel $quote");
      return 0;
    }
  }
  if ($msg =~ /^([\'\w\s\-\_]+) (is|are) ([\w\s\-\_\'\"\;\,\.\:\!]+)/) {
    my $a = $1;
    my $c = $2;
    my $b = $3;
    if ($a =~ /^(who|what)\s*$/i and $memory{$c}{$b}) {
      $server->command("action -channel $channel heard $b $c $memory{$c}{$b}");
    } else {
      # $server->command("action -channel $channel wonders why $a is $b ");
      if ($nick ne $a) {
        add_log("'$a' $c '$b'") if ($DEBUG);
        $memory{$c}{$a} = $b;
      } else {
        $server->command("action -channel $channel thinks $nick should stop talking about themselves");
      }
    }
  }
}

# what to do when people join the channel
#
sub join {
  my ($server, $channel, $nick, $user) = @_;
  # return if ($nick eq $self);
  $last{'server'} = $server;
  $last{'channel'} = $channel;
  $last{'nick'} = $nick;
  $server->command("whois $nick");
  if ($conf{config}{welcome} and $nick ne $self) {
    my $welcome = $conf{config}{welcome}[int(rand(@{$conf{config}{welcome}}))];
    $welcome =~ s/\$nick/$nick/g;
    $welcome =~ s/\$channel/$channel/g;
    $server->command("action -channel $channel $welcome");
  } elsif ($nick eq $self) {
    $server->command("action -channel $channel steps up to the bar");
  }
}

# Sub will check everythng that is printed to the local window
#
sub check_output {
  my ($window, $a, $b, $c, $text, $dest) = @_;
  my $now = time;
  if ($text =~ /\*\*\*  nickname    : (\S+) \((\S+)\)/) {
    $last{'nick'} = $1;
    $last{'anick'} = $2;
  }
  add_log("DEBUG $text") if ($DEBUG);
  if ($text =~ /\*\*\*  fingerprint : (.+)$/) {
    my $fingerprint = $1;
    add_log("FINGERPRINT $last{'nick'} $fingerprint") if ($DEBUG);
    my $cur_nick = $last{'nick'};
    $cur_nick =~ s/^(\S)\@.*$/$1/;
    if (!$memory{$cur_nick}{fingerprint}) {
      $memory{$cur_nick}{fingerprint} = $fingerprint;
    } elsif ($fingerprint ne $memory{$cur_nick}{fingerprint}) {
      $last{'server'}->command("action -channel $last{'channnel'} YELLS $last{'nick'} IS AN IMPOSTOR (maybe?)");
    }
    add_log("CHECK AUTO-OP $last{'nick'} $last{'channel'} ") if ($DEBUG);
    if ($fingerprint eq $conf{"ops:$last{'channel'}"}{$cur_nick}[0] or
        $fingerprint eq $conf{"ops:all"}{$cur_nick}[0]) {
      add_log("OPing $last{'nick'} on $last{'channel'}") if ($DEBUG);
      $last{'server'}->command("CUMODE $last{'channel'} +o $last{'anick'}");
    } else {
      # add_log("NOT-OPing $last{'nick'} on $last{'channel'} $fingerprint ne . " $conf{"ops:$last{'channel'}"}{$cur_nick}[0]) 
        # if ($DEBUG);
    }
  }
}

sub private_message {
  my ($server, $message, $nick, $address) = @_;
  if ($message eq 'dump conf') {
    for my $key (sort keys %conf) {
      $server->command("msg $nick $key");
      for my $nkey (sort keys %{$conf{$key}}) {
        $server->command("msg $nick `-$nkey");
        for my $sub (@{$conf{$key}{$nkey}}) {
          $server->command("msg $nick   `-$sub");
        }
      }
    }
    return 0;
  }
  if ($message =~ /^broadcast (.*)$/) {
    my $msg = $1;
    for my $ch (sort keys %{$memory{channels}}) {
      $server->command("action -channel $ch heard $msg");
    }
    return 0;
  }
  if ($message =~ /^dump memory ?(.*)$/) {
    if (my $item = $1) {
      return if (!$memory{$item});
      $server->command("msg $nick dumping memory $item");
      for my $nkey (sort keys %{$memory{$item}}) {
        if ($nkey and $memory{$item}{$nkey}) {
          $server->command("msg $nick `-$nkey=$memory{$item}{$nkey}");
        }
      }
    } else {
      $server->command("msg $nick dumping memory");
      for my $key (sort keys %memory) {
        $server->command("msg $nick $key");
        for my $nkey (sort keys %{$memory{$key}}) {
          $server->command("msg $nick `-$nkey=$memory{$key}{$nkey}");
        }
      }
    }
    return 0;
  }
  if ($message eq 'flush memory') {
    $server->command("msg $nick flushing memory");
    undef %memory;
    return 0;
  }
  if ($message =~ /^reload$/) {
    reload($server, $nick);
    return 0;
  }
  if ($message =~ /^(hello|hi|howdy|hola)$/) {
    $server->command("msg $nick $message");
    return 0;
  }
  if ($message eq 'save memory') {
    $server->command("msg $nick saving my memory");
    save_memory();
    return 0;
  }
  if ($message eq 'load memory') {
    $server->command("msg $nick loading my memory from last dump");
    load_memory();
    return 0;
  }
  if ($message eq 'help') {
    $server->command("msg $nick Private Message Commands:
- join #channel [passwd]
  To invite $self to #channel
  She will join and add the person who invited her to her auto op 
    list to that channel.
  You can invite her to a channel, op her and leave, and when you come back, 
    she will auto-op you, keeping the channel open

- leave #channel
  To make $self leave a channel
  Can only be done by the person that did the invite (by fingerprint)

-op #channel user
  To make $self op user on #channel, if they have the rights or you 
    have op rights for that channel in the config
    anonymous ops?

- quote <STK>
  To display current stock quote of <STK> from Yahoo Finance

- define <WORD>
 To display the MW definition of <WORD>

- jargon <WORD>
 To display the jargin file entry for <WORD>

- broadcast message here
  To display a message to all channels $self is currently on.
  * $self heard message here
  NOTE:  Don't abuse or it will be removed


In #channel Command
- $self version
  To display the current version of Kaiko, as defined in the config file

- $self info <user>
  To display the last known info about a user
  * $self last saw <user> on <date>  from <host>

- $self broadcast message here
  To display a message to all channels $self is currently on.
  * $self heard message here

- $self define
 To display the MW definition of WORD to the channel

- $self jargon
 To display the jargon file entry for WORD to the channel

- who/what is ...?
  as $self listens to the channel, she picks up bits of info
  She will tell if she has heard anything  about the subject

- $self sleep <min>
 To make $self not respond to anything in public channels for <min> minutes
 Issueing a sleep command while $self is asleep will tell you how long until
    $self wakes up
");
    $server->command("msg $nick and overall, I try and be witty");
    return 0;
  }
  if ($message =~ /^join (\#\!?[\w\.\-\s]+)$/) {
    my $ch = $1;
    if (!$memory{$ch}{invite}) {
      $server->command("msg $nick joining $ch");
      $memory{$ch}{invite} = $memory{$nick}{fingerprint};
      $server->command("join $ch");
      $server->command("whois $nick");
      $server->command("msg $nick");
      $conf{"ops:$ch"}{$nick}[0] = $memory{$nick}{fingerprint};
      add_log(" SET AUTO-OP $nick $ch " 
        . $conf{"ops:$last{'channel'}"}{$nick}[0]) if ($DEBUG);
    } else {
      $server->command("msg $nick I ahve already been invited to $ch");
    }
    return 0;
  }
  if ($message =~ /^leave (\#\!?[\w\.\-]+)$/) {
    my $ch = $1;
    if ($memory{$ch}{invite} eq $memory{$nick}{fingerprint}) {
      $server->command("msg $nick leaving $ch");
      $server->command("leave $ch");
      $memory{$ch}{invite} = '';
    } else {
      $server->command("msg $nick I am not leaving $ch");
      $server->command("msg $nick you can't tell me what to do");
    }
    return 0;
  }
  if ($message =~ /^quote ([\w\.\-]+)/) {
    my $res = get("http://finance.yahoo.com/d/quotes.csv?s=$1&f=sl1d1t1c1ohgvp&e=.csv");
    $res =~ s/"//g;
    my ($sym, $last, $c_date, $c_time, $change, $open, $high, $low, $volume, $prev ) = split( /,/, $res );
    if ($last eq '0.00') {
      $server->command("msg $nick $sym does not appear to be a valid stock ticker");
    } else {
      $server->command("msg $nick $sym was last trading at $last on $c_date at $c_time with a change of $change");
    }
    return 0;
  }
  if ($message =~ /^op (\S+) (\S+)/) {
    my $ch = $1;
    my $op = $2;
    if (
       $memory{$nick}{fingerprint} eq $conf{"ops:$ch"}{$nick}[0] or
       $memory{$op}{fingerprint} eq $conf{"ops:$ch"}{$op}[0] or
       $memory{$op}{fingerprint} eq $conf{"ops:all"}{$op}[0] 
        ) {
      add_log("OPing $op on $ch per $nick") if ($DEBUG);
      $server->command("CUMODE $ch +o $op");
    }
    return 0;
  }
  if ($message =~ /^define ([\"\w\-\s\']+)/) {
    my $word = $1;
    my $def = define($word, 'wn');
    if ($def) {
      $server->command("msg $nick according to WordNet, $def");
    } else {
      $server->command("msg $nick sorry, don't know what '$word' means");
    }
    return 0;
  }
  if ($message =~ /^jargon ([\"\w\-\s\']+)/) {
    my $word = $1;
    my $def = define($word, 'jargon');
    if ($def) {
      $server->command("msg $nick $def");
    } else {
      $server->command("msg $nick sorry, don't know what '$word' means");
    }
    return 0;
  }
  if ($nick ne $self) {
    $server->command("msg $nick I don't understand, but I am limited right now");
  }
}

sub save_memory {
  my $mem = $conf{config}{memory}[0];
  if ($mem !~ /^\//) {
    $mem = "$ENV{HOME}/.silc/$mem";
  }
  open(MEM,">$mem");
  print MEM "# This File Should Not Be Edited\n";
  for my $key (sort keys %memory) {
    print MEM "[$key]\n";
    for my $nkey (sort keys %{$memory{$key}}) {
      print MEM "$nkey=$memory{$key}{$nkey}\n";
    }
    print MEM "\n";
  }
  close(MEM);
}

sub load_memory {
  my $mem = $conf{config}{memory}[0];
  if ($mem !~ /^\//) {
    $mem = "$ENV{HOME}/.silc/$mem";
  }
  open(MEM,"$mem") or add_log("ERROR Opening MEMORY($mem): $!");
  my @memory = <MEM>;
  close(MEM);
  my $group = '';
  for my $line (@memory) {
    chomp $line;
    add_log("MEM: $line");
    next if ($line =~ /^#/ or $line =~ /^\s*$/);
    if ($line =~ /^\[(\S+)\]/) {
      $group = $1;
    } elsif ($group) {
      my ($key, $value) = split('=', $line);
      $memory{$group}{$key} = $value;
    }
  }
}
sub reload {
  my ($server, $nick) = @_;
  my $md51 = `$md5_cmd  $ENV{HOME}/.silc/scripts/kaiko.pl`;
  my $c_md51 = `$md5_cmd $ENV{HOME}/.silc/kaiko.conf`;
  chomp $md51;
  chomp $c_md51;
  add_log("Check MD5 => $md51") if ($DEBUG);
  add_log("Check Conifg_MD5 => $c_md51") if ($DEBUG);
  if ($md5 ne $md51) {
    save_memory();
    $server->command("run kaiko.pl");
    $server->command("msg $nick ok, I reloaded my brains from source");
    return 0;
  }
  if ($c_md5 ne $c_md51) {
    load_conf("$ENV{HOME}/.silc/kaiko.conf");
    $server->command("msg $nick ok, I reloaded my personality");
    return 0;
  }
  $server->command("msg $nick ummm, I don't need to reload");
  return 0;
}

sub define {
  my ($word, $dict) = @_;
  my @cmdlist;
  push(@cmdlist, "CLIENT kaiko\@unspecific.com");
  push(@cmdlist, "DEFINE $dict $word");
  push(@cmdlist, "QUIT");
  my ($name, $aliases, $type, $len, $iaddr) = gethostbyname($dict_server);
  my $sockaddr = 'S n a4 x8';
  my $paddr = pack( $sockaddr, AF_INET, $dict_port, $iaddr );
  my $proto  = getprotobyname('tcp');
  socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
  connect(SOCK, $paddr)                      || die "connect: $!";
  select(SOCK); $| = 1; select(STDOUT); $| = 1;
  foreach my $i (@cmdlist) {
    print SOCK "$i\r\n";
  }
  my $data = '';
  my $buf = '';
  while ($buf !~ /221 /) {
    recv(SOCK, $buf, 4096, 0);
    $data .= $buf;
  }
  my @data = split(/\r\n/,$data);
  $data = '';
  for my $line (@data) {
    if ($line !~ /^\d{3}/ and $line ne '.' and $line ne '') {
       $line =~ s/[\{\}]//g;
       $data .= "$line\n";
    }
  }
  close(SOCK)                                || die "close: $!";
  return $data;
}

<a name=top></a>
# route_detector.pl

<center>How many routes out of your network can you find?<br><br>
<b>Latest Version is: 0.9</b><br><br>
</center>
<blockquote>
If you want information about new releases mailed to you, or have any suggestions, please contact <a href=mailto:madhat@unspecific.com>me</a>.<br><br>
</blockquote>

<br clear=all>
<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>

<a name=desc></a>
<h2>Description</h2>
<blockquote>
Written by: <a href=mailto:madhat@unspecific.com>MadHat at Unspecific.com</a><br><br>
This scanner is intended to detect multi-homed boxes on a secured
network. Signed ICMP packets are sent with spoofed source IPs to hosts
on an internal, protected network. On the box where the spoofed IP is,
the listener watches for the ICMP packet. The ICMP data is the IP
address you are testing (the target on the inside network) and a MD5
hash of a secret and that same IP. In listen mode it takes the IP in
the data field and the secret (specified on command line) and compares
the hash. If it matches, then it knows it is a packet it is supposed
to pay attention to. If the IP in the data field does not match the IP
in the source address from the IP headers, it displays the
information. On machines that are behind a NATed device they are all
flagged. If you have several machines they will all have the same IP,
so it is easy to determine if one if dual homed, since it will be the
one that does not match the rest. If you are using a stateful
firewall, it will usually block all echo-replies, having not seen
the echo-request.
<br><br>
</blockquote>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=feat></a>
<h2>Features</h2>
<ul>
  <li> Command line 'key' to verify packets
  <li> Timed listening (for automation/croned scanning)
  <li> Max Packets, so it exists after receiving X number of packets, if there is no timeout set.
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=bugs></a>
<h2>BUGS</h2>
<blockquote>
Send your bugs to <a href=mailto:bugs@unspecific.com>Bugs at Unspecific.com</a><br><br>
With newer Linux kernels, we are seeing some issues with Net::RawIP.  Here is an entry from someone else's FAQ that addresses the issue, but it is not working for me. ;)
<pre>
Q: I get sendto() at /usr/local/lib/perl/5.8.2/Net/RawIP.pm line 550?
A: You are not allowed to send the constructed packet. Please check if you
are running a packet filtering program (Linux: iptables -L or ipchains -L / 
FreeBSD: ipfw list). If that's not the case and you are trying to send an
icmp redirect packet check if your system allows you to send redirect
messages e.g. look at /proc/sys/net/ipv4/conf/all/*redirect or at
sysctl net.ipv4.conf.default.send_redirects. 
Try sysctl -w net.inet.icmp.drop_redirect=0 under FreeBSD.
</pre>
With my testing, if you avoid the broadcast IP of your local subnet and the network address, it works fine.<br><br>
for example, if I am on 192.168.1.7 on a /24, and I scan 192.168.1.1-254 it works fine, but if I include .0 or .255 in this example I get the error. 

</blockquote>
<ul>
  <li> Can not scan network or broadcast address of the machine it is running from. ('Feature' of Net::RawIP)
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=todo></a>
<h2>ToDo</h2>
<ul>
  <li> Added forking to scan faster.  Easy, just need to add the code.
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=requi></a>
<h2>Requirements</h2>
<ul>
  <li><a href=http://www.perl.com>Perl</a> >= 5.6 <br>
  <li><a href=http://search.cpan.org/search?dist=Net-RawIP>Net::RawIP</a><br>
  <li><a href=/marconi>Marconi</a> More details to come.  For now, just download to same directory you are running the Sender from<br>
</ul>


<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=down></a>
<h2>Download</h2>
<ul>
  <li><a href=route_detector.pl>route_detector.pl</a> v0.9 - the script itself
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=out></a>
<h2>Output</h2>
<blockquote>
<b>Listener</b>
<pre>
$ sudo ./route_detector.pl -v -l -k unspecific
Route Detector v0.1 by MadHat (at) Unpsecific.com
Packet Received from: 192.168.100.3
Original IP Sent to:  192.168.1.0
WARNING: Packet came back from 192.168.100.3, but was sent to 192.168.1.0
Packet Received from: 192.168.1.1
Original IP Sent to:  192.168.1.1
Packet Received from: 192.168.1.3
Original IP Sent to:  192.168.1.3
^C
</pre>
<br><br>
<b>Sender</b>
<pre>
$ sudo ./route_detector.pl -v -k unspecific -s 172.21.1.56 -d 192.168.1.0/24
Route Detector v0.6 by MadHat (at) Unpsecific.com
scanning 192.168.1.0/24
Sending Packets to 255 IPs
Sending to 192.168.1.0
Sending to 192.168.1.1
Sending to 192.168.1.2
Sending to 192.168.1.3
^C
</pre>
</blockquote>
<br><br><h2>NON-Verbose w/ NATed hosts</h2>
<blockquote>
<b>Listener</b>
<pre>
$ sudo ./route_detector.pl -l -k unspecific
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.0
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.1
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.6
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.9
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.11
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.12
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.16
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.18
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.20
WARNING: Packet came back from 172.16.0.1, but was sent to 192.168.3.21
^C
</pre>
<br><br>
<b>Sender</b>
<pre>
$ sudo ./route_detector.pl -k unspecific -s 172.21.1.56 -d 192.168.3.0/24
Sending Packets to 255 IPs
^C
</pre>
</blockquote>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=use></a>
<h2>Usage (output from ./http-scan.pl -h)</h2>
<blockquote>
<pre>
$ ./route_detector.pl
Must have EUID == 0 to use Net::RawIP at ./route_detector.pl line 36
MUST BE RUN AS ROOT
Route Detector v by MadHat (at) Unpsecific.com
Usage:
./route_detector.pl -l | -d &lt;remote_ip> [-s &lt;source_ip>] [-v] [-k key]\
        [-t &lt;sec>] [-c &lt;pact_count>] [-S &lt;sec_delay> ]

    -l  Listen Mode  Sniffing for ICMP packets and looking for the right data.
    -d &lt;remote_ip>   Send Mode, sending 'signed' ICMP packets to &lt;remote_ip>
    -s &lt;source_ip>   Spoofed Source IP, to be used with -d
    -k &lt;key>         Key used to 'sign' the data in the ICMP packet
    -i &lt;interface>   Interface, default eth0
    -t &lt;sec>         Number of seconds to listen (-l) before exiting
    -S &lt;sec_delay>   Number of seconds to wait (0) between each packet
    -c &lt;pact_count>  Number of packets to listen for (-l) before exiting
    -v  Verbose      Add moe info about what is going on


</pre>
</blockquote>
<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=goals></a>
<h2>Goals</h2>
<ol>
   <li>
</ol>
<br><br>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=change></a>
<h2>Change Log</h2>
<ul> 
  <li><b>0.9</b>
  <ul>
    <li> Changed the output layout on verbose mode (-v)
    <li> Output in Verbose mode (-v) now includes DNS entry of both target and resonder
    <li> Added "Time" to verbose mode (-v) telling the number of seconds it took for the packet to make it's journey.  
    <br> Time must be synced on both source and dest hosts if they are not the same host to be accurate.
    <br> I recommend using <a href=http://www.ntp.org/>NTP</a>
  </ul>
  <li><b>0.8</b>
  <ul>
    <li> Increased the speed by making the time between packets setable via the command-line (-S), default is 0
    <li> I like incrementsing on simple things... ;^)
  </ul>
  <li><b>0.7</b>
  <ul>
    <li> Added DNS lookups with Verbose listening
    <li> Removed some other data in Verbose listening
  </ul>
  <li><b>0.6</b>
  <ul>
    <li> First public release
  </ul>
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>

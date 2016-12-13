<a name=top></a>
<br><br>

# nbtscan.pl
<center>If you want information about new releases mailed to you,<br> or have any suggestions, please contact <a href=mailto:madhat@unspecific.com>me</a>.</center><br>
<b>Latest Version is: 0.4</b>

<br clear=all>
<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>

<a name=desc></a>
<h2>Description</h2>
Written by: <a href=mailto:madhat@unspecific.com>MadHat at Unspecific.com</a><br>
This is a simple script that uses <a href=/marconi/>Marconi</a> to scan a range 
of hosts for their NetBIOS name and MAC address.  UDP port 137 must be open 
for it to work.
<br><br>
</blockquote>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=feat></a>
<h2>Features</h2>
<ul>
  <li> Simple NetBIOS scanning useing Perl
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=bugs></a>
<h2>BUGS</h2>
Send your bugs to <a href=mailto:bugs@unspecific.com>Bugs at Unspecific.com</a><br>
<ul>
  <li> Marconi doesn't always return the User logged in correctly.  This is because of the lack of info in the NBTSTAT packet.
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
  <li><a href=/marconi/>Marconi</a> Just download to same directory you are running nbtscan.pl from<br>
</ul>


<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=down></a>
<h2>Download</h2>
<ul>
  <li><a href=nbtscan.pl>nbtscan.pl</a> v0.4 - the script itself<br><br>
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=out></a>
<h2>Output</h2>
<pre>
$ ./nbtscan.pl -v 192.168.10.172/24
NBTScan v0.3 by MadHat (at) Unpsecific.com
scanning 192.168.10.172/24
IP Address       Host Name        Mac Address         User           Domain
-------------------------------------------------------------------------------
192.168.10.19    DODO             00-08-00-00-00-bc   MADHAT         WONDERLAND
192.168.10.20    MADHAT           00-b0-00-00-00-41   MADHAT         WONDERLAND
192.168.10.23    ALICE            00-b0-00-00-00-04   ALICE          WONDERLAND
192.168.10.25    JABERWOCKY       00-b0-00-00-00-7c   ADMINISTRATOR  WONDERLAND
192.168.10.27    HUMPTY           00-b0-00-00-00-df   HUMPTY         WONDERLAND
192.168.10.31    DUM              00-02-00-00-00-82                  WONDERLAND
192.168.10.32    DEE              00-b0-00-00-00-f8                  WONDERLAND
192.168.10.33    DINAH            00-b0-00-00-00-6b   DINAH          WONDERLAND
192.168.10.36    WHITENIGHT       00-b0-00-00-00-32   ADMINISTRATOR  WONDERLAND
192.168.10.40    REDQUEEN         00-b0-00-00-00-19   REDQUEEN       WONDERLAND


<hr>
$ ./nbtscan.pl -v 192.168.1.172
NBTScan v0.3 by MadHat (at) Unpsecific.com
scanning 192.168.1.172
IP Address       Name              Group       Type
-----------------------------------------------------------------------------
192.168.1.172    ISS-SCANNER       UNIQUE      Workstation/Redirector
192.168.1.172    WONDERLAND        GROUP       Domain Name
192.168.1.172    ISS-SCANNER       UNIQUE      Messenger Service
192.168.1.172    ISS-SCANNER       UNIQUE      Server Service
192.168.1.172    WONDERLAND        GROUP       Browser Election Service
192.168.1.172    INet~Services     GROUP       Domain Controler
192.168.1.172    IS~ISS-SCANNER    UNIQUE      Workstation/Redirector
192.168.1.172    MADHAT            UNIQUE      Messenger Service
MAC Address: 00-b0-d0-00-22-63


</pre>
<br><br>
<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>
<a name=use></a>
<h2>Usage (output from ./http-scan.pl -h)</h2>
<pre>
$ ./nbtscan.pl
NBTScan v0.1 by MadHat (at) Unpsecific.com
Usage:
./nbtscan.pl [-v] [-t &lt;sec>] &lt;ip_range>

    &lt;ip_range>   Range of IPs you want to scan.  Supported formats listed below
    -t &lt;sec>     Timeout for each host waiting for a response
    -v  Verbose  Add moe info about what is going on

    a.b.c.d/n       - 10.0.0.1/25
    a.b.c.*         - 10.0.0.*
    a.b.c.d/w.x.y.z - 10.0.0.0/255.255.224.0 (standard format)
    a.b.c.d/w.x.y.z - 10.0.0.0/0.0.16.255    (cisco format)
    a.b.c.d-z       - 10.1.2.0-12
    a.b.c-x.*       - 10.0.0-3.*
    a.b.c-x.d       - 10.0.0-3.0
    hostname        - unspecific.com
    hostname[1-3]   - host[1-3].unspecific.com
<hr>


</pre>
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
  <li><b>0.4</b>
  <ul>
    <li> Added -V to allow for Verbose ouput of all data returned when scanning a subnet.
  </ul>
  <li><b>0.3</b>
  <ul>
    <li> Rewrote how Marconi was doing NBTScans and fixed this to support the added features of including the username, domain and other items.
  </ul>
  <li><b>0.2</b>
  <ul>
    <li> Fixed a few error in the way the scans were being precessed
  </ul>
  <li><b>0.1</b>
  <ul>
    <li> Created the damn thing
  </ul>
</ul>

<small><center><hr size=1 width=80% noshade><a href=#desc>Description</a> | <a href=#feat>Features</a> | <a href=#bugs>Bugs</a> | <a href=#todo>ToDo</a> | <a href=#requi>Requirements</a> | <a href=#down>Download</a> | <a href=#out>Output</a> | <a href=#use>Usage/Docs</a> | <a href=#goals>Goals</a> | <a href=#change>Change Log</a><hr size=1 width=80% noshade></center></small>

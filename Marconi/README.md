# Marconi
<div class=mainbody>
At this time Marconi is just a simple perl module that I use with many of my 
security and network programs.  It only has a few functions built in, but is 
growing.  The POD info is not up to date, but it is a work in progress. 
<br>
<br>
To use the module with any of the apps that need it, just download it into the same directory they are running from.  There will be a full install process in the future...  Real Soon Now(tm)<br><br>
For more info, please contact me @ 
<a href=mailto:madhat@unspecific.com>MadHat (at) Unspecific.com</a>
<br><br>

I just rewrote how Marconi does NBTScanning using the NBTSTAT packets.  It is more accurate and suplies more information.
<br><br>

Need to start a change log for Marconi.pm.<br>
<br>
So I noticed that some hosts were not working properly.  Looks like the type 
of Node they are made scanning different as far as the NBTSTAT packet sent.
I changed the NBTSTAT packet and noticed different info returned that was not 
matching my old tests.  It was a different node type.<br>
<a href=http://support.microsoft.com/default.aspx?scid=http://support.microsoft.com:80/support/kb/articles/Q119/4/93.asp&NoWebContent=1>http://support.microsoft.com/default....support/kb/articles/Q119/4/93.asp&NoWebContent=1</a>
<br><br>
I added support to show 2 node types that I ahve encountered.<br>
<a href=/nbtscan>nbtscan.pl</a> has also been updated to use this new info.<br><br>
</div>
<div class=mainbody>
<a href=Marconi.pm>marconi.pm</a> The module itself.<br><br>
</div>
<div class=bodytitle>Apps That Use Marconi</div>
<ul class=list>
  <li><a href=/nbtscan>NBTScan</a>
  <li><a href=/routedetector>RouteDetector</a>
</ul>
<div class=bodytitle>Current Functions</div>
<ul class=list>
  <li><b>CalculateIPRange</b><br><br>
CalculateIPRange takes 4 possible parameters and returns an array that 
contains the IPs expanded from the list given, or an error message, if 
ERRNO is defined.
<br><br>
<code> @list = CalculateIPRange($iplist, [$errno, [$maxip, [$DEBUG]]])</code>
<br><br>
  <ul class=list>
    <li> <b>$iplist</b><br> Scalar that represents the IPs. Currently supported
formats include<br>
    <ul class=list>
      <li>a.b.c.d/n       - 10.0.0.1/25<br>
      <li>a.b.c.*         - 10.0.0.*<br>
      <li>a.b.c.d/w.x.y.z - 10.0.0.0/255.255.224.0 (standard format)<br>
      <li>a.b.c.d/w.x.y.z - 10.0.0.0/0.0.16.255    (cisco format)<br>
      <li>a.b.c.d-z       - 10.1.2.0-12<br>
      <li>a.b.c-x.*       - 10.0.0-3.*<br>
      <li>a.b.c-x.d       - 10.0.0-3.0<br>
      <li>hostname        - unspecific.com<br>
      <li>hostname[1-4].domains.com
    </ul>
<br><br>
    <li> <b>$errno</b><br>
whether or not to return an error<br><br>
    <ul class=list>
If set a 'helpful' message will be returned as the first item of the array
<br>If not set, or set to 0, nothing will be returned if the function is not 
able to expand the list into IPs.
    </ul>

<br><br>
    <li> <b>$maxip</b><br>
    <ul class=list>
This is used to set the maximum number of IPs to return in the array.  
Default value is a /16, or 65536 IPs.  This can ot be raised.  
If the MAXIP is reached an error is returned.
    </ul>
<br><br>
    <li> <b>$DEBUG</b><br>
<ul class=list>
DEBUG vaue is an integer from 1 to 3, where 3 is the most verbose.
</ul>
  </ul>
  <li><b>NBTScan</b><br><br>
<code>($name, $mac, $user, $domain, @data) = NBTScan( $ipaddr, [$timeout, [$DEBUG]])</code><br><br>
NBTScan takes 3 porrible paramiters and returns 5 vaules.
<br>
NetBIOS Name is the firect Item returned.<br>
Second item is the MAC address<br>
Third is the Username of the person logged in (this is a guess and mae be the amchine name).<br>
Forth item returned is the domain or workgroup the box is a member of.<br>
Last item is a comma sperated list of everything returned by the NBTSTAT packet from the machine being queried.  The 3 fields returned per line are the Name returned, the description of what thet name reqpresnts and the "Group or Unique" field that denotes wether it is a domain/workgroup related item of local to the box.<br><br>
UDP port 137 must be open for 
this function to be successful.  The 3 values sent are IP address, timeout 
and a debug flag.
<br><br>
  <ul class=list>
    <li> <b>$ipaddr</b>
    <ul class=list>
      The IP address you wish to scan.  At this point only IPv4 is supported and hostname will not be accepted.
    </ul>
    <li> <b>$timeout</b>
    <ul class=list>
      The number of seconds to wait for a reply before giving up and moving on.
    </ul>
    <li> <b>$DEBUG</b>
      <ul class=list>
        DEBUG vaue is an integer from 1 to 3, where 3 is the most verbose.
      </ul>
  </ul>
  <li><b>CheckPort</b><br><br>
<code>$rc = CheckPort( $ipaddr, $port, $proto, [$timeout, [$DEBUG]])</code><br><br>
CheckPort takes 5 possible paramaters and returns a binary vaule.  It will 
return true if the port is open and false if it is not.  The 5 vaules sent 
are IP address, port, protocol by name, timeout in seconds and a debug vaule.
<br><br>
  <ul class=list>
    <li> <b>$ipaddr</b>
    <ul class=list>
      The IP address you wish to scan.  At this point only IPv4 is supported and hostname will not be accepted.
    </ul>
    <li> <b>$port</b>
    <ul class=list>
      The port you wish to scan.  Valid port are 1-65535, 0 is not supported at this time.
    </ul>
    <li> <b>$proto</b>
    <ul class=list>
      'TCP' or 'UDP'
    </ul>
    <li> <b>$timeout</b>
    <ul class=list>
      The number of seconds to wait for a reply before giving up and moving on.
    </ul>
    <li> <b>$DEBUG</b>
      <ul class=list>
        DEBUG vaue is an integer from 1 to 3, where 3 is the most verbose.
      </ul>
  </ul>
  <li><b>RawRequest</b><br><br>
<code>$content = RawRequest( $ipaddr, $port, $request, [$timeout, [$ssl, [$DEBUG]]])</code><br><br>
RawRequest takes 6 possible paramaters and returns a string for success
and nothing for failure.  The 6 values sent are IP address, port, request,
timeout, ssl and a debug value.
<br><br>
  <ul class=list>
    <li> <b>$ipaddr</b>
    <ul class=list>
      The IP address you wish to scan.  At this point only IPv4 is supported and hostname will not be accepted.
    </ul>
    <li> <b>$port</b>
    <ul class=list>
      The port you wish to send the request to.  Valid port are 1-65535, 0 is not supported at this time.
    </ul>
    <li> <b>$request</b>
    <ul class=list>
      The request can be a simple newline, or a full HTTP request or something more complicated like HEX values for binary.
    </ul>
    <li> <b>$timeout</b>
    <ul class=list>
      The number of seconds to wait for a reply before giving up and moving on.
    </ul>
    <li> <b>$ssl</b>
    <ul class=list>
      If set to true, SSL will be used.  Specifically Net::SSLeay:sslcat is the function used.
    </ul>
    <li> <b>$DEBUG</b>
      <ul class=list>
        DEBUG vaue is an integer from 1 to 3, where 3 is the most verbose.
      </ul>
  </ul>
  <li><b>swrite</b><br><br>
Stolen directly from the perlform perldoc page, which is to write() what sprintf() is to printf().<br>

<br><br>
<code>       $content = swrite($format, @strings);</code><br><br>
<code> $string = swrite(&lt;&lt;'END', 1, 2, 3);<br>
Check me out<br>
@&lt;&lt;&lt;  @|||  @>>><br>
END<br>
  print $string;</code>
<br><br>
</ul>


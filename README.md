A few random perl scripts written over the years


## binify.pl
At one point I needed an easy way to convert files to and form the ASCII representation of binary (ones and zeros). This is how I did it. Instructions are in the file.

## boustrophedon.pl 
This script takes a text file are reverses every other line. Don't ask how it was used.

## burble.pl 
reads standard mbox file and will randomize phrases, pulls data from websites and writes a new email as the person specificed on the command line. Used to gain knowledge of peoples inner workings. Has been know ot piss people off, make people cry and/or unscribe.

## count
to keep score on some of the mailing lists I have been on for a while. What it does is count the emails, domains or suffixes to tell how many emails, lines and new lines have been posted to the list. It reads a standard mbox format files

## hosts
a 'host' replacement (sort of) that expands subnets into a list of IPs can be used with or without hostnames.  Can also be used as a perl include file to use the expanding capabilities (as seen in the scanners) - Can also be used as a CGI script, called through a web server and returns HTML

## Marconi
 A simple perl module used with a few of the other scripts.  It has functions such as expanding network notation (CIDR notation, CISCO notation, ranges, etc...) plus NBT UDP packet creation and reading and more...

## Kaiko
Kaiko is a silc bot

## nbtscan
This is a simple script that uses Marconi to scan a range of hosts for their NetBIOS name and MAC address. UDP port 137 must be open for it to work. It uses UDP sockets, not a plugin or module to request and receive the info.

## route-dector
This scanner is intended to detect multi-homed boxes on a secured network. Also uses marconi for network notation expansion.





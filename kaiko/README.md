
<h2 align=right>Kaiko</h2>

<ul>
  <li> <a href=/silc/kaiko.pl>Kaiko - The Script</a>
  <li> <a href=/silc/kaiko.conf>Kaiko - The Config</a>
<br><br>
Kaiko means "Silcworm" in Japanese, and as the person who suggested it pointed out, "worm means something to you hacker types, right?"  I gave Kaiko the last name of Hatsukaa, which means "hacker".  So Kaiko's full name is Silcworm[sic] Hacker.
<br><br>
Kaiko is a girl, presently.  She has the ability to auto op people joining a channel she is on.  While there are a lot of bots out there for IRC, there are few to none for Silc, and so Kaiko was born.  Kaiko is a script that has to be run inside a CLI silc client.  It is a full silc session, with it's own configs, public/private key pairs, etc...
<br><br>
Check here for more details on Kaiko, how to install her, how to run her and how to modify her.  For now, you have access to the code and config files.<br><br>
ToDo: <br>
<li>Add private message responces<br>
<li>Remove some hardcoded locations

<br><br><b>Current <em>/msg kaiko help</em> ouput</b><br><br>
<pre>
*kaiko* Private Message Commands:
 - join #channel [passwd]
   To invite kaiko to #channel
   She will join and add the person who invited her to her 
     auto op list to that channel.
   You can invite her to a channel, op her and leave, and 
     when you come back, she will auto-op you, keeping the 
     channel open
 
 - leave #channel
   To make kaiko leave a channel
   Can only be done by the person that did the invite 
     (by fingerprint)
 
 -op #channel user
   To make kaiko op user on #channel, if they have the 
     rights or you have op rights for that channel in the 
     config anonymous ops?

 - quote &gt;STK>
   To display current stock quote of &gt;STK> from Yahoo Finance
 
 - define &gt;WORD>
  To display the MW definition of &gt;WORD>
 
 - jargon &gt;WORD>
  To display the jargin file entry for &gt;WORD>
 
 - broadcast message here
   To display a message to all channels kaiko is currently on.
   * kaiko heard message here
   NOTE:  Don't abuse or it will be removed
 
 
 In #channel Command
 - kaiko version
   To display the current version of Kaiko, as defined in 
     the config file
 
 - kaiko info &gt;user>
   To display the last known info about a user
   * kaiko last saw &gt;user> on &gt;date>  from &gt;host>
 
 - kaiko broadcast message here
   To display a message to all channels kaiko is currently on.
   * kaiko heard message here
 
 - kaiko define
  To display the MW definition of WORD to the channel

 - kaiko jargon
  To display the jargon file entry for WORD to the channel
 
 - who/what is ...?
   as kaiko listens to the channel, she picks up bits of info
   She will tell if she has heard anything  about the subject
 
 - kaiko sleep &gt;min>
  To make kaiko not respond to anything in public channels 
    for &gt;min> minutes
  Issueing a sleep command while kaiko is asleep will tell
    you how long until kaiko wakes up

</pre>

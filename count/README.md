

count.pl

mbox counting at its... well, it works


Description

Wirten by: MadHat at Unspecific.com [[|%^)
count.pl is to keep score on some of the mailing lists I have been on for a while. What it does is count the emails, domains or suffixes to tell how many emails, lines and new lines have been posted to the list. It reads a standard mbox format files.
I have tested it with mutt, pine, evolution, and Eudora.



Features

count on email, domain or suffix
sort on number of messages (-E), number of lines (-L), number of new lines (-N) or the amount of grabage (-G) sent (quoted lines)
counts quoted lines if the line starts with > | : <TAB> blah blah blah
automatically strips duplicate messages (based on message ID)
can be limited to show only the top X entries (defalt is 50, see -m option)
can be limited to specific date range (see -f and -t)
can count on gzipped mbox files
can count on web based archives
can rip a list of URLs from mail (see -u)
can show % of email by each person that contain HTML, RTF, or attachments (see -l)
can show Total number of replies referencing each address (see -T)



BUGS

some MS clients don't seem to properly attribute quoted lines, so it has trouble there, but there is nothing I can do about that.



Requirements

perl (>5.6 prefered)
Date::Manip perl module
Mail::MboxParser perl moodule
Bundle::LWP if you are going to use the http get of mailboxes
gzip or gunzip if you are going to use compressed mailboxes. (if you don't know where to find them.... no comment)



Download

count.pl - v2.4.0


Output

An example of the output...
$ ./count.pl -e -f01/01/2002 -t01/31/2002 -m 5 subfolders/Folder/mbox
Start Date: Jan  1, 2002
End Date:   Jan 31, 2002
Total emails matched: 108
Total Unique Entries: 21
                                       Total    Total      Total   Sig/
    Address                           EMails    Lines       New    Noise
                                      Posted    Posted     Lines   Ratio
  1 someone@adomain.com                   20       842       267    32
  2 user@domain.org                       12       786       180    23
  3 another@domainfoo.com                  9       412        59    14
  4 user@some.collg.edu                    8       293        42    14
  5 someone@another.com                    8       149        62    42

$ ./count.pl -e -l -f01/01/2002 -t01/31/2002 -m 5 subfolders/Folder/mbox
Start Date: Jan  1, 2002
End Date:   Jan 31, 2002
Total emails matched: 108
Total Unique Entries: 21
                                     Total  Total   Total  Sig/
    Address                         EMails  Lines    New   Noise  Loser
                                    Posted  Posted  Lines  Ratio  Rating
  1 talks@not-msn.net                   10     288    142    49     25
  2 madhat_unspecificly@yahoo.com        9     354    215    61      0
  3 bob@someother.net                    5     124     41    33     20
  4 someone@bombed.net                   4     181     39    22      0
  5 luser@some.collg.edu                 3      54     39    72    100


$ ./count.pl -e -m 5 subfolders/Folder/mbox
Start Date: Dec 31, 1969
End Date:   Nov 10, 2002
Total Unique Entries: 12
                                     Total  Total   Total  Sig/
    Address                         EMails  Lines    New   Noise  Troll
                                    Posted  Posted  Lines  Ratio  Rating
  1 bobuser@domain.net                  10     288    142    49     15
  2 nonuser5@yahoo.com                   9     354    215    61      4
  3 latida@unsc.net                      5     124     41    33      1
  4 ugabooga@msn.com                     4     181     39    22      4
  5 loser@attbi.com                      3      54     39    72      0

Usage (output from ./count.pl -h)

 count - 2.2.1 - The email counter by: MadHat<madhat@unspecific.com>

./count <-e|-d|-s> [-ENLGTl] [-m#] [-f <from_date> -t <to_date>]\
     <mailbox | http://domain.com/archive/mailbox>
        -h Full Help
        -e email address
        -d count domains
        -s count suffix (.com, .org, etc...)
        -l Add loser rating
        -T Add troll rating
        -T Add list of URLs found in the date range
        -v Verbose output (DEBUG Output)
        -E sort on emails (DEFAULT)
        -L sort on total lines
        -N sort on numer of NEW lines (not part of reply)
        -G sort on Garbage (quoted lines)
        -m# max number of entries to show
        -fmm/dd/yyyy From date.  Start checking on this date [01/01/1970]
        -tmm/dd/yyyy To date. Stop checking after this date [today]
        <mailbox> is the mailbox to count in...


'count' will open the disgnated mailbox and sort through the emails counting
on the specified results.

-e, -d or -s are required as well as a mailbox.  All other flags are optional.

 -e will count on the whole email address
 -d will count only on the domain portion of the email (everything after the @) 
 -s will count on the suffix (evertthing past the last . - .com, .org...)

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

ChangeLog

2.4
Fixed a problem with Dates (stripping last day in some instances)
Removed GPG sigs from being counted
Added less than 10% sig/noise to increase loser rating
Added "no subject" to increase loser rating
Added top posting to increase loser rating
Updated URL listing, grouping by subject (-u)
added contributers with URL listing (-u)
Fixed more debug messages
2.3
fixed some email matching issues
cleaned up the debugging more... I think this happens every time
added gzip'ed mbox support
added troll rating based on Reference and In-Reply-To headers.
Troll rating is the total number of emails that reference an email directly using one of those 2 header fields.
added http support for counting mail archives
added some new debug info when using -v
added -D for debug messages 
-D 1 low (shows basic routines and info)
-D 2 detailed (shows more specific details about what is going on, plus everything above
-D 3 annoying (shows every line of every email, pluse everything above)
made -v only give basic details abut what is going on because -D added for real DEBUGing info
cleaned u the quoted and new lines, like not including blank lines as new or quoted lines anymore.
added option for Troll rating (-T)
reworked how the format was generated 
so it is easier to add new features ;-)
added URL ripper to show list of URLs for date range (see -u)
after adding above, I went back and had it weed out all the footer style URLs, like for http://www.yahoo.com, http://messenger.msn.com, etc...
2.2
fixed several errors
added loser rating OPTION based on attachments sent. Also includes non text (ie. HTML, RTF) mime types. 
Specifically, this is a % of mails that include one of these, since it is standard that you don't send attachments to lists and on the lists I am on, non-text mails are considered bad.
2.1
INIT CHANGE LOG
 
 
 
 
 http://www.unspecific.com/.go/count/

o S/N Ratio - % new lines to total lines posted.

o L - Loser Rating - % of emails that contain items deemed as bad list
etiquette, that includes top posting, posting in HTML, over-quoting,
etc...

o T - Troll Rating - # of emails that reply directly referencing your
email via the 'In-Reply-To' or 'Reference' headers


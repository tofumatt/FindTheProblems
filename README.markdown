# FindTheProblems #
## A Simple Ruby -> Prowl Site Monitor ##

[Prowl](http://prowl.weks.net) is a nifty iPhone App -- it's basically a [Growl](http://growl.info) client for the iPhone. It's got a neato web API that allows pretty much any program to send it notifications. Site monitoring seems like a pretty good use of this capability. Setup a cron job and you can get by-the-minute notifications on an array of sites that you are responsible for maintaining.

## Setup ##

### Required Settings ###

This is a pretty barebones little script; you only need to edit:

*   *Sites_To_Check* -- An array of URLs to check. HTTP and HTTPS work fine as long as your Ruby install supports 'em.
*   *Prowl_API_Keys* -- An array of at least one (1) and up to five (5) Prowl API Keys. You can get your API Key by signing into the [Prowl Site](http://prowl.weks.net).

### Optional Settings ###

*	*Priority* -- Prowl notification priority. Can be an integer between -2 (lowest priority) and 2 (emergency). Set to 2 by default.
*	*Provider_Key* -- A Prowl Provider key. Find out more about these on the [Prowl API Page](http://prowl.weks.net/api.php). Empty by default.
*	*Max_Redirects* -- If the page redirects you, how many redirects should you follow before you give up? You'll want this to be at least 1 unless you're **positive** that all of your URLs never do 3xx redirects. Set to 3 by default.

## Usage ##

You can run this script from the command-line and it'll check your sites right away. However, you'll probably want to setup a cron job or some other sort of scheduled task to automatically check your sites for you on a regular basis. On a UNIX machine, you can simply type: `crontab -e` to open up your cron schedule. To check your sites every five minutes, add this line to your crontab:

	0,5,10,15,20,25,30,35,40,45,50,55 * * * * /path/to/findtheproblems.rb

## License ##

This program is free software; it is distributed under an [MIT License](http://www.opensource.org/licenses/mit-license.php).

---

Copyright (c) 2009 [Matthew Riley MacPherson](http://lonelyvegan.com).
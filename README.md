GradeBot
=========

This script monitors and notifies if my grades have been changed/updated as professors enter them.  
It was written for Ellucian's Student Information Systems (I think that's what it is).

start.sh: Just reads through creds file (or any filename passed as arg) and forks grades.sh  
grades.sh: Does the fetching of the grades and monitors for changes.

The script uses Mutt to send the emails, so it should be installed and configured accordingly.  

By default, it checks every 5 minutes, but interval can be changed in grades.sh  
Also by default, it filters out everything but the 2016FA semester, which can also be changed in grades.sh  
(remove the last 'grep' for no filtering)  
It is configured to use Cooper Union's services, so it may work with little changes in grades.sh (or not)  
Variable url is the url of the address to fetch the student's profile.
Also correct url_login

The scripts would generate files under the grades/ directory, which are the temporary grades that the scripts are comparing the new grades against.
They also generate a log file.

Usage
---------
Before starting the script, user credentials and email addresses should be added to the creds file.  
(!!PLAINTEXT PASSWORDS WOAH!!)  
Each user should receive an initial email with the current grades upon running starting the scripts.

```
git clone https://github.com/awkwardbunny/gradebot
cd gradebot
./start.sh creds
```

I don't know if this will continue running after the ssh session is closed.  
If it doesn't use tmux or something to keep them alive.

Some commands I find useful:
```
killall grades.sh # terminates all scripts
```
and
```
ps aux | grep grades.sh # lists all currently running scripts
```

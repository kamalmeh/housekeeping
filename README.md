# Automation of Housekeeping Activity
This is a combination of Shell and Perl script to perform housekeeping activity of the directories mentioned in purge.conf file. This is very easy to setup on your server.

## purge.conf
List all directories in this file. You can use either absolute path or relative path

## purge.ini
Grab the environment variables into perl program. List all variables you want to separate from the actual core login written in purge.pl

## purge.pl
It has the core logic for housekeeping. Don't mess with it unless you know what you are doing.

## purge.sh
Wrapper script to trigger core logic in purge.pl file and can be scheduled either in cron or any other job scheduling tool.

# Bugs and Issues
Feel free to open any issues or fix them and contribute here.

# Author
Kamal Mehta - Having extensive experience in writing automation tools in Bash, Perl and Python.
You can contact me on kamal.h.mehta@smiansh.com
Check out my profile: http://www.smiansh.com

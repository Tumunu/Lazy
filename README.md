# Lazy
A hack shell script, because fuck doing this shit everytime you start a new Kali VM (or any Debian based VM with minimal changes *cough* Ubuntu)

```bash
./lazy.sh -h

lazy.sh 0.1
Copyright 2020 . All rights reserved.

Usage: ./lazy.sh OPTION

NOTE: install GO first !!!
-g [local]            --go-install [local]            Go needs to be installed first. Then 'source ~/.bashrc'
-c [local]            --clean-install [local]         Rebuild VM with usual packages stored at local

-f [share][local]     --fix-share [share][local]      Fix Virtualbox share permissions

NOTE:  utilities
-b [share][local]     --burp [share][local]           Install burpsuite from local windows share
-r [file]             --remove-carriage [file]        Remove windows carriage returns from file
-d [url]              --debs [url]                    Download/Install manually debs
```

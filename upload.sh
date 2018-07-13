#!/bin/sh
rsync -azr --delete -e ssh public/* www.mhatta.org:/home/88/mhm5200/ja.mhatta.org


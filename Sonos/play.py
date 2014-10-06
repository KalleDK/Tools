#!/usr/bin/env python
import re
import sys
import soco
import os.path
import os
#import os.environ
import cgi
from subprocess import Popen, PIPE
form = cgi.FieldStorage()
id = form.getvalue('id')
uid = form.getvalue('uid')
action = form.getvalue('action')

p = Popen(["ifconfig", "em0"], stdout=PIPE, stderr=PIPE)
out, err = p.communicate()
info = out.split()
inet = False
for line in info:
	if inet:
		m = re.match(r".*",line)
		ip = m.group(0)
		inet = False
	m = re.match(r"inet",line)
	if m:
		inet = True


if not os.path.isfile(id + ".mp3"):
	p = Popen(["youtube-dl", "-x", "--audio-format", "mp3", "--id", "--prefer-ffmpeg", id], stdout=PIPE, stderr=PIPE)
	out, err = p.communicate()
	p = Popen(["youtube-dl", "-e", id], stdout=PIPE, stderr=PIPE)
	out, err = p.communicate()
	m =re.match(r"(.+)[\s]*-[\s]*(.+)", out)
	if m:
		title = m.group(2)
		artist = m.group(1)
	else:
		m =re.match(r"(.+)[\s]*:[\s]*(.+)", out)
		if m:
           		title = m.group(2)
           		artist = m.group(1)
        	else:
			title = out
			artist = "Youtube"

	p = Popen(["audiotag", "-a", artist, "-t", title, id + ".mp3"], stdout=PIPE, stderr=PIPE)
	out, err = p.communicate()
else:
	p = Popen(["audiotag", "-l", id +".mp3"], stdout=PIPE, stderr=PIPE)
	out, err = p.communicate()
	info = out.splitlines()
	artist = ""
	title = ""
	for line in info:
		m = re.match(r"=== ARTIST: (.*)", line)
		if m:
			artist = m.group(1)
		m = re.match(r"=== TITLE: (.*)", line)
                if m:
                        title = m.group(1)

sonos = soco.discover()

for instance in set(sonos):
	if uid == instance.uid:
		player = instance

if action == "Play":
	player.play_uri('x-file-cifs://'+ip+'/sonos/' + id + '.mp3')

if action == "Queue":
	player.add_uri_to_queue('x-file-cifs://'+ip+'/sonos/' + id + '.mp3')

print "Content-type: text/html"
print
print "<title>Playing</title>"
print "<p>Artist: " + artist + "</p>"
print "<p>Title: " + title + "</p>"

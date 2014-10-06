#!/usr/bin/env python
import sys
import soco
import cgi

sonos = soco.discover()

print 'Content-type: text/html'
print
print '<title>SonosTube</title>'
print '<script>'
print ' function DoSubmit() {'
print '	var str = document.getElementById("id").value;'
print ' var re = /[?&]v=([^&]+)/;'
print ' m = re.exec(str);'
print ' if (m) {'
print '     document.getElementById("id").value = m[1];'
print ' } else {'
print '     var re = /[^\/=]+$/g;'
print '     var myArray = str.match(re);'
print '     document.getElementById("id").value = myArray[0];'
print '}'
print ' return true;'
print '}'
print '</script>'
print '<h1>Sonos Controller</h1>'
print '<form method="GET" action="play.py" onsubmit="DoSubmit();">'
print '<input type="text" id="id" name="id"><br>'
for instance in set(sonos):
	print '<input type="radio" name="uid" value="' + instance.uid + '">' + instance.uid + '<br>'

print '<input type="submit" name="action" value="Play">'
print '<input type="submit" name="action" value="Queue">'
print '<input type="submit" name="action" value="Test">'
print '</form>'

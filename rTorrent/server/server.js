var express = require('express');
var app = express();
var spawn = require('child_process').spawn;

var port = 8021;
var ip = '172.20.20.21';
var script = '/usr/local/bin/magnet_to_torrent.bash';

app.get('/magnet', function(req, res){
	magnet = spawn(script, [req.query.q, req.query.cat]);
  	res.send(decodeURIComponent(req.query.q));
});

var server = app.listen(port, ip, function() {
    console.log('Listening on port %d', server.address().port);
});

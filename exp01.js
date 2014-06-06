var http = require('http');
var ip = '172.20.20.23';
var port = 8000;


function wol(action, target, res) {
	var wol_path = '/home/pi/Git/Tools/wol.pl';
	var data_all = '';
	var spawn = require('child_process').spawn;
    	var ls = spawn(wol_path, ['-'+action, ''+target]);
	
	ls.stdout.on('data', function (data) {
		data_all += data;
	});

	ls.on('exit', function (code) {
		res.end(data_all);
	});
}

function serv(req, res) {
	res.writeHead(200, {'Content-Type': 'text/plain'});
	URI=require('url').parse(req.url, true);
	console.log(URI);
	if (URI.pathname == "/wol") {
		wol(URI.query.action, URI.query.target, res);
	} else {
		res.end("Nothing here\n");
	}
}

http.createServer(serv).listen(port, ip);

console.log('Server running at http://'+ip+':'+port+'/');

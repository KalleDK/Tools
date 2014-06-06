var spawn = require('child_process').spawn;
var wo = '/home/pi/Git/Tools/wol.pl';

var ls = spawn(wo, ['-list', 'all']);

ls.stdout.on('data', function (data) {
  console.log('stdout: ' + data);
});

ls.stderr.on('data', function (data) {
  console.log('stderr: ' + data);
});

ls.on('close', function (code) {
  console.log('child process exited with code ' + code);
});

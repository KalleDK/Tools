// ==UserScript==
// @name       Magnet Fixer
// @namespace  http://k-moeller.dk
// @version    0.1
// @description  Change Magnet Links
// @match      http://thepiratebay.se/*
// @match      https://thepiratebay.se/*
// @copyright  2014+, Kalle
// ==/UserScript==

var url = '';

var js = document.createElement("script");
js.innerHTML = '\
function magnet(cat) {\
var xpath = "//a[starts-with(@href,\'magnet:\')]";\
var res = document.evaluate(xpath, document, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);\
var linkIndex, magnetLink, str;\
for (linkIndex = 0; linkIndex < res.snapshotLength; linkIndex++) {\
magnetLink = res.snapshotItem(linkIndex);\
str = encodeURIComponent(magnetLink.href);\
magnetLink.href=\'' + url + '/magnet?cat=\' + cat + \'&q=\' + str;\
}\
}';

var style_div = document.createElement("style");
style_div.innerHTML = '\
#magnet {\
position: fixed;\
top: 1em;\
right: 1em;\
}';

var button_div = document.createElement("div");
button_div.id="magnet";
button_div.innerHTML = '\
<input id="magnet_video" type="button" onclick="magnet(\'movie\')" value="Video">\
<input id="magnet_tv" type="button" onclick="magnet(\'tv\')" value="Tv">\
<input id="magnet_andet" type="button" onclick="magnet(\'andet\')" value="Andet">';
document.getElementById("header").insertBefore(js,document.getElementById("header").firstChild);
document.getElementById("header").insertBefore(button_div,document.getElementById("header").firstChild);
document.getElementById("header").insertBefore(style_div,document.getElementById("header").firstChild);

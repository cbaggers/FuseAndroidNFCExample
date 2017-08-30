var Observable = require("FuseJS/Observable");
var NFC = require("NFC");

var info = Observable("");

NFC.on("tagDiscovered", function(message) {
	console.log(message);
	info.value = message;
});

module.exports = {
	info: info
};

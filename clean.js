'use strict';

/* eslint-disable no-control-regex */

module.exports.data = function (obj) {
	delete obj._id;
	if (!obj.hasOwnProperty('_key')) {
		return null;
	}
	var key = obj._key;
	
	// Cleanup some "problematic" keys that could result in too long keys for index. They are not needed.
	if (key === "errors:404" || key === "ip:recent")
		return null;
	
	// clean up importer bugs
	delete obj.undefined;
	// if ((key.startsWith('chat:room:') && key.endsWith('uids') && !key.endsWith(':uids')) || (key.startsWith('uid:') && key.endsWith('sessionUUID:sessionId') && !key.endsWith(':sessionUUID:sessionId'))) {
	// 	return null;
	// }

	// remove importer cache on live objects
	if (!key.startsWith('_imported')) {
		for (var k of Object.keys(obj)) {
			if (k.startsWith('_imported')) {
				delete obj[k];
			}
		}
	}

	return module.exports.value(obj);
}

function isNumber(n) {
	return !isNaN(parseFloat(n)) && isFinite(n);
}

var dotRE = /\./g;

module.exports.value = function (obj) {
	var key = obj._key;
	for (var k in obj) {
		if (!Object.prototype.hasOwnProperty.call(obj, k)) {
			continue;
		}
		var v = obj[k];
		// if there is a '.' in the field name it inserts subdocument in mongo, replace '.'s with \uff0E,
		if (dotRE.test(k)) {
                        delete obj[k];
                        k = k.replace(dotRE, '\uff0E');
                }
		if (!v || v === true) {
			continue;
		}
		if (v instanceof Date) {
			obj[k] = v.getTime();
			continue;
		}
		if (typeof v === 'number') {
			if (Number.isNaN(v)) {
				obj[k] = 'NaN';
			}
			continue;
		}
		// Convert value to a real number (to allow mongo $inc operation to work after migration)
		// Skipping some objects that should keep value as string && !key.endsWith(":members") 
		if (k !== "value" && isNumber(v)) {
			obj[k] = Number(v);
		}
		if (typeof v === 'string') {
			if (v.indexOf('\x00') !== -1) {
				obj[k] = v.replace(/\x00/g, 'x00');
			}
			continue;
		}
		if (Array.isArray(v)) {
			obj[k] = v.map(function(a) {
				return String(a || '').replace(/\x00/g, 'x00');
			});
			continue;
		}

		// Object, possibly from a plugin
		obj[k] = module.exports.value(v);
	}

	return obj;
}

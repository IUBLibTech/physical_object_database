function validateBarcode(barcode) {
	valid = true;
	if (/^\d+$/.test(barcode)) {
		check = barcode.slice(-1);
		sum = 0;
		var pairs = barcode.split("").reverse().join('').match(/.{1,2}/g);
		for (i in pairs) {
		  o = parseInt(pairs[i][1] * 2);
		  sum += parseInt(o > 9 ? Math.floor(o / 10) + (o % 10) : o);
		  sum += parseInt(pairs[i][0]);
		}
		sum -= check;
		valid = (sum * 9) % 10;
	} else {
		valid = false
	}

	el = $("#physical_object_mdpi_barcode")
	if (valid) {
		el.removeClass("bad_barcode");
	} else {
		el.addClass("bad_barcode");
	}

}
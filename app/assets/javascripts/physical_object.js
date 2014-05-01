function validateBarcode(barcodeEl) {
	valid = false;
	barcode = barcodeEl.value
	if (barcode == "0") {
		valid = true;
	} else if (barcode.length == 14 && barcode.charAt(0) == 4 && (/^\d+$/.test(barcode))) {
		check = barcode.slice(-1);
		sum = 0;
		var pairs = barcode.split("").reverse().join('').match(/.{1,2}/g);
		for (i in pairs) {
		  o = parseInt(pairs[i][1] * 2);
		  sum += parseInt(o > 9 ? Math.floor(o / 10) + (o % 10) : o);
		  sum += parseInt(pairs[i][0]);
		}
		sum -= check;
		valid = (sum * 9) % 10 == check;
	}

	el = $(barcodeEl)
	if (valid) {
		el.removeClass("bad_barcode");
	} else {
		el.addClass("bad_barcode");
	}

}
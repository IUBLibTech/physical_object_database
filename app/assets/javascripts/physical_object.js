
/* only checks wether the barcode check digit is correct */
function validCheckDigit(barcode) {
	if ((/^\d+$/.test(barcode))) {
		check = barcode.slice(-1);
		sum = 0;
		var pairs = barcode.split("").reverse().join('').match(/.{1,2}/g);
		for (i in pairs) {
		  o = parseInt(pairs[i][1] * 2);
		  sum += parseInt(o > 9 ? Math.floor(o / 10) + (o % 10) : o);
		  sum += parseInt(pairs[i][0]);
		}
		sum -= check;
		return (sum * 9) % 10 == check;
	} else {
		return false;
	}
}

function markInvalid(barcodeEl) {
	barcodeEl.addClass("bad_barcode");
}

function markValid(barcodeEl) {
	barcodeEl.removeClass("bad_barcode");
}


function validateMdpiBarcode(barcodeEl) {
	var hmm = validCheckDigit(barcodeEl.val());
	if ((barcodeEl.val() == "0" || barcodeEl.val() == "") || (barcodeEl.val().length == 14 && barcodeEl.val().charAt(0) == 4 && validCheckDigit(barcodeEl.val()))) {
		markValid(barcodeEl);
	} else {
		markInvalid(barcodeEl);
	}
}

function validateIucatBarcode(barcodeEl) {
	if ((barcodeEl.val() == "0" || barcodeEl.val() == "") || (barcodeEl.val().length == 14 && barcodeEl.val().charAt(0) == 3 && validCheckDigit(barcodeEl.val()))) {
		markValid(barcodeEl);
	} else {
		markInvalid(barcodeEl);
	}
}



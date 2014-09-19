// handle the AJAX call on the barcode_check form - this basically checks to see if the specified
// barcode has ephemera:
// *) if it doesn't, it then hands off to the hidden 'barcode_submit' form and manually submits that form
// *) if it does have ephemera, it displays a dialog the user interact
$( document ).ready(function() {
	$("#ephemera_returned_ephemera_returned").click(function() {
		if ($(this).is(":checked")) {
			$("#mdpi_barcode").val(bc);
			$("#barcode_form").submit();
			$( this ).dialog( "close" ); 
		}
	});

	$( "#barcode_check" ).submit(
		function(event) {
			event.preventDefault()
			bc = $("#mdpi_barcode_check").val();
			// make the ajax call to see if the item has ephemera
			$.ajax({
				url: "../../../physical_objects/has_ephemera",
				async: false,
				data: {
					mdpi_barcode: bc
				},
				type: "GET",
				dataType : "text",
				success: function( text ) {
					if (text == 'true') {
						$("#po_b").text(bc)
						$(function() {
							$( "#dialog" ).dialog(
								{ 
									buttons: [ 
										{ text: "Ok", click: function() { 
											$("#mdpi_barcode").val(bc);
											$("#barcode_form").submit();
											$( this ).dialog( "close" ); 
											}
										}, 
										{ text: "Cancel", click: function() { 
											$( this ).dialog( "close" ); } 
										} 
									], 
									modal: true,
									title: bc+" Has Ephemera" ,
									width: 'auto'
								}
								);
						});
						
					} else if (text == 'false') {
						$("#mdpi_barcode").val(bc);
						//make sure the checkbox is unchecked because this item does not have ephemera
						$("#ephemera_returned_ephemera_returned").prop("checked", false)
						$("#barcode_form").submit();
					} else {
						alert("There is no Physical Object with barcode: "+bc);
					}
				},
				error: function( xhr, status, errorThrown ) {
					alert("An unexpected error occured... Check the physical object you just submitted for status")
				}
			});
		}
	);
});



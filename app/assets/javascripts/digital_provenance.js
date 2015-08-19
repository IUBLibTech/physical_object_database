// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
	$(function (){
		$('.date').datepicker();
	});
	$(function() {
		$("[id^=signal_chain_select]").change(
			function() {
				signal_chain_id = $(this).val();
				table = $(this).parent().parent().parent().parent();
				url = (signal_chain_id.length > 0 ? "../../signal_chains/ajax_show/"+signal_chain_id : "../../signal_chains/ajax_show/none");
				alert(url);
				$.ajax({
					url: url,
					async: false,
					data: {},
					type: "GET",
					dataType : "text",
					success: function( text ) {
						bad = $(".signal_chain_tr");
						bad.remove();
						table.append(text);
					},
					error: function( xhr, status, errorThrown ) {
						alert("Oops! Html status: "+status)
					}
				})
			});
	});
})

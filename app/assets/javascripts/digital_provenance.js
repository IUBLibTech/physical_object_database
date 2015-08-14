// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {
	$(function (){
		$('.date').datepicker();
	});
	$(function() {
		$("[id^=signal_chain_select_]").change(
			function() {
				signal_chain_id = $(this).val();
				table_id = $(this).parent().parent().parent().parent().attr("id")
				$.ajax({
					url: "../../signal_chains/ajax_show/"+signal_chain_id,
					async: false,
					data: {},
					type: "GET",
					dataType : "text",
					success: function( text ) {
						bad = $(".signal_chain_tr");
						bad.remove();
						parent = $("#"+table_id);
						parent.append(text);

					},
					error: function( xhr, status, errorThrown ) {
						alert("Oops! Html status: "+status)
					}
				})
			});
	});
})

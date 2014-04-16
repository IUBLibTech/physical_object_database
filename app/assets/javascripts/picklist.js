// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function new_box(pl_id) {  
  jQuery.ajax({
    url: "/bins/new_box/"+pl_id,
    type: "POST",
    data: {},
    dataType: "html",
    beforeSend: function(xhr) {
    	xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    },
    success: function(data) {
    	jQuery("#dialog").html(data)
    	$("#dialog").dialog({autoOpen : false, modal : true, show : { effect: "blind", duration: 100 }, hide : { effect: "blind", duration: 100 }});
      $("#dialog").dialog("open");
    },
    error: function (xhr, ajaxOptions, thrownError) {
        alert("Something bad happened...");
      }
  });
}

function assign_box(box_id) {  
  jQuery.ajax({
    url: "/bin/assign_box/"+box_id,
    type: "POST",
    data: {},
    dataType: "html",
    beforeSend: function(xhr) {
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    },
    success: function(data) {
      jQuery("#assign_bin_dialog").html(data)
      $("#dialog").dialog({autoOpen : false, modal : true, show : { effect: "blind", duration: 100 }, hide : { effect: "blind", duration: 100 }});
      $("#dialog").dialog("open");
    },
    error: function (xhr, ajaxOptions, thrownError) {
        alert("Something bad happened...");
      }
  });
}

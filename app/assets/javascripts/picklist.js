//FIXME: currently not called
// function new_box(pl_id) {  
//   jQuery.ajax({
//     url: "/bins/"+pl_id+"/boxes/new",
//     type: "GET",
//     data: {},
//     dataType: "html",
//     beforeSend: function(xhr) {
//     	xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
//     },
//     success: function(data) {
//     	jQuery("#dialog").html(data)
//     	$("#dialog").dialog({autoOpen : false, modal : true, show : { effect: "blind", duration: 100 }, hide : { effect: "blind", duration: 100 }});
//       $("#dialog").dialog("open");
//     },
//     error: function (xhr, ajaxOptions, thrownError) {
//         alert("Something bad happened...");
//       }
//   });
// }

//FIXME: currently not called
// function assign_box(box_id) {  
//   jQuery.ajax({
//     url: "/bin/"+box_id+"/assign_box",
//     type: "POST",
//     data: {},
//     dataType: "html",
//     beforeSend: function(xhr) {
//       xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
//     },
//     success: function(data) {
//       jQuery("#assign_bin_dialog").html(data)
//       $("#dialog").dialog({autoOpen : false, modal : true, show : { effect: "blind", duration: 100 }, hide : { effect: "blind", duration: 100 }});
//       $("#dialog").dialog("open");
//     },
//     error: function (xhr, ajaxOptions, thrownError) {
//         alert("Something bad happened...");
//       }
//   });
// }

var $pl_tooltip = $('#tooltip'),
  offset = {x: 20, y: 20};

  

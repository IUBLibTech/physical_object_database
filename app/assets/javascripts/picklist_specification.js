function tm_div(format, type, object_id, edit_mode) {  
  jQuery.ajax({
    url: "/physical_objects/tm_form/"+object_id,
    type: "GET",
    data: {"format" : format, "edit_mode" : true, "type" : type, 'edit_mode' : edit_mode},
    dataType: "html",
    success: function(data) {
      jQuery("#technicalMetadatum").html(data);
    }
  });
}


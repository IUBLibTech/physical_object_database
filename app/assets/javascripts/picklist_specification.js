function tm_div(format, type, object_id, edit_mode) {  
  jQuery.ajax({
    url: "/physical_objects/tm_form/",
    type: "GET",
    data: {"format" : format, "edit_mode" : true, "type" : type, 'edit_mode' : edit_mode, "id" : object_id},
    dataType: "html",
    success: function(data) {
      jQuery("#technicalMetadatum").html(data);
    }
  });
}


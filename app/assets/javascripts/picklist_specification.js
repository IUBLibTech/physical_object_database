function set_format_div(format, edit_mode) {  
  jQuery.ajax({
    url: "/picklist_specifications/get_form",
    type: "GET",
    data: {"format" : format, "edit_mode" : edit_mode},
    dataType: "html",
    success: function(data) {
      jQuery("#formatDiv").html(data);
    }
  });
}

function tm_div(format, po_id) {  
  jQuery.ajax({
    url: "/physical_objects/get_tm_form",
    type: "GET",
    data: {"format" : format, "edit_mode" : true, "id" : po_id},
    dataType: "html",
    success: function(data) {
      jQuery("#technicalMetadatum").html(data);
    }
  });
}


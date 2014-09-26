$(function() {
  $("#sortable").sortable({
   update: function(event, ui){
     $('#reorder_submission').val($("#sortable").sortable('toArray'));
   }
  });
  $("#sortable").disableSelection();
});

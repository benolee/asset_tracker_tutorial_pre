$(document).ready(function(){
  $("#message").dialog({modal: true});
  $("select[class*=flexselect]").flexselect();
  $("#work_unit_client_id_flexselect").click(function(event){
    if ($(this).val() == "Select a client") {
      $(this).val("");
    }
  });
});

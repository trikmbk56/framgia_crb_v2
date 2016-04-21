$(document).on('page:change', function() {
  $('#attendee').select2({
    multiple: true,
    theme: 'bootstrap',
    tokenSeparators: [',', ' ']
  });

  $('#dateTime .time').timepicker({
    timeFormat: 'g:ia',
    scrollDefault: 'now'
  });

  $('#dateTime .date').datepicker({
    dateFormat: 'dd-mm-yy',
    autoclose: true
  });

  if($('.new_event').length > 0){
    $('#dateTime').datepair();
  }

  if($('.edit_event').length > 0){
    $('#start_date').datepicker('setDate', $('#start_date').val());
  }
});

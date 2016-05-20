$(document).on('page:change', function(){
  var start_time = $('#start_time');
  var start_date = $('#start_date');
  var finish_time = $('#finish_time');
  var finish_date = $('#finish_date');
  var start_repeat = $('#start-date-repeat');
  var end_repeat =  $('#end-date-repeat');

  $('#attendee').select2({
    multiple: true,
    theme: 'bootstrap',
    tokenSeparators: [',', ' '],
    width: '97%'
  });
  $('#add_attendee').select2();

  $('#dateTime .time').timepicker({
    timeFormat: 'g:ia',
    scrollDefault: 'now'
  });

  $('#dateTime .date').datepicker({
    dateFormat: 'dd-mm-yy',
    autoclose: true
  });

  $('#dateTime').datepair();

  if($('.edit_event').length > 0){
    $('#start_date').datepicker('setDate', $('#start_date').val());
  }

  $(document).on('change', '.date-time', function(event) {
    $('#event_start_date').val(start_date.val() + ' ' + start_time.val());
    $('#event_finish_date').val(finish_date.val() + ' ' + finish_time.val());
    $('#event_start_repeat').val(start_repeat.val());
    $('#event_end_repeat').val(end_repeat.val());
  });
});

$(document).ready(function() {
  $('.btn-del').click(function() {
    attendee = $(this).attr('id');
    var attendeeId = attendee.substr(4);
    eventId = $(this).attr('ev-id');
    userId = $(this).attr('user-id');
    url = '/users/'+ userId + '/events/' + eventId + '/attendees/' + attendeeId
    var text = confirm(I18n.t('events.confirm.delete'));
    if (text === true){
      $('.l-att-' + attendeeId).fadeOut();
      $.ajax({
        url: url,
        type: 'DELETE',
        dataType: 'text',
        error: function(text) {
          alert(text);
        }
      });
    }
  });
});

$(document).on('page:change', function(){
  $('.dialog-repeat-event').click(function() {
    showDialog('dialog-repeat-event-form');
  });

  $('#event_repeat_type').on('change', function() {
    var repeat_type = $('#event_repeat_type').val();
    var repeat_weekly = "weekly";
    if(repeat_type == repeat_weekly){
      showDialog('repeat-on');
    }
    else{
      hiddenDialog('repeat-on');
    }
  });

  function showDialog(dialogId) {
    var dialog = $('#' + dialogId);
    $(dialog).removeClass('dialog-hidden');
    $(dialog).addClass('dialog-visible');
  }

  hiddenDialog = function(dialogId) {
    var dialog = $('#' + dialogId);
    $(dialog).addClass('dialog-hidden');
    $(dialog).removeClass('dialog-visible');
  }

  $('#close, #done, #cancel').click(function() {
    hiddenDialog('dialog-repeat-event-form');
    hiddenDialog('repeat-on');
  });

  $('#start-date-repeat, #end-date-repeat').datepicker({
    dateFormat: 'dd-mm-yy',
    autoclose: true
  });
});

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
  var start_time = $('#start_time');
  var start_date = $('#start_date');
  var finish_time = $('#finish_time');
  var finish_date = $('#finish_date');
  var url = window.location.href;
  var new_event = I18n.t("events.new.url");
  if (url.indexOf(new_event) > 0
      && $('#start_time').val() == I18n.t("events.new.am")
      && $('#finish_time').val() == I18n.t("events.new.pm")){
    $('#all_day').prop('checked', true);
    checkAllday();
  }
  $('#all_day').on('click', function() {
    checkAllday();
  });

  $('#event_repeat_type').on('change', function() {
    var repeat_type = $('#event_repeat_type').val();
    var repeat_weekly = "weekly";
    if(repeat_type == repeat_weekly){
      showDialog('repeat-on');
      checkedWeekly();
    }
    else{
      hiddenDialog('repeat-on');
    }
  });

  function formatAMPM(date) {
    var hours = date.getHours();
    var minutes = date.getMinutes();
    var ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours ? hours : 12;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    var strTime = hours + ':' + minutes + ampm;
    return strTime;
  }
  function checkAllday(){
    if ($('#all_day')[0].checked){
      start_time.hide();
      finish_time.hide();
      $('#event_all_day').val(true);
      var start = new Date();
      start.setHours(0,0,0,0);
      var end = new Date();
      end.setHours(23,59,59,999);
      start_time.val(formatAMPM(start));
      finish_time.val(formatAMPM(end));
      $('#event_start_date').val(start_date.val() + ' ' + start_time.val());
      $('#event_finish_date').val(finish_date.val() + ' ' + finish_time.val());
    }else{
      start_time.show();
      finish_time.show();
      $('#event_all_day').val(false);
    }
  }
  function showDialog(dialogId) {
    var dialog = $('#' + dialogId);
    $(dialog).removeClass('dialog-hidden');
    $(dialog).addClass('dialog-visible');
    $('.overlay-bg').show().css({'height' : docHeight});
  }

  hiddenDialog = function(dialogId) {
    var dialog = $('#' + dialogId);
    $(dialog).addClass('dialog-hidden');
    $(dialog).removeClass('dialog-visible');
  }

  $('#close, #cancel').click(function() {
    clearDialog();
  });

  function clearDialog() {
    hiddenDialog('dialog-repeat-event-form');
    hiddenDialog('repeat-on');
    hideOverlay();
  }

  function hideOverlay() {
    $('.overlay-bg').hide();
  }

  function uncheckRepeat() {
    $('input[type="checkbox"]#repeat').prop('checked', false);
  }

  var docHeight = $(document).height();

  $('.dialog-repeat-event').hide();

  $('input[type="checkbox"]#repeat').change(function() {
    if(this.checked && $('.cb-repeat').hasClass('first')) {
      showDialog('dialog-repeat-event-form');
    }
    if(!$('.cb-repeat').hasClass('first')) {
      if(this.checked)
        $('.dialog-repeat-event').show();
      else
        $('.dialog-repeat-event').hide();
    }
  });

  $('.dialog-repeat-event').click(function() {
    showDialog('dialog-repeat-event-form');
  });

  $('#done').click(function() {
    if($('#start-date-repeat').val() == '') {
      $('#start-date-repeat').focus();
    } else if($('#end-date-repeat').val() == '') {
      $('#end-date-repeat').focus();
    } else {
      clearDialog();
      $('.cb-repeat').removeClass('first');
      $('.dialog-repeat-event').show();
    }
  });

  $('#close, #cancel').click(function() {
    if($('.cb-repeat').hasClass('first'))
      uncheckRepeat();
    hideOverlay();
  });

  $('.overlay-bg').click(function(events) {
      events.preventDefault();
  });

  $(document).keyup(function(e) {
    if (e.keyCode == 27) {
      clearDialog();
      uncheckRepeat();
    }
  });

  $('#start-date-repeat, #end-date-repeat').datepicker({
    dateFormat: 'dd-mm-yy',
    autoclose: true
  });

  $('#start-date-repeat').on('change', function(){
    checkedWeekly();
  });

  function checkedWeekly() {
    var repeatOn = $('#start-date-repeat').val().split('-');
    var splitRepeatOn = new Date(repeatOn[2], repeatOn[1] - 1, repeatOn[0]);
    var cb = $('#repeat-' + splitRepeatOn.getDay());
    cb.prop('checked', true);
  }
});

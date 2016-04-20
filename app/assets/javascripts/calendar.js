$(document).ready(function() {
  $('#full-calendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    defaultView: 'agendaWeek',
    businessHours: true,
    editable: true,
    events: function(start, end, timezone, callback) {
      $.ajax({
        url: '/api/events',
        dataType: 'json',
        success: function(doc) {
          var events = [];
          events = doc.map(function(data) {
            return {title: data.title, start: data.start_time,
              end: data.end_time, id: data.id}
          });
          callback(events);
        }
      });
    },
    eventClick: function(event, jsEvent, view) {
      $('#popup').offset({left: jsEvent.pageX-200, top: jsEvent.pageY});
      $('#popup').css('visibility', 'visible');
      popupOriginal();
      $('#title-popup').html(event.title);
      var time_format = 'MMMM Do YYYY, h:mm a';
      var time = event.start.format(time_format) + ' - ' +
        event.end.format(time_format);
      $('#time-event-popup').html(time);
      var edit_url = '/users/' + $('#current-user-id-popup').html() +
       '/events/' + event.id + '/edit';
      $('#btn-edit-event').attr('href', edit_url);
      deleteEventPopup(event);
      clickEditTitle(event);
    },
  });

  function clickEditTitle(event) {
    $('#title-popup').click(function() {
      $('.data-display').css('display', 'none');
      $('.data-none-display').css('display', 'inline-block');
      $('#title-input-popup').val(event.title);
      $('#title-input-popup').unbind('change');
      $('#title-input-popup').on('change', function(e) {
        event.title = e.target.value;
      });
      updateEventPopup(event);
    });
  }

  function updateEventPopup(event) {
    $('#btn-save-event').click(function() {
      $('#popup').css('visibility', 'hidden');
      url = '/api/events/' + event.id
      $.ajax({
        url: url,
        data: {title: event.title},
        type: 'PUT',
        dataType: 'text',
        success: function(text) {
          $('#full-calendar').fullCalendar('updateEvent', event);
        },
        error: function(text) {
          alert(text);
        }
      });
    });
  }

  function deleteEventPopup(event) {
    $('#btn-delete-event').unbind('click');
    $('#btn-delete-event').click(function() {
      $('#popup').css('visibility', 'hidden');
      var temp = confirm(I18n.t('calendars.events.confirm_delete_event'));
      if (temp === true)
        {
          $('#full-calendar').fullCalendar('removeEvents', event.id);
          url = '/api/events/' + event.id
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
  }

  function popupOriginal() {
    $('#title-input-popup').val('');
    $('.data-display').css('display', 'inline-block');
    $('.data-none-display').css('display', 'none');
  }

  $('.cancel-popup-event').click(function() {
    $('#popup').css('visibility', 'hidden');
  });

  $('#mini-calendar').datepicker({
    dateFormat: 'DD, d MM, yy',
      onSelect: function(dateText,dp) {
        $('#full-calendar').fullCalendar('gotoDate',new Date(Date.parse(dateText)));
        $('#full-calendar').fullCalendar('changeView','agendaWeek');
      }
  });

  $('.create').click(function() {
    if ($(this).parent().hasClass('open')) {
      $(this).parent().removeClass('open');
    }
    else{
      $(this).parent().addClass('open');
    };
  });

  $('#clst_my').click(function() {
    if ($('#collapse1').hasClass('in')) {
      $('#collapse1').removeClass('in')
    } else{
      $('#collapse1').addClass('in')
    };
  });
});

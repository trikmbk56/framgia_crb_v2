$(document).ready(function() {
  var start_time, end_time, event_title;

  $('#full-calendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaFourDay,agendaDay'
    },
    views: {
      agendaFourDay: {
        type: 'agenda',
        duration: {days: 4},
        buttonText: '4 days'
      },
      timetable: {
        type: 'custom',
        buttonText: 'Time table',
      }
    },
    defaultView: 'agendaWeek',
    businessHours: true,
    editable: true,
    selectable: true,
    selectHelper: true,
    unselectAuto: false,
    nowIndicator: true,
    allDaySlot: false,
    selectable: {
      month: false,
      agenda: true
    },
    height: $(window).height() - $('header').height() - 9,
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
    eventClick: function(events, jsEvent, view) {
      $('#popup').offset({left: jsEvent.pageX-200, top: jsEvent.pageY});
      $('#popup').css('visibility', 'visible');
      deleteEventPopup(events);
    },
    dayClick: function(date, jsEvent, view) {
      showCreateEventDialog(date, date, jsEvent, true);
      setDateTime(date, date);
    },
    select: function(start, end, jsEvent) {
      showCreateEventDialog(start, end, jsEvent, false);
      setDateTime(start, end);
    }
  });

  function deleteEventPopup(events) {
    $('#btn-delete-event').unbind('click');
    $('#btn-delete-event').click(function() {
      $('#popup').css('visibility', 'hidden');
      var temp = confirm(I18n.t('calendars.events.confirm_delete_event'));
      if (temp === true)
        {
          $('#full-calendar').fullCalendar('removeEvents', events.id);
          url = '/api/events/' + events.id
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

  $('#bubble-close').click(function() {
    $('#full-calendar').fullCalendar('unselect');
    hiddenCreateEventDialog();
  });

  function showCreateEventDialog(start, end, jsEvent, dayClick) {
    var dialog = $('#new-event-dialog');
    var dialogW = $(dialog).width();
    var dialogH = $(dialog).height();
    var windowW = $(window).width();
    var windowH = $(window).height();
    var xCordinate, yCordinate;

    if(jsEvent.pageX - dialogW/2 < 0) {
      xCordinate = jsEvent.pageX - dialogW/2;
    } else if(windowW - jsEvent.pageX < dialogW/2) {
      xCordinate = windowW - 2 * dialogW/2;
    } else {
      xCordinate = jsEvent.pageX - dialogW/2;
    }

    if(jsEvent.pageY - dialogH < 0) {
      yCordinate = jsEvent.pageY + 10;
    } else {
      yCordinate = jsEvent.pageY - dialogH - 10;
    }

    $(dialog).css({'top':yCordinate, 'left':xCordinate});

    $('#start-time').val(dateTimeFormat(start, dayClick));
    $('#finish-time').val(dateTimeFormat(end, dayClick));
    $('.event-time').text(eventDateTimeFormat(start, end, dayClick));

    $(dialog).removeClass('dialog-hidden');
    $(dialog).addClass('dialog-visible');
  }

  hiddenCreateEventDialog = function() {
    var dialog = $('#new-event-dialog');
    $(dialog).addClass('dialog-hidden');
    $(dialog).removeClass('dialog-visible');
    $('#event-title').val('');
    $('#start-time').val('');
    $('#finish-time').val('')
  }

  $('#new-event-btn').on('click', function(event) {
    event.preventDefault();
    var form =  $('#new_event');
    event_title = $('#event-title').val();
    $.ajax({
      url: $(form).attr('action'),
      type: 'POST',
      dataType: 'script',
      data: $(form).serialize(),
      success: function(data) {
        var eventData;
        eventData = {
          title: event_title,
          start: start_time,
          end: end_time
        };
        $('#full-calendar').fullCalendar('renderEvent', eventData, true);
        $('#full-calendar').fullCalendar('unselect');
      }
    });
  });

  function setDateTime(start, end) {
    start_time = start;
    end_time = end;
  }

  function eventDateTimeFormat(startTime, endTime, dayClick) {
    if (dayClick) {
      return startTime.format('dddd DD-MM-YYYY');
    } else {
      return startTime.format('dddd') + ' ' + startTime.format('H:mm A') + ' To '
        + endTime.format('H:mm A') + ' ' + startTime.format('DD-MM-YYYY');
    }
  }

  function dateTimeFormat(dateTime, dayClick) {
    if(dayClick)
      return dateTime.format('dddd DD-MM-YYYY');
    return dateTime.format('MMMM Do YYYY, h:mm:ss a');
  }
});

$(document).ready(function() {
  var start_date, finish_date, event_title;

  $('#full-calendar').fullCalendar({
    header: {
      left: 'today prev,next',
      center: 'title',
      right: 'agendaDay,agendaWeek,agendaFourDay,month'
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
            return {title: data.title, start: data.start_date,
              end: data.finish_date, id: data.id}
          });
          callback(events);
        }
      });
    },
    eventClick: function(event, jsEvent, view) {
      $('#popup').offset({left: jsEvent.pageX-200, top: jsEvent.pageY});
      $('#popup').css('visibility', 'visible');
      popupOriginal();
      if(event.title == '')
        $('#title-popup').html(I18n.t('calendars.events.no_title'));
      else
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
    dayClick: function(date, jsEvent, view) {
      showCreateEventDialog(date, date, jsEvent, true);
      setDateTime(date, date);
    },
    select: function(start, end, jsEvent) {
      showCreateEventDialog(start, end, jsEvent, false);
      setDateTime(start, end);
    },
    eventResize: function(event, delta, revertFunc) {
      updateEvent(event);
    },
    eventDrop: function(event, delta, revertFunc) {
      updateEvent(event);
    }
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
      if(event.title == '')
        event.title = I18n.t('calendars.events.no_title');
      updateEvent(event);
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

  $('.cancel-popup-event').click(function() {
    $('#popup').css('visibility', 'hidden');
    $('#title-input-popup').val('');
  });

  function popupOriginal() {
    $('#title-input-popup').val('');
    $('.data-display').css('display', 'inline-block');
    $('.data-none-display').css('display', 'none');
  }

  function updateEvent(event){
    setDateTime(event.start, event.end);
    var id = event.id;
    url = '/api/events/' + id;
    $.ajax({
      url: url,
      data: {
        title: event.title,
        start: start_date.format(),
        end: finish_date.format()
      },
      type: 'PUT',
      dataType: 'text',
      success: function(text) {
        $('#full-calendar').fullCalendar('updateEvent', event);
      }
    });
  }

  $('.fc-prev-button, .fc-next-button, .fc-today-button').click(function() {
    var moment = $('#full-calendar').fullCalendar('getDate');
    $('#mini-calendar').datepicker();
    $('#mini-calendar').datepicker('setDate', new Date(moment.format('MM/DD/YYYY')));
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
    if ($('#collapse1').hasClass('in')){
      $('#collapse1').removeClass('in')
    } else{
      $('#collapse1').addClass('in')
    };
  });

  $(document).click(function() {
    if (!$(event.target).hasClass('create')
      && !$(event.target).closest('#event-popup').hasClass('dropdown-menu')){
      $('#source-popup').removeClass('open');
    }
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
          start: start_date,
          end: finish_date
        };
        $('#full-calendar').fullCalendar('renderEvent', eventData, true);
        $('#full-calendar').fullCalendar('unselect');
      }
    });
  });

  function setDateTime(start, end) {
    start_date = start;
    finish_date = end;
  }

  function eventDateTimeFormat(startDate, endDate, dayClick) {
    if (dayClick) {
      return startDate.format('dddd DD-MM-YYYY');
    } else {
      return startDate.format('dddd') + ' ' + startDate.format('H:mm A') + ' To '
        + endDate.format('H:mm A') + ' ' + startDate.format('DD-MM-YYYY');
    }
  }

  function dateTimeFormat(dateTime, dayClick) {
    if(dayClick)
      return dateTime.format('dddd DD-MM-YYYY');
    return dateTime.format('MMMM Do YYYY, h:mm:ss a');
  }
});

$(document).on('page:change', function() {
  var start_date, finish_date, event_title;

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
    eventLimit: true,
    selectable: {
      month: false,
      agenda: true
    },
    height: $(window).height() - $('header').height() - 9,
    events: function(start, end, timezone, callback) {
      var calendars = [];
      $('input:checkbox[class=calendar-select]:checked').each(function(){
        calendars.push($(this).val());
      });
      $.ajax({
        url: '/api/events',
        data: {
          calendars: calendars
        },
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
      popupOriginal();
      initDialogEventClick(event);
      dialogCordinate(jsEvent, 'popup', 'prong-popup');
      hiddenDialog('new-event-dialog');
      showDialog('popup');
      unSelectCalendar();
      deleteEventPopup(event);
      clickEditTitle(event);
    },
    dayClick: function(date, jsEvent, view) {
      setDateTime(date, date);
      initDialogCreateEvent(date, date, true);
      dialogCordinate(jsEvent, 'new-event-dialog', 'prong');
      hiddenDialog('popup');
      showDialog('new-event-dialog');
    },
    select: function(start, end, jsEvent) {
      setDateTime(start, end);
      initDialogCreateEvent(start, end, false);
      dialogCordinate(jsEvent, 'new-event-dialog', 'prong');
      hiddenDialog('popup');
      showDialog('new-event-dialog');
    },
    eventResize: function(event, delta, revertFunc) {
      updateEvent(event);
    },
    eventDrop: function(event, delta, revertFunc) {
      updateEvent(event);
    }
  });

  function initDialogEventClick(event) {
    if(event.title == '')
      $('#title-popup').html(I18n.t('calendars.events.no_title'));
    else
      $('#title-popup').html(event.title);
    $('#time-event-popup').html(eventDateTimeFormat(event.start, event.end, false));
    var edit_url = '/users/' + $('#current-user-id-popup').html() +
     '/events/' + event.id + '/edit';
    $('#btn-edit-event').attr('href', edit_url);
  }

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
      hiddenDialog('popup');
      url = '/api/events/' + event.id;
      if(event.title == '')
        event.title = I18n.t('calendars.events.no_title');
      updateEvent(event);
    });
  }

  function deleteEventPopup(event) {
    $('#btn-delete-event').unbind('click');
    $('#btn-delete-event').click(function() {
      hiddenDialog('popup');
      var temp = confirm(I18n.t('calendars.events.confirm_delete_event'));
      if (temp === true) {
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
    hiddenDialog('popup');
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
        $('#full-calendar').fullCalendar('gotoDate', new Date(Date.parse(dateText)));
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

  $('.caret').click(function() {
    if ($(this).closest('div').hasClass('open')) {
      $(this).closest('div').removeClass('open');
    }
    else{
      $(this).closest('div').addClass('open');
      event.stopPropagation();
    };
  });

  $('#clst_my').click(function() {
    if ($('#collapse1').hasClass('in')) {
      $('#collapse1').removeClass('in')
      $('.zippy-arrow').css({'background-position': '-153px -81px'});
    } else{
      $('#collapse1').addClass('in')
      $('.zippy-arrow').css({'background-position': '-141px -81px'});
    };
  });

  $(document).click(function() {
    if (!$(event.target).hasClass('create')
      && !$(event.target).closest('#event-popup').hasClass('dropdown-menu')){
      $('#source-popup').removeClass('open');
    }

    if (($(event.target).closest('#new-event-dialog').length == 0)
      && ($(event.target).closest('.fc-body').length == 0)) {
      hiddenDialog('new-event-dialog');
    }

    if (($(event.target).closest('#popup').length == 0)
      && ($(event.target).closest('.fc-body').length == 0)) {
      hiddenDialog('popup');
    }
  });

  $(document).keydown(function(e) {
    if (e.keyCode == 27) {
      $('#source-popup').removeClass('open');
      $('#sub-menu-my-calendar, #menu-of-calendar').removeClass('sub-menu-visible');
      $('#sub-menu-my-calendar, #menu-of-calendar').addClass('sub-menu-hidden');
      $('.list-group-item').removeClass('background-hover');
    }
  });

  $('#title-event-value').bind('keypress keydown keyup change', function() {
    var title = $('#title-event-value').val();
    var user_id = $('#current-user-id-popup').html();
    var edit_link = 'users/' + user_id.toString()
      + '/events/new?event%5Btitle%5D=' + title.toString();
    $('#link-to-event').attr('href', edit_link);
  });

  $('#clst_my_menu').click(function() {
    var position = $('#clst_my_menu').offset();
    $('#menu-of-calendar').removeClass('sub-menu-visible');
    $('#menu-of-calendar').addClass('sub-menu-hidden');
    $('#source-popup').removeClass('open');
    $('#sub-menu-my-calendar').css({'top': position.top + 13, 'left': position.left});
    if ($('#sub-menu-my-calendar').hasClass('sub-menu-visible')){
      $('#sub-menu-my-calendar').removeClass('sub-menu-visible');
      $('#sub-menu-my-calendar').addClass('sub-menu-hidden');
    } else{
      $('#sub-menu-my-calendar').removeClass('sub-menu-hidden');
      $('#sub-menu-my-calendar').addClass('sub-menu-visible');
    };
    event.stopPropagation();
  });

  $(document).click(function() {
    $('#sub-menu-my-calendar').removeClass('sub-menu-visible');
    $('#sub-menu-my-calendar').addClass('sub-menu-hidden');
    if (!$(event.target).hasClass('clstMenu-child')) {
      $('#menu-of-calendar').removeClass('sub-menu-visible');
      $('#menu-of-calendar').addClass('sub-menu-hidden');
    };
    if ($('#menu-of-calendar').hasClass('sub-menu-hidden')) {
      $('.list-group-item').removeClass('background-hover');
    };
  });

  $('.clstMenu-child').click(function() {
    var windowH = $(window).height();
    var position = $(this).offset();
    $('#id-of-calendar').html($(this).attr('id'));
    var menu_height = $('#menu-of-calendar').height();
    if ((position.top + 12 + menu_height) >= windowH ) {
      $('#menu-of-calendar').
        css({'top': position.top - menu_height - 2, 'left': position.left});
    }else {
      $('#menu-of-calendar').
        css({'top': position.top + 12, 'left': position.left});
    };
    if ($('#menu-of-calendar').hasClass('sub-menu-visible')) {
      $('#menu-of-calendar').removeClass('sub-menu-visible');
      $('#menu-of-calendar').addClass('sub-menu-hidden');
      $(this).parent().removeClass('background-hover');
    } else{
      $('#menu-of-calendar').removeClass('sub-menu-hidden');
      $('#menu-of-calendar').addClass('sub-menu-visible');
      $(this).parent().addClass('background-hover');
    };
  });

  $('#edit-calendar').click(function() {
    var id_calendar = $('#id-of-calendar').html();
    var user_id = $('#current-user-id-popup').html();
    var edit_link = 'users/' + user_id.toString()
      + '/calendars/' + id_calendar.toString() + '/edit';
    $('#edit-calendar').attr('href', edit_link);
  });

  $('#full-calendar').bind('mousewheel', function(e) {
    var view = $('#full-calendar').fullCalendar('getView');
    if (view.name == 'month') {
      if(e.originalEvent.wheelDelta > 0) {
        $('#full-calendar').fullCalendar('next');
      } else{
        $('#full-calendar').fullCalendar('prev');
      };
      var moment = $('#full-calendar').fullCalendar('getDate');
      $('#mini-calendar').datepicker();
      $('#mini-calendar').datepicker('setDate', new Date(moment.format('MM/DD/YYYY')));
    };
  });

  $('#mini-calendar').bind('mousewheel', function(e) {
    if(e.originalEvent.wheelDelta > 0) {
      $('.ui-datepicker-next').click();
    } else{
      $('.ui-datepicker-prev').click();
    };
  });

  $('#bubble-close').click(function() {
    unSelectCalendar();
    hiddenDialog('new-event-dialog');
  });

  function dialogCordinate(jsEvent, dialogId, prongId) {
    var dialog = $('#' + dialogId);
    var dialogW = $(dialog).width();
    var dialogH = $(dialog).height();
    var windowW = $(window).width();
    var windowH = $(window).height();
    var xCordinate, yCordinate;
    var prongRotateX, prongXCordinate, prongYCordinate;

    if(jsEvent.clientX - dialogW/2 < 0) {
      xCordinate = jsEvent.clientX - dialogW/2;
    } else if(windowW - jsEvent.clientX < dialogW/2) {
      xCordinate = windowW - 2 * dialogW/2 - 10;
    } else {
      xCordinate = jsEvent.clientX - dialogW/2;
    }

    if(jsEvent.clientY - dialogH < 0) {
      yCordinate = jsEvent.clientY + 20;
      prongRotateX = 180;
      prongYCordinate = -9;
    } else {
      yCordinate = jsEvent.clientY - dialogH - 20;
      prongRotateX = 0;
      prongYCordinate = dialogH;
    }

    prongXCordinate = jsEvent.clientX - xCordinate - 10;

    $(dialog).css({'top': yCordinate, 'left': xCordinate});
    $('#' + prongId).css({
      'top': prongYCordinate,
      'left': prongXCordinate,
      'transform': 'rotateX(' + prongRotateX + 'deg)'
    });
  }

  function initDialogCreateEvent(start, end, dayClick) {
    var title = $('#event-title');
    $(title).focus();
    $(title).val('');
    $('#start-time').val(dateTimeFormat(start, dayClick));
    $('#finish-time').val(dateTimeFormat(end, dayClick));
    $('.event-time').text(eventDateTimeFormat(start, end, dayClick));
  }

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

  function unSelectCalendar() {
    $('#full-calendar').fullCalendar('unselect');
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
      success: function(data) {}
    });
  });

  $('#edit-event-btn').on('click', function(event) {
    event.preventDefault();
    var form =  $('#new_event');
    var url = $(form).attr('action') + '/new';
    var data = $(form).serialize();
    window.location.href = url + '?data='+ data;
  });

  $('#event-title').click(function(event) {
    $('.error-title').text('');
  });

  function setDateTime(start, end) {
    start_date = start;
    finish_date = end;
  }

  function eventDateTimeFormat(startDate, finishDate, dayClick) {
    if (dayClick) {
      return startDate.format('dddd DD-MM-YYYY');
    } else {
      return startDate.format('dddd') + ' ' + startDate.format('H:mm A') + ' To '
        + finishDate.format('H:mm A') + ' ' + startDate.format('DD-MM-YYYY');
    }
  }

  function dateTimeFormat(dateTime, dayClick) {
    if(dayClick)
      return dateTime.format('dddd DD-MM-YYYY');
    return dateTime.format('MMMM Do YYYY, h:mm:ss a');
  }

  $('.calendar-select').change(function(event) {
    $('#full-calendar').fullCalendar('removeEvents');
    $('#full-calendar').fullCalendar('refetchEvents');
  });
});

$(document).on('page:change', function() {
  var start_date, finish_date, event_title;
  var GMT_0 = -420;
  var lastestView;
  if (localStorage.getItem('lastestView') != 'undefined')
    lastestView = localStorage.getItem('lastestView');
  else
    lastestView = 'agendaWeek';

  $('#full-calendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'agendaDay,agendaWeek,month,agendaFourDay'
    },
    views: {
      agendaFourDay: {
        type: 'agenda',
        duration: {days: 4},
        buttonText: '4 days'
      }
    },
    borderColor: '#ffffff',
    eventColor: '#4285f4',
    defaultView: lastestView,
    editable: true,
    selectHelper: true,
    unselectAuto: false,
    nowIndicator: true,
    allDaySlot: true,
    eventLimit: true,
    allDayDefault: false,
    selectable: {
      month: false,
      agenda: true
    },
    height: $(window).height() - $('header').height() - 9,
    events: function(start, end, timezone, callback) {
      var calendars = [];
      $('input:checkbox[class=calendar-select]:checked').each(function() {
        calendars.push($(this).val());
      });
      var start_time_view = $('#full-calendar').fullCalendar('getView').start;
      var end_time_view = $('#full-calendar').fullCalendar('getView').end;
      $.ajax({
        url: '/api/events',
        data: {
          calendars: calendars,
          start_time_view: start_time_view.format(),
          end_time_view: end_time_view.format(),
        },
        dataType: 'json',
        success: function(doc) {
          var events = [];
          events = doc.map(function(data) {
            return {
              title: data.title,
              start: data.start_date,
              end: data.finish_date,
              id: data.id,
              className: 'color-' + data.color_id,
              calendar: data.calendar,
              allDay: data.all_day,
              repeat_type: data.repeat_type,
              end_repeat: data.end_repeat,
              event_id: data.event_id,
              exception_type: data.exception_type,
              editable: data.editable,
            }
          });
          callback(events);
        }
      });
    },
    eventRender: function(event, element) {
      if(event.allDay === false) {
        if(event.end && event.end.isBefore(new Date()))
          $(element).addClass('before-current');
      }
      else {
        if(event.start.isBefore(new Date(), 'day'))
          $(element).addClass('before-current');
      }
    },
    eventClick: function(event, jsEvent, view) {
      localStorage.setItem('current_event', event)
      if(event.title) {
        initDialogEventClick(event, jsEvent);
      } else {
        dialogCordinate(jsEvent, 'new-event-dialog', 'prong');
        showDialog('new-event-dialog');
        $('#event-title').focus();
      }
    },
    dayClick: function(date, jsEvent, view) {
      if(view.name === 'month') {
        date_start = $.extend(true, {}, date);
        date_end = $.extend(true, {}, date);

        date_start = moment(date_start._d).startOf('day');
        date_end = moment(date_end._d).endOf('day');

        setDateTime(date_start, date_end);
        initDialogCreateEvent(date_start, date_end, true);
        dialogCordinate(jsEvent, 'new-event-dialog', 'prong');
        hiddenDialog('popup');
        showDialog('new-event-dialog');
      }
    },
    select: function(start, end, jsEvent) {
      if(end._d.getDate() != start._d.getDate()){
        $('#full-calendar').fullCalendar('unselect');
      } else {
        setDateTime(start, end);
        initDialogCreateEvent(start, end, false);
        dialogCordinate(jsEvent, 'new-event-dialog', 'prong');
        hiddenDialog('popup');
        showDialog('new-event-dialog');
      }
    },
    eventResizeStart: function( event, jsEvent, ui, view ) {
      hiddenDialog('new-event-dialog');
      hiddenDialog('popup');
      setDateTime(event.start, event.end);
    },
    eventResize: function(event, delta, revertFunc) {
      if (event.repeat_type == null || event.repeat_type.length == 0 ||
        event.exception_type == 'edit_only') {
        if (event.exception_type != null)
          exception_type = event.exception_type;
        else
          exception_type = null;
        updateEvent(event, 0, exception_type, 0);
      } else {
        if(event.end.format('DD') == event.start.format('DD')) {
          end_date = event.end;
          event.end = finish_date;
          confirm_update_popup(event, 0, end_date);
        }else {
          event.end = finish_date;
          alert(I18n.t('events.flashs.not_updated'));
        }
      }
      hiddenDialog('new-event-dialog');
      hiddenDialog('popup');
    },
    eventDragStart: function( event, jsEvent, ui, view ) {
      hiddenDialog('new-event-dialog');
      hiddenDialog('popup');
    },
    eventDrop: function(event, delta, revertFunc) {
      allDay = 0;
      if(!event.end) {
        event.end = event.start.clone();
        event.end.add(2, 'hours');
      }
      if(event.allDay) {
        allDay = 1;
        event.end = event.start;
      }

      updateEvent(event, allDay, null, 1);
    }
  });

  function initDialogEventClick(event, jsEvent){
    if ($('#popup') !== null)
      $('#popup').remove();
    $.ajax({
      url: 'api/events/' + event.event_id,
      data: {
        title: event.title,
        start: event.start.format('MM-DD-YYYY H:mm A'),
        end: (event.end !== null) ? event.end.format('MM-DD-YYYY H:mm A') : ''
      },
      success: function(data){
        $('#calcontent').append(data);
        dialogCordinate(jsEvent, 'popup', 'prong-popup');
        hiddenDialog('new-event-dialog');
        showDialog('popup');
        unSelectCalendar();
        deleteEventPopup(event);
        if (event.editable){
          clickEditTitle(event);
        }
        cancelPopupEvent(event);
      }
    });
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
    $('#btn-save-event').unbind('click');
    $('#btn-save-event').click(function() {
      hiddenDialog('popup');
      allDay = 0;
      if(event.allDay)
        allDay = 1;
      if (event.repeat_type == null || event.repeat_type.length == 0 || event.exception_type == 'edit_only') {
        if (event.exception_type != null)
          exception_type = event.exception_type;
        else
          exception_type = null;
        updateEvent(event, 0, exception_type, 0);
      } else {
        confirm_update_popup(event, allDay, event.end);
      }
    });
  }

  function deleteEventPopup(event) {
    $('#btn-delete-event').unbind('click');
    $('#btn-delete-event').click(function() {
      hiddenDialog('popup');
      if (event.repeat_type == null || event.repeat_type.length == 0 || event.exception_type == 'edit_only') {
        deleteEvent(event, 'delete_only');
      } else {
        confirm_repeat_popup(event);
      }
    });
  }

  function deleteEvent(event, exception_type) {
    var start_date_before_delete, finish_date_before_delete;
    if (event.allDay !== true){
      start_date_before_delete = event.start._i;
      finish_date_before_delete = event.end._i;
    };
    $.ajax({
      url: '/api/events/' + event.event_id,
      type: 'DELETE',
      data: {
        exception_type: exception_type,
        exception_time: event.start.format(),
        finish_date: (event.end !== null) ? event.end.format('MM-DD-YYYY H:mm A') : '',
        start_date_before_delete: start_date_before_delete,
        finish_date_before_delete: finish_date_before_delete,
      },
      dataType: 'text',
      success: function(text){
        var _event = event;
        var count = 0;
        if(exception_type == 'delete_all_follow')
          $('#full-calendar').fullCalendar('removeEvents', function(e){
            if(e.event_id == event.event_id && e.start.format() >= event.start.format())
              return true;
          });
        else
          if(exception_type == 'delete_all')
            $('#full-calendar').fullCalendar('removeEvents', function(e){
              if(e.event_id == event.event_id)
                return true;
            });
          else
            event.exception_type = exception_type;
            $('#full-calendar').fullCalendar('removeEvents', event.id);
      },
      error: function(text) {
      }
    });
  }

  function confirm_repeat_popup(event){
    var dialog = $('#dialog-repeat-popup');
    var dialogW = $(dialog).width();
    var dialogH = $(dialog).height();
    var windowW = $(window).width();
    var windowH = $(window).height();
    var xCordinate, yCordinate;
    xCordinate = (windowW - dialogW) / 2;
    yCordinate = (windowH - dialogH) / 2;
    dialog.css({'top': yCordinate, 'left': xCordinate});
    showDialog('dialog-repeat-popup');

    $('.btn-confirm').click(function() {
      deleteEvent(event, $(this).attr('rel'));
      hiddenDialog('dialog-repeat-popup');
    });
  }

  $('.btn-cancel, .bubble-close').click(function(event) {
    hiddenDialog('dialog-update-popup');
  });

  function cancelPopupEvent(event){
    $('#calcontent').on('click', '.cancel-popup-event', function() {
      event.title = $('#title-popup').text().trim();
      hiddenDialog('popup');
      hiddenDialog('dialog-repeat-popup');
      hiddenDialog('dialog-update-popup');
    });
  }

  function updateEvent(event, allDay, exception_type, is_drop) {
    var start_time_before_drag, finish_time_before_drag;
    event.end ? setDateTime(event.start, event.end) : setDateTime(event.start, event.start);

    if(event.title == '')
      event.title = I18n.t('calendars.events.no_title');

    if (event.allDay !== true){
      start_time_before_drag = event.start._i;
      finish_time_before_drag = event.end._i;
    };

    $.ajax({
      url: '/api/events/' + event.event_id,
      data: {
        event: {
          title: event.title,
          start_date: start_date.format(),
          finish_date: finish_date.format(),
          all_day: allDay,
          exception_type: exception_type,
          end_repeat: event.end_repeat
        },
        is_drop: is_drop,
        start_time_before_drag: start_time_before_drag,
        finish_time_before_drag: finish_time_before_drag
      },
      type: 'PUT',
      dataType: 'json',
      success: function(data) {
        event.event_id = data.event.id;
        event.exception_type = data.event.exception_type;
        $('#full-calendar').fullCalendar('updateEvent', event);

        if(exception_type == 'edit_all_follow' || exception_type == 'edit_all')
          $('#full-calendar').fullCalendar('refetchEvents');
        else
          $('#full-calendar').fullCalendar('renderEvent', event, true);
      }
    });
  }

  function confirm_update_popup(event, allDay, end_date){
    var dialog = $('#dialog-update-popup');
    var dialogW = $(dialog).width();
    var dialogH = $(dialog).height();
    var windowW = $(window).width();
    var windowH = $(window).height();
    var xCordinate, yCordinate;
    xCordinate = (windowW - dialogW) / 2;
    yCordinate = (windowH - dialogH) / 2;
    dialog.css({'top': yCordinate, 'left': xCordinate});
    showDialog('dialog-update-popup');
    $('.btn-confirm').unbind('click');
    $('.btn-confirm').click(function() {
      event.end = end_date;
      updateEvent(event, allDay, $(this).attr('rel'), 0);
      hiddenDialog('dialog-update-popup');
    });
  }

  function saveLastestView() {
    localStorage.setItem('lastestView', $('#full-calendar').fullCalendar('getView').type);
  }

  $('.fc-prev-button, .fc-next-button, .fc-today-button').click(function() {
    var moment = $('#full-calendar').fullCalendar('getDate');
    $('#mini-calendar').datepicker();
    $('#mini-calendar').datepicker('setDate', new Date(moment.format('MM/DD/YYYY')));
  });

  $('#mini-calendar').datepicker({
    dateFormat: 'DD, d MM, yy',
    showOtherMonths: true,
    selectOtherMonths: true,
      onSelect: function(dateText,dp) {
        $('#full-calendar').fullCalendar('gotoDate', new Date(Date.parse(dateText)));
        $('#mini-calendar').datepicker('setDate', new Date(Date.parse(dateText)));
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
      $('#my-zippy-arrow').css({'background-position': '-153px -81px'});
    } else{
      $('#collapse1').addClass('in')
      $('#my-zippy-arrow').css({'background-position': '-141px -81px'});
    };
  });

  $('#clst_other').click(function() {
    if ($('#collapse2').hasClass('in')) {
      $('#collapse2').removeClass('in')
      $('#other-zippy-arrow').css({'background-position': '-153px -81px'});
    } else{
      $('#collapse2').addClass('in')
      $('#other-zippy-arrow').css({'background-position': '-141px -81px'});
    };
  });

  $('#title-mini-calendar').click(function() {
    $('#mini-calendar').removeClass('out');
    $('#title-mini-calendar').removeClass('in');
  });

  $('.ui-datepicker-title').click(function() {
    $('#title-mini-calendar').addClass('in');
    $('#mini-calendar').addClass('out');
  });

  $('.ui-datepicker').on('click', '.ui-datepicker-title', function() {
    $('#title-mini-calendar').addClass('in');
    $('#mini-calendar').addClass('out');
  });

  $(document).click(function() {
    if ($('.fc-view-container').length != 0)
      saveLastestView();

    if (!$(event.target).hasClass('create')
      && !$(event.target).closest('#event-popup').hasClass('dropdown-menu')){
      $('#source-popup').removeClass('open');
    }

    if (($(event.target).closest('#new-event-dialog').length == 0)
      && ($(event.target).closest('.fc-body').length == 0)) {
      hiddenDialog('new-event-dialog');
      unSelectCalendar();
    }

    if (($(event.target).closest('#popup').length == 0)
      && ($(event.target).closest('.fc-body').length == 0)) {
      hiddenDialog('popup');
    }
    if (($(event.target).closest('#dialog-repeat-popup').length == 0) &&
      ($(event.target).closest('#btn-delete-event').length ==0)) {
      hiddenDialog('dialog-repeat-popup');
    }
  });

  $(document).keydown(function(e) {
    if (e.keyCode == 27) {
      $('#source-popup').removeClass('open');
      $('#sub-menu-my-calendar, #menu-of-calendar, #sub-menu-setting').removeClass('sub-menu-visible');
      $('#sub-menu-my-calendar, #menu-of-calendar, #sub-menu-setting').addClass('sub-menu-hidden');
      $('.list-group-item').removeClass('background-hover');
      $('.sub-list').removeClass('background-hover');
      hiddenDialog('new-event-dialog');
      hiddenDialog('popup');
      hiddenDialog('dialog-update-popup');
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
      $('.sub-list').removeClass('background-hover');
    };
  });

  $('.clstMenu-child').click(function() {
    var windowH = $(window).height();
    var position = $(this).offset();
    if ($(this).find('.sub').length > 0)
      $('#create-sub-calendar').addClass('hidden-menu');
    else
      $('#create-sub-calendar').removeClass('hidden-menu');
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
      $('input:checkbox[class=input-assumpte]:checked').prop('checked', false);
      rel = $(this).attr('rel');
      $('input:checkbox[id=input-color-' + rel+ ']').prop('checked', true);
      $('#menu-calendar-id').attr('rel', $(this).attr('id'));
    };
  });

  $('#create-sub-calendar').click(function() {
    var id_calendar = $('#id-of-calendar').html();
    var user_id = $('#current-user-id-popup').html();
    var create_sub_link = 'users/' + user_id.toString()
      + '/calendars/' + 'new?parent_id=' + id_calendar.toString();
    $('#create-sub-calendar').attr('href', create_sub_link);
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

  $('.disable').addClass('disable-on');

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
    var allDayClick = !start._i;
    $('#all-day').val(dayClick || allDayClick ? '1' : '0');
    $('.event-time').text(eventDateTimeFormat(start, end, dayClick || allDayClick));
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

    obj = Object();
    var data = $(form).serializeArray();

    $.each(data, function(_, element) {
      if (element.name.indexOf('start_date') > 0) {
        obj['start_date'] = element.value
      } else if(element.name.indexOf('finish_date') > 0) {
        obj['finish_date'] = element.value
      } else if(element.name.indexOf('all_day') > 0) {
        obj['all_day'] = element.value
      } else if(element.name.indexOf('title') > 0) {
        obj['title'] = element.value
      }
    });

    content = JSON.stringify({event: obj})

    window.location.href = url + '?fdata='+ Base64.encode(content);
  });

  $('#event-title').click(function(event) {
    $('.error-title').text('');
  });

  function setDateTime(start, end) {
    start_date = start;
    finish_date = end;
  }

  function eventDateTimeFormat(startDate, finishDate, dayClick) {
    if (dayClick || finishDate == null) {
      return startDate.zone(GMT_0).format('MMMM Do YYYY');
    } else {
      return startDate.format('dddd') + ' ' + startDate.format('H:mm A') + ' To '
        + finishDate.format('H:mm A') + ' ' + finishDate.format('DD-MM-YYYY');
    }
  }

  function dateTimeFormat(dateTime, dayClick) {
    if(dayClick)
      return dateTime.zone(GMT_0).format('MMMM Do YYYY, HH:mm:ss');
    return dateTime.format('MMMM Do YYYY, h:mm:ss a');
  }

  $('.calendar-select').change(function(event) {
    $('#full-calendar').fullCalendar('removeEvents');
    $('#full-calendar').fullCalendar('refetchEvents');
  });

  $('#calcontent .input-assumpte').change(function() {
    $('input:checkbox[class=input-assumpte]:checked').not(this).prop('checked', false);
    color_id = $(this).attr('rel');
    calendar_id = $('#menu-calendar-id').attr('rel');
    url = '/api/calendars/' + calendar_id
    $.ajax({
      url: url,
      method: 'PUT',
      data: {
        color_id: color_id,
      },
      success: function(data) {
        $('#' + calendar_id).attr('rel', color_id);
        $('#label-calendar-select-' + calendar_id).removeClass().addClass('color-' + color_id);
        $('#full-calendar').fullCalendar('removeEvents');
        $('#full-calendar').fullCalendar('refetchEvents');
      }
    });
  });

  $('#new_calendar .input-assumpte').change(function() {
    checkedColor(this);
  });

  $('.edit_calendar .input-assumpte').change(function() {
    checkedColor(this);
  });

  function checkedColor(e) {
    $('input:checkbox[class=input-assumpte]:checked').not(e).prop('checked', false);
    color_id = $(e).attr('rel');
    $('#calendar_color_id').val(color_id);
  }

  if ($('#make_public').val() == 'public_hide_detail') {
    $('#make_public').prop('checked', true);
    $('#free_busy').prop('checked', true);
  }
  else if ($('#make_public').val() == 'share_public') {
    $('#make_public').prop('checked', true);
  }
  else if ($('#make_public').val() == 'no_public') {
    $('#make_public').prop('checked', false);
    $('#free_busy').prop('disabled', true);
  };

  $('#make_public').click(function() {
    $('#make_public').val((this.checked) ? 'share_public' : 'no_public');
    $('#free_busy').prop('disabled', (this.checked) ? false : true);
  });

  $('#free_busy').click(function() {
    $('#make_public').val(($('#free_busy').prop('checked')) ? 'public_hide_detail' : 'share_public');
  });

  /* share-calendar*/

  $('#textbox-email-share').select2({
    tokenSeparators: [',', ' '],
    width: '90%'
  });

  var current_user = $('#current_user').val();
  var user_ids = [current_user];

  $('.user_share_ids').each(function() {
    user_id_temp = $(this).val();
    if ($.inArray(user_id_temp, user_ids) == -1) {
      user_ids.push(user_id_temp);
    };
  });

  $('#add-person').click(function() {
    var user_id = $('#textbox-email-share').val();
    var email = $('#textbox-email-share').find('option:selected').text();
    var permission = $('#permission-select').val();
    if (user_id) {
      $.ajax({
        url: '/api/calendars/new',
        method: 'get',
        data: {
          user_id: user_id,
          email: email,
          permission: permission,
        },
        success: function(html) {
          if ($.inArray(user_id, user_ids) == -1) {
            if($('#user-calendar-share-' + user_id).length > 0) {
              $('#user-calendar-share-' + user_id).css('display', 'block');
              $('#user-calendar-share-' + user_id).find('.user_calendar_destroy').val(false);
              per_id_new = $('#permission-select').val();
              $('#user-calendar-share-' + user_id).find('#permission-select-share').val(per_id_new);
            }
            else {
              $('#list-share-calendar').append(html);
              user_ids.push(user_id);
            }
          };
        }
      });
    }
    $('#textbox-email-share').val('');
    $('#select2-textbox-email-share-container').html('');
  });

  $('#list-share-calendar').on('click', '.image-remove', function() {
    $(this).parent().parent().find('.user_calendar_destroy').val('1');
    $(this).parent().parent().hide();
    index = user_ids.indexOf($(this).prop('id'));
    if (index !== -1)
      user_ids.splice(index, 1);
  });

  $('#request-email-button').click(function() {
    $.ajax({
      url: '/api/request_emails/new',
      data: {
        request_email: $('#request-email-input').val()
      },
      type: 'GET',
      dataType: 'text',
      success: function(text) {
        alert(text);
      }
    });
  });

  $('#add-attendee').on('click', function() {
    id = $('#list-attendee').find('li').length;
    attendee = $('#load-attendee').val();
    exitEmail(attendee);
    if (validateEmail(attendee)){
      list_attendee = document.getElementById('list-attendee');
      if(!exitEmail(attendee)){
        var attendee_form = $('#group_attendee_'+(id-1)).clone()[0];

        var group_attendee = $('#group_attendee_'+(id-1));

        $(group_attendee).find('li')[0].innerHTML = attendee;
        $(group_attendee).find('input[type=hidden]')[0].value = attendee;
        $(group_attendee).find('input[type=hidden]')[1].value = false;
        $(group_attendee).show();

        attendee_form.id = 'group_attendee_'+id;
        $(attendee_form).find('input[type=hidden]')[0].name = 'event[attendees_attributes]['+id+'][email]';
        $(attendee_form).find('input[type=hidden]')[1].name = 'event[attendees_attributes]['+id+'][_destroy]';
        $(attendee_form).find('input[type=hidden]')[1].value = true
        list_attendee.appendChild(attendee_form);
        $('#load-attendee').val('');
        $('#load-attendee').focus();
      }else {
        alert(I18n.t('events.flashs.attendee_added'));
      }
    }else {
      alert(I18n.t('events.flashs.invalid_email'));
    }
  });

  $('#list-attendee').on('click', '.remove_attendee', function(event){
    $(this).prev().prev('input[type=hidden]').val(true)
    $(this).parent().hide();
  });

  $('.calendar-address').on('click', function() {
    $('.cal-dialog').css('display', 'block');
  });

  $('.cal-dialog-title-close, .goog-buttonset-default').on('click', function() {
    $('.cal-dialog').css('display', 'none');
  });

  $(document).on('click', '.btn-confirmation-repeat', function() {
    var current_event = localStorage.getItem('current_event');
    var allDay = current_event.allDay;
    confirm_update_popup(current_event, allDay, current_event.end);
  });
});

function validateEmail(email) {
  var email = document.getElementById('load-attendee')
  var re = /^(([^<>()\[\]\\.,;:\s@']+(\.[^<>()\[\]\\.,;:\s@']+)*)|('.+'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  if (!re.test(email.value)) {
    return false;
  }
  return true;
}

function exitEmail(email) {
  for(var i = 0; i < $('#list-attendee').find('li').length; i++){
    if(email == $('#list-attendee').find('li')[i].innerHTML
      && $($('#list-attendee').find('li')[i]).parent().find('input[type=hidden]')[1].value == 'false'){
      return true;
    }
  };
  return false;
}

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
            return {title: data.title, start: data.start_time, end: data.end_time}
          });
          callback(events);
        }
      });
    }
  });

  $('#mini-calendar').datepicker({
    dateFormat: 'DD, d MM, yy',
      onSelect: function(dateText,dp){
        $('#full-calendar').fullCalendar('gotoDate',new Date(Date.parse(dateText)));
        $('#full-calendar').fullCalendar('changeView','agendaWeek');
      }
  });

  $('.create').click(function(){
    if ($(this).parent().hasClass('open')) {
      $(this).parent().removeClass('open');
    }
    else{
      $(this).parent().addClass('open');
    };
  });
});

$(document).ready(function() {
  $('#calendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    defaultDate: '2016-01-12',
    businessHours: true,
    editable: true
  });
});

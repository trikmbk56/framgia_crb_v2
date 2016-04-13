$(document).ready(function() {
  $('#calendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    defaultView: 'agendaWeek',
    businessHours: true,
    editable: true
  });

  $('#miniCalendar').datepicker({
    dateFormat: 'DD, d MM, yy',
      onSelect: function(dateText,dp){
        $('#calendar').fullCalendar('gotoDate',new Date(Date.parse(dateText)));
        $('#calendar').fullCalendar('changeView','agendaDay');
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

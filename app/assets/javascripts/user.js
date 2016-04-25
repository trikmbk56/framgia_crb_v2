function myModal(){
  $('#my-modal')[0].style.display = 'block';
}

function closeModal(){
  $('#my-modal')[0].style.display = 'none';
}

function goBack() {
  window.history.back();
}

$(document).on('page:change', function() {
  var checkbox = [];
  var btn_load = I18n.t('user.info.events.button');

  $('#load-more-event').click(function() {
    $('#load-more-event').html('').addClass('load-gif');
    rel =  Number($('#load-more-event').attr('rel')) + 1;
    $('#load-more-event').attr('rel', rel);
    get_calendar_id();
    $.ajax({
      url: '/api/events',
      data: {
        page: rel,
        calendar_id: checkbox
      },
      success: function(html) {
        if(html == '')
          $('#load-more-event').hide();
        else{
          $('#load-more-event').removeClass('load-gif').html(btn_load).show();
          $('#event-list-id').append(html);
        }
      },
      error: function(html) {
        $('#load-more-event').hide();
      }
    });
  });

  $('.calendar-checkbox').change(function(event) {
    get_calendar_id();
    $.ajax({
      url: '/api/events',
      data: {
        calendar_id: checkbox,
      },
      success: function(html) {
        $('#event-list-id').html(html);
        $('#load-more-event').attr('rel', 1);
        $('#load-more-event').removeClass('load-gif').html(btn_load).show();
      }
    });
  });

  function get_calendar_id(){
    checkbox = [];
    $('input:checkbox[name=checkbox-calendar]:checked').each(function(){
      checkbox.push($(this).val());
    });
  }
});

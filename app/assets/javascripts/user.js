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

  function get_calendar_id() {
    checkbox = [];
    $('input:checkbox[name=checkbox-calendar]:checked').each(function() {
      checkbox.push($(this).val());
    });
  }

  $(document).click(function(e) {
    if ($(event.target).closest('#header-avatar').length == 0) {
      $('#sub-menu-setting').removeClass('sub-menu-visible');
      $('#sub-menu-setting').addClass('sub-menu-hidden');
    }
  });

  $('#header-avatar').click(function() {
    var position = $('#header-avatar').offset();
    $('#sub-menu-setting').css({'top': position.top + 46, 'left': position.left - 110});
    $('#prong-header').css({
      'top': -9,
      'left': 130,
      'transform': 'rotateX(' + 180 + 'deg)'
    });
    if ($('#sub-menu-setting').hasClass('sub-menu-visible')) {
      $('#sub-menu-setting').removeClass('sub-menu-visible');
      $('#sub-menu-setting').addClass('sub-menu-hidden');
    } else {
      $('#sub-menu-setting').removeClass('sub-menu-hidden');
      $('#sub-menu-setting').addClass('sub-menu-visible');
    };
  });
});

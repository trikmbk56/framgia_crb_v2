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

  $('.u-name').hover(function() {
    $('#username-edit').show();
    }, function(){
    $('#username-edit').hide();
  });

  $('.u-email').hover(function() {
    $('#email-edit').show();
    }, function(){
    $('#email-edit').hide();
  });

  $('.edit-info-btn').click(function() {
    if ($(this).parent().attr('class') == 'u-name') {
      $('.u-name').hide();
      $('#u-name-input').show();
    } else {
      $('.u-email').hide();
      $('#u-email-input').show();
    }
  });

  $('.save-info-btn').click(function() {
    if ($(this).parent().attr('id') == 'u-name-input') {
      updateUsername($('#username-input').val());
    } else {
      updateEmail($('#email-input').val());
    }
  }); 

  function updateUsername(newUsername) {
    var user_id = $('#user-id').val();
    var url = '/api/users/' + user_id;
    $.ajax({
      url: url,
      data: {
        user: {
          name: newUsername,
          email: $('#user-email').text()
        },
        status: "UpdateUserInformation"
      },
      type: 'PUT',
      dataType: 'text',
      success: function(text){
        $('#user-name a').text(newUsername);
        $('.u-name').show();
        $('#u-name-input').hide ();
        alert(text);
      }
    });
  }

  function updateEmail(newEmail) {
    var user_id = $('#user-id').val();
    var url = '/api/users/' + user_id;
    $.ajax({
      url: url,
      data: {
        user: {
          name: $('#user-name').text(),
          email: newEmail
        },
        status: "UpdateUserInformation"
      },
      type: 'PUT',
      dataType: 'text',
      success: function(text){
        $('#user-email').text(newEmail);
        $('.u-email').show();
        $('#u-email-input').hide ();
        alert(text);
      }
    });
  }

  $('#choose-file-btn').change(function(event) {
    $('#submit-file-btn').show();
    var files = event.target.files;
    var image = files[0];
    var reader = new FileReader();
    reader.onload = function(file) {
      var img = new Image();
      img.src = file.target.result;
      if (img.width > img.height)
        img.setAttribute("width", "150px");
      else 
        img.setAttribute("height", "150px");
      $('#user-avatar').html(img);
    }
    reader.readAsDataURL(image);;
  });

  $('#submit-file-btn').click(function() {
    $(this).hide();
  });
});

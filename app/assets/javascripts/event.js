$(document).ready(function() {
  $('#attendee').select2({
    multiple: true,
    theme: 'bootstrap',
    tokenSeparators: [',', ' ']
  })
});

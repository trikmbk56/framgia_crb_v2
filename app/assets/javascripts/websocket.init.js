$(document).ready(function() {
  if(Notification.permission !== 'granted') {
    Notification.requestPermission();
  }

  ws_rails = new WebSocketRails(location.host+'/websocket', true);
  ws_rails.on_open = function(data) {
    console.log('Connection has been established: ', data);
  }

  ws_rails.bind('websocket_notify', function(message){
    var title = message['title'];
    var start = message['start'];
    var finish = message['finish'];
    var desc = message['desc']
    var attendees = message['attendees'];
    var from_user = message['from_user'];
    var to_user = message['to_user']
    n = new Notification(title, {
      body: 'Start: ' + start + '\nFinish: ' + finish + '\ndesc: ' + desc
      + '\nFrom: ' + from_user + '\nReciever: ' + to_user});
    n.close();
  });
});

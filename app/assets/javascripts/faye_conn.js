//= require faye
var faye;
function connect_to_faye(callback) {
  if (typeof faye == "undefined") {
    if ($.cookie("ajax-setting")) {
       connect_with_ajax(callback);
    } else {
       connect_with_ws(callback);
    }
  }
}

function connect_with_ws(callback) {
  faye = new Faye.Client("http://" + window.location.hostname + ":9292/faye");
  callback();
}

function connect_with_ajax(callback) {
  faye = new Faye.Client('http://' + window.location.hostname + '/faye');
  faye.disable('websocket');
  faye.disable('eventsource');
  callback();
}

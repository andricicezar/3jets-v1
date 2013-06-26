//= require faye

var faye = new Faye.Client("http://" + window.location.hostname + ":9292/faye");

function connect_to_faye(callback) {
  connect_with_ws(callback);
/*  $.ajax({
    url: "http://" + window.location.hostname + ":9292/fayes",
    type: "get",
    cache: true,
    dataType: "script",
    crossDomain: true,
    asynchronus: false,
    timeout: 500,
    complete: function(xhr, responseText, thrownError) {
      if (xhr.status != "204") {
        console.log("Working with WS");
        connect_with_ws(callback);
      } else {
        console.log("Working with Ajax");
        connect_with_ajax(callback);
      }
    }
  });*/
}

function connect_with_ws(callback) {
  //faye = new Faye.Client("http://" + window.location.hostname + ":9292/faye");
  callback();
}

function connect_with_ajax(callback) {
  faye = new Faye.Client('http://' + window.location.hostname + '/faye');
  faye.disable('websocket');
  faye.disable('eventsource');
  callback();
}

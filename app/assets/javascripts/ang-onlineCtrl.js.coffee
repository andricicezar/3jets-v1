@OnlineCtrl = ["$scope", "$timeout", ($scope, $timeout) ->
  $scope.friends = []
  $scope.games = []
  $scope.notifications = []
  $scope.currentGame = {}
  if ($scope.friends.length == 0)
      jQuery.get("/info", "json").done( (data) ->
        $scope.$apply ( ->
          $scope.friends = data[0]
          $scope.games = data[1]
          $scope.notifications = data[2]
        )
      )
  $scope.setCurrentGame = ->
    if ($("#main_grid1").length)
      aux = parseInt($("#main_grid1").attr("game"))
      angular.forEach $scope.games, (game) ->
        if (game.game_id == aux)
          $scope.currentGame = game


  $scope.keepTracking = ->
    s = "/channel/" + $("#users_panel").attr("channel")
    faye.subscribe(s, (data) ->
      value = $.parseJSON(data)
      if (value.type == 1)
        $scope.addFriend(value)
      else if (value.type == 2)
        $scope.addGame(value)
      else if (value.type == 3)
        $scope.addNotifications(value)
    )
  $scope.visit = (link) ->
    Turbolinks.visit(link)

  # NROW-uri

  $scope.addFriend = (value) ->
    ok = false
    angular.forEach $scope.friends, (friend) ->
      if (friend.id == value.id)
        $scope.$apply ( ->
          friend.time = 12
        )
        ok = true
        return
    if (!ok)
      $scope.$apply( ->
        $scope.friends.push(value)
      )

  $scope.addGame = (value) ->
    ok = false
    angular.forEach $scope.games, (game) ->
      if (game.game_id == value.game_id)
        $scope.$apply( ->
          if (value.turn == 3)
            game.turn = 0
            game.num_players = 0
            game.time = -2
          else
            game.turn = value.turn
            game.num_players = value.num_players
            game.enemy_pic = value.enemy_pic
            game.enemy_name = value.enemy_name
            game.time = value.time
          game.timestamp = Date.now()
        )
        ok = true
        return
    if (!ok)
      $scope.$apply( ->
        $scope.games.push(value)
      )
  $scope.$watch('notifications.length', ->
    $("#no-notifications").html($scope.notifications.length)
    $("#no-notifications").css("display", if $scope.notifications.length > 0 then "block" else "none")
  )

  $scope.addNotifications = (value) ->
    ok = false
    angular.forEach $scope.notifications, (notif, index) ->
      if (notif.notf_id == value.notf_id) 
        $scope.notifications.splice(index, 1)
        return
    if (!ok)
      $scope.$apply( ->
        $scope.notifications.push(value)
      )


  # NOTIFICATIONS

  $scope.acceptNotif = (ev) ->
    $.get(ev.accept_url)
    angular.forEach $scope.notifications, (notif, index) ->
      if notif == ev
        $scope.notifications.splice(index, 1)
        return

  $scope.declineNotif = (ev) ->
    $.get(ev.decline_url)
    angular.forEach $scope.notifications, (notif, index) ->
      if notif == ev
        $scope.notifications.splice(index, 1)
        return


  # INITIALIZE

  if (typeof faye != "undefined")
    $scope.keepTracking()
  else
    connect_to_faye($scope.keepTracking)


  # Timers
  $scope.timer = ->
    angular.forEach $scope.friends, (friend) ->
      $scope.$apply ( ->
        --friend.time if friend.time
      )
    $timeout($scope.timer, 5000)
  $timeout($scope.timer, 5000)

  $scope.gameTimer = ->
    angular.forEach $scope.games, (game) ->
      if (typeof game.timestamp == "undefined")
        game.timestamp = Date.now()
      if game.time > 0
        now = Date.now()
        game.time -= Math.floor((now - game.timestamp)/1000)
        game.timestamp = now
      if game.time == 0 || game.time == -1
       $.get(game.game_ur + "/check")
    $scope.setCurrentGame()
    if ($scope.currentGame)
      if ($scope.currentGame.time > 0)
        $("#timer").css({
          "width": (100*($scope.currentGame.time-2)/60)+"%",
          "left": (50-(100*($scope.currentGame.time-2)/60)/2) + "%"
        })
      if ($scope.currentGame.time < 12 && $scope.currentGame.turn == 1)
        $(".game-users p").css("display", "block")
      else
        $(".game-users p").css("display", "none")
    $timeout($scope.gameTimer, 1000)
  $timeout($scope.gameTimer, 1000)

  $scope.verify = (item) ->
    return true if typeof item.time == "string"
    item.time > 0
]

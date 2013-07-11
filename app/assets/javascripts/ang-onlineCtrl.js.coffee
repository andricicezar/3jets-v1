@OnlineCtrl = ["$scope", "$timeout", ($scope, $timeout) ->
  $scope.friends = []
  $scope.games = []
  $scope.notifications = []
  if ($scope.friends.length == 0)
      jQuery.get("/info", "json").done( (data) ->
        $scope.$apply ( ->
          $scope.friends = data[0]
          $scope.games = data[1]
          $scope.notifications = data[2]
        )
      )

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
          if (game.num_players == 1) 
            game.num_players++
            game.enemy_pic = value.enemy_pic
            game.enemy_name = value.enemy_name
          if (value.turn == 3)
            game.num_players = 0
          game.turn = value.turn
          game.time = value.time
          game.timestamp = Date.now()
        )
        ok = true
        return
    if (!ok)
      $scope.$apply( ->
        $scope.games.push(value)
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


  if (typeof faye != "undefined")
    $scope.keepTracking()
  else
    connect_to_faye($scope.keepTracking)

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
        game.time -= Math.floor((game.timestamp - now)/1000)
        game.timestamp = now
      if game.time == 0 || game.time == -1
       $.get(game.game_ur + "/check")
    $timeout($scope.gameTimer, 1000)
  $timeout($scope.gameTimer, 1000)

  $scope.verify = (item) ->
    return true if typeof item.time == "string"
    item.time > 0
]

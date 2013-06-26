@OnlineCtrl = ["$scope", "$timeout", ($scope, $timeout) ->
  $scope.friends = []
  $scope.games = []
  $scope.notifications = []
  if ($scope.friends.length == 0)
      jQuery.get("/friends", "json").done( (data) ->
        $scope.$apply ( ->
          $scope.friends = data
        )
      )
  if ($scope.games.length == 0)
    jQuery.get("/games", "json").done( (data) ->
      $scope.$apply ( ->
        $scope.games = data
      )
    )
  if ($scope.notifications.length == 0)
    jQuery.get("/notifications", "json").done( (data) ->
      $scope.$apply ( ->
        $scope.notifications = data
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
        $scope.$apply( ->
          $scope.notifications.push(value)
        )
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
      $scope.friends.shift(value)

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
        )
        ok = true
        return
    if (!ok)
      location.reload()
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
      --friend.time if friend.time
    $timeout($scope.timer, 5000)
  $timeout($scope.timer, 5000)

  $scope.verify = (item) ->
    item.time > 0
]

class HomeController
  constructor: ($scope, $http, Budget) ->
    $scope.budget_data = Budget.data

lex_app.controller 'HomeController', HomeController

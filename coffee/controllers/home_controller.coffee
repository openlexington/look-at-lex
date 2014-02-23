class HomeController
  constructor: (@$scope, $http, Budget) ->
    $scope.budget_data = Budget.data
    $scope.page_info =
      num_pages: 1
      page: 1
      per_page: 20
    $scope.$watch 'budget_data.length', ->
      return unless $scope.budget_data.length > 0
      $scope.page_info.num_pages = Math.ceil($scope.budget_data.length /
                                             $scope.page_info.per_page)

    $scope.page = @on_page_change

  on_page_change: (new_page) =>
    @$scope.page_info.page = new_page

lex_app.controller 'HomeController', HomeController

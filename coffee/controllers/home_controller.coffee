class HomeController
  constructor: (@$scope, $http, Budget) ->
    $scope.budget_data = Budget.data
    $scope.page_info =
      num_pages: 1
      page: 1
      per_page: 15
      window_size: 10
      windows: []
    $scope.$watch 'budget_data.length', =>
      return unless $scope.budget_data.length > 0
      $scope.table_data = (row for row in $scope.budget_data when row.fund)
      $scope.page_info.num_pages = Math.ceil($scope.table_data.length /
                                             $scope.page_info.per_page)
      @set_page_windows()

    $scope.page = @on_page_change

  set_page_windows: ->
    page_window = []
    for i in [0...@$scope.page_info.window_size]
      page_window.push i
    @$scope.page_info.windows.push page_window
    if @$scope.page_info.num_pages > @$scope.page_info.window_size
      page_window = []
      start_window = @$scope.page_info.num_pages -
                     @$scope.page_info.window_size
      for i in [start_window...@$scope.page_info.num_pages]
        page_window.push i
      @$scope.page_info.windows.push page_window

  on_page_change: (new_page) =>
    @$scope.page_info.page = new_page

lex_app.controller 'HomeController', HomeController

class HomeController
  constructor: (@$scope, @$location, $routeParams, $http, Budget) ->
    $scope.budget_data = Budget.data
    $scope.page_info =
      num_pages: 1
      page: parseInt($routeParams.page || 1, 10)
      per_page: 15
      window_size: 10
      windows: []
    @on_page_change(1) if $scope.page_info.page < 1
    $scope.$watch 'budget_data.length', =>
      return unless $scope.budget_data.length > 0
      $scope.table_data = (row for row in $scope.budget_data when row.fund)
      $scope.page_info.num_pages = Math.ceil($scope.table_data.length /
                                             $scope.page_info.per_page)
      if $scope.page_info.page > $scope.page_info.num_pages
        @on_page_change($scope.page_info.num_pages)
      @set_page_windows()
    $scope.show_all_pages = @show_all_pages
    $scope.page = @on_page_change

  set_page_windows: ->
    page_window = []
    window_limit = Math.min(@$scope.page_info.window_size,
                            @$scope.page_info.num_pages)
    for i in [0...window_limit]
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
    @$location.path "/page/#{new_page}"

  show_all_pages: =>
    @$scope.page_info.windows.length = 0
    page_window = []
    for i in [0...@$scope.page_info.num_pages]
      page_window.push i
    @$scope.page_info.windows.push page_window

lex_app.controller 'HomeController', HomeController

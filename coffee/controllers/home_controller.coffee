class HomeController
  constructor: (@$scope, @$location, $routeParams, $http, Budget) ->
    $scope.filters =
      fund_name: $routeParams.fund_name
    $scope.page_info = Budget.page_info
    $scope.page_info.page = parseInt($routeParams.page || 1, 10)
    @on_page_change(1) if $scope.page_info.page < 1
    $scope.loading =
      budget_data: true
    $scope.budget_data = Budget.data
    Budget.filter_data($scope.filters)
    $scope.table_data = Budget.table_data
    $scope.funds = []
    $scope.$watch 'budget_data.length', =>
      return unless $scope.budget_data.length > 0
      $scope.loading.budget_data = false
      @initialize_filters()
      Budget.filter_data($scope.filters)
      @change_page_if_necessary()
      Budget.set_page_windows()
    $scope.$watch 'table_data.length', =>
      return unless $scope.table_data.length > 0
      @change_page_if_necessary()
      Budget.set_page_windows()
    $scope.$watch 'filters.fund_name', =>
      return unless $scope.table_data.length > 0
      new_page = Math.min($scope.page_info.page, $scope.page_info.num_pages)
      @on_page_change(new_page)
    $scope.show_all_pages = @show_all_pages
    $scope.page = @on_page_change

  initialize_filters: ->
    for row in @$scope.budget_data when @$scope.funds.indexOf(row.fund_name) == -1
      @$scope.funds.push row.fund_name
    @$scope.funds.sort()

  change_page_if_necessary: ->
    if @$scope.page_info.page > @$scope.page_info.num_pages
      @on_page_change(@$scope.page_info.num_pages)

  on_page_change: (new_page) =>
    if fund_name=@$scope.filters.fund_name
      @$location.path "/page/#{new_page}/fund/#{fund_name}"
    else
      @$location.path "/page/#{new_page}"

  show_all_pages: =>
    @$scope.page_info.windows.length = 0
    page_window = []
    for i in [0...@$scope.page_info.num_pages]
      page_window.push i
    @$scope.page_info.windows.push page_window

lex_app.controller 'HomeController', HomeController

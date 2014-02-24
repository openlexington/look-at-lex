class HomeController
  constructor: (@$scope, @$location, $routeParams, $http, Budget) ->
    fund = $routeParams.fund
    dept_id = $routeParams.dept_id
    $scope.filters =
      fund: if fund then parseInt(fund, 10) else undefined
      dept_id: if dept_id then parseInt(dept_id, 10) else undefined
    $scope.page_info = Budget.page_info
    $scope.page_info.page = parseInt($routeParams.page || 1, 10)
    @on_page_change(1) if $scope.page_info.page < 1
    $scope.loading =
      budget_data: true
    $scope.budget_data = Budget.data
    Budget.filter_data($scope.filters)
    $scope.table_data = Budget.table_data
    $scope.funds = [{name: '', value: undefined}]
    $scope.divisions = []
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
    $scope.$watchCollection '[filters.fund, filters.dept_id]', =>
      return unless $scope.table_data.length > 0
      new_page = Math.min($scope.page_info.page, $scope.page_info.num_pages)
      @on_page_change(new_page)
    $scope.show_all_pages = @show_all_pages
    $scope.page = @on_page_change

  initialize_filters: ->
    name_sorter = (a, b) ->
      return -1 if a.name < b.name
      return 1 if a.name > b.name
      0
    funds = []
    dept_ids = []
    fund = @$scope.filters.fund
    for row in @$scope.budget_data
      if row.fund && funds.indexOf(row.fund) == -1
        @$scope.funds.push {name: row.fund_name, value: row.fund}
        funds.push row.fund
      if row.dept_id && dept_ids.indexOf(row.dept_id) == -1 && (!fund || row.fund == fund)
        @$scope.divisions.push {name: row.division_name, value: row.dept_id}
        dept_ids.push row.dept_id
    @$scope.funds.sort name_sorter
    @$scope.divisions.sort name_sorter

  change_page_if_necessary: ->
    if @$scope.page_info.page > @$scope.page_info.num_pages
      @on_page_change(@$scope.page_info.num_pages)

  on_page_change: (new_page) =>
    fund = @$scope.filters.fund
    dept_id = @$scope.filters.dept_id
    if fund
      if dept_id
        @$location.path "/page/#{new_page}/fund/#{fund}/division/#{dept_id}"
      else
        @$location.path "/page/#{new_page}/fund/#{fund}"
    else if dept_id
      @$location.path "/page/#{new_page}/division/#{dept_id}"
    else
      @$location.path "/page/#{new_page}"

  show_all_pages: =>
    @$scope.page_info.windows.length = 0
    page_window = []
    for i in [0...@$scope.page_info.num_pages]
      page_window.push i
    @$scope.page_info.windows.push page_window

lex_app.controller 'HomeController', HomeController

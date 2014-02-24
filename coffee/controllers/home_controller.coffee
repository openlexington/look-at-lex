class HomeController
  constructor: (@$scope, @$location, $routeParams, $http, Budget) ->
    fund = $routeParams.fund
    dept_id = $routeParams.dept_id
    dept_id2 = $routeParams.dept_id2
    $scope.filters =
      fund: if fund then parseInt(fund, 10) else undefined
      dept_id: if dept_id then parseInt(dept_id, 10) else undefined
      dept_id2: if dept_id2 then parseInt(dept_id2, 10) else undefined
    console.log $scope.filters
    $scope.page_info = Budget.page_info
    $scope.page_info.page = parseInt($routeParams.page || 1, 10)
    @on_page_change(1) if $scope.page_info.page < 1
    $scope.loading =
      budget_data: true
    $scope.budget_data = Budget.data
    Budget.filter_data($scope.filters)
    $scope.table_data = Budget.table_data
    $scope.funds = [{name: '', value: undefined}]
    $scope.divisions = [{name: '', value: undefined}]
    $scope.programs = [{name: '', value: undefined}]
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
    $scope.$watchCollection '[filters.fund, filters.dept_id, filters.dept_id2]', =>
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
    dept_id2s = []
    fund = @$scope.filters.fund
    dept_id = @$scope.filters.dept_id
    for row in @$scope.budget_data
      if row.fund && funds.indexOf(row.fund) == -1
        @$scope.funds.push {name: row.fund_name, value: row.fund}
        funds.push row.fund
      if row.dept_id && dept_ids.indexOf(row.dept_id) == -1 && (!fund || row.fund == fund)
        @$scope.divisions.push {name: row.division_name, value: row.dept_id}
        dept_ids.push row.dept_id
      if row.dept_id2 && dept_id2s.indexOf(row.dept_id2) == -1 && (!fund || row.fund == fund) && (!dept_id || row.dept_id == dept_id)
        @$scope.programs.push {name: row.program_name, value: row.dept_id2}
        dept_id2s.push row.dept_id2
    @$scope.funds.sort name_sorter
    @$scope.divisions.sort name_sorter
    @$scope.programs.sort name_sorter

  change_page_if_necessary: ->
    if @$scope.page_info.page > @$scope.page_info.num_pages
      @on_page_change(@$scope.page_info.num_pages)

  on_page_change: (new_page) =>
    fund = @$scope.filters.fund
    dept_id = @$scope.filters.dept_id
    dept_id2 = @$scope.filters.dept_id2
    if fund
      if dept_id
        if dept_id2
          @$location.path "/page/#{new_page}/fund/#{fund}/division/#{dept_id}" +
                          "/program/#{dept_id2}"
        else
          @$location.path "/page/#{new_page}/fund/#{fund}/division/#{dept_id}"
      else
        if dept_id2
          @$location.path "/page/#{new_page}/fund/#{fund}/program/#{dept_id2}"
        else
          @$location.path "/page/#{new_page}/fund/#{fund}"
    else if dept_id
      if dept_id2
        @$location.path "/page/#{new_page}/division/#{dept_id}/program/" +
                        "#{dept_id2}"
      else
        @$location.path "/page/#{new_page}/division/#{dept_id}"
    else if dept_id2
      @$location.path "/page/#{new_page}/program/#{dept_id2}"
    else
      @$location.path "/page/#{new_page}"

  show_all_pages: =>
    @$scope.page_info.windows.length = 0
    page_window = []
    for i in [0...@$scope.page_info.num_pages]
      page_window.push i
    @$scope.page_info.windows.push page_window

lex_app.controller 'HomeController', HomeController

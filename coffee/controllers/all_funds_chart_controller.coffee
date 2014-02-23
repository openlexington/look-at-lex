class AllFundsChartController
  constructor: (@$scope, @Budget) ->
    $scope.loading =
      all_funds_chart: true
    $scope.$watch 'budget_data.length', =>
      return unless $scope.budget_data.length > 0
      @on_budget_loaded $scope.budget_data

  on_budget_loaded: (budget_data) ->
    grouped_data = @Budget.group_data(budget_data, 'fund_name',
                                      'fy_2014_adopted')
    color = d3.scale.category20()
    chart = new PieChart('#all-funds-pie', color, 'fy_2014_adopted')
    chart.create_root grouped_data
    chart.create_pie_slices (value) -> numeral(value).format "$ 0,0[.]00"
    chart.label_pie_slices (value) -> numeral(value).format "($ 0.0 a)"
    chart.add_legend 'fund_name'
    @$scope.loading.all_funds_chart = false

lex_app.controller 'AllFundsChartController', AllFundsChartController

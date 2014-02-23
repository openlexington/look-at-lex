class GeneralServicesChartController
  constructor: (@$scope, @Budget) ->
    $scope.loading =
      general_services_chart: true
    $scope.$watch 'budget_data.length', =>
      return unless $scope.budget_data.length > 0
      @on_budget_loaded $scope.budget_data

  on_budget_loaded: (budget_data) ->
    gen_serv_data = @Budget.extract_fund_data(1101, budget_data)
    grouped_data = @Budget.group_data(gen_serv_data, 'division_name',
                                      'fy_2014_adopted')
    color = d3.scale.category20()
    chart = new PieChart('#general-services-pie', color, 'fy_2014_adopted')
    chart.create_root grouped_data
    chart.create_pie_slices (value) -> numeral(value).format "$ 0,0[.]00"
    chart.label_pie_slices (value) -> numeral(value).format "($ 0.0 a)"
    chart.add_legend 'division_name'
    @$scope.loading.general_services_chart = false

lex_app.controller 'GeneralServicesChartController',
                   GeneralServicesChartController

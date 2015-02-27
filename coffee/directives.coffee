lex_app.directive 'allfundschart', (Budget) ->
  restrict: 'E'
  replace: true
  transclude: true
  scope:
    {}
  template: '<div id="all-funds-pie" class="chart-wrapper"></div>'
  link: (scope, element, attrs) ->
    scope.$watch '$parent.table_data.length', ->
      return unless scope.$parent.table_data && scope.$parent.table_data.length > 0
      grouped_data = Budget.group_data(scope.$parent.table_data, 'fund_name',
                                       'fy_2014_adopted')
      color = d3.scale.category20()
      chart = new PieChart(element[0], color, 'fy_2014_adopted')
      chart.create_root grouped_data
      chart.create_pie_slices (value) -> numeral(value).format "$ 0,0[.]00"
      chart.label_pie_slices (value) -> numeral(value).format "($ 0.0 a)"
      chart.add_legend 'fund_name'

lex_app.directive 'generalserviceschart', (Budget) ->
  restrict: 'E'
  replace: true
  transclude: true
  scope:
    {}
  template: '<div id="general-services-pie" class="chart-wrapper"></div>'
  link: (scope, element, attrs) ->
    scope.$watch '$parent.table_data.length', ->
      return unless scope.$parent.table_data && scope.$parent.table_data.length > 0
      gen_serv_data = Budget.extract_fund_data(1101, scope.$parent.table_data)
      grouped_data = Budget.group_data(gen_serv_data, 'division_name',
                                       'fy_2014_adopted')
      color = d3.scale.category20()
      chart = new PieChart(element[0], color, 'fy_2014_adopted')
      chart.create_root grouped_data
      chart.create_pie_slices (value) -> numeral(value).format "$ 0,0[.]00"
      chart.label_pie_slices (value) -> numeral(value).format "($ 0.0 a)"
      chart.add_legend 'division_name'

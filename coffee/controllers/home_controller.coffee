class HomeController
  constructor: ($scope, $http) ->
    $http.get('/2014-lexington-ky-budget.json').success (data) =>
      @setup_all_funds_chart data
      @setup_general_services_chart data

  group_data: (data, key, value_property) ->
    grouped_data = []
    get_group = (key_value) ->
      for obj in grouped_data
        return obj if obj[key] is key_value
      undefined
    for obj in data
      group = get_group(obj[key])
      new_group = false
      if typeof (group) is "undefined"
        group = {}
        group[key] = obj[key]
        group[value_property] = 0
        new_group = true
      value = obj[value_property]
      if typeof (value) isnt 'undefined' and value isnt ''
        float_value = parseFloat(value.replace(/,/, ''))
        # Parentheses in value, don't include
        if value.indexOf('(') < 0 or value.indexOf(')') < 0
          group[value_property] += float_value
      grouped_data.push(group) if new_group

    value_sorter = (a, b) ->
      a_value = a[value_property]
      b_value = b[value_property]
      return -1 if a_value > b_value
      return 1 if a_value < b_value
      0

    grouped_data.sort value_sorter
    max_slices = 5
    if grouped_data.length < max_slices
      end_slice = grouped_data.length
    else
      end_slice = max_slices
    main_groups = grouped_data.slice(0, end_slice)
    other_groups = grouped_data.slice(end_slice, grouped_data.length)
    other_group = {}
    other_group[key] = 'Other'
    other_group[value_property] = 0
    for grp in other_groups
      other_group[value_property] += grp[value_property]
    groups_with_other = main_groups.concat(other_group)
    groups_with_other.sort value_sorter
    groups_with_other

  extract_fund_data: (fund, data) ->
    fund_data = []
    for datum in data when datum.fund is fund
      fund_data.push(datum)
    fund_data

  setup_all_funds_chart: (all_data) ->
    all_funds_data = @group_data(all_data, 'fund_name', 'fy_2014_adopted')
    color = d3.scale.category20()
    chart = new PieChart('#all-funds-pie', color, 'fy_2014_adopted')
    chart.create_root all_funds_data
    chart.create_pie_slices (value) -> numeral(value).format "$ 0,0[.]00"
    chart.label_pie_slices (value) -> numeral(value).format "($ 0.0 a)"
    chart.add_legend 'fund_name'

  setup_general_services_chart: (all_data) ->
    general_services_data = @group_data(@extract_fund_data(1101, all_data),
                                        'division_name', 'fy_2014_adopted')
    color = d3.scale.category20()
    chart = new PieChart('#general-services-pie', color, 'fy_2014_adopted')
    chart.create_root general_services_data
    chart.create_pie_slices (value) -> numeral(value).format "$ 0,0[.]00"
    chart.label_pie_slices (value) -> numeral(value).format "($ 0.0 a)"
    chart.add_legend 'division_name'

lex_app.controller 'HomeController', HomeController

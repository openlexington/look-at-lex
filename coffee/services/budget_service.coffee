lex_app.factory 'Budget', ($http) ->
  class BudgetService
    constructor: ->
      @data = []
      $http.get('/2014-lexington-ky-budget.json').success (response) =>
        for datum in response
          @data.push datum

    group_data: (raw_data, key, value_property) ->
      grouped_data = []
      get_group = (key_value) ->
        for obj in grouped_data
          return obj if obj[key] is key_value
        undefined
      for obj in raw_data
        group = get_group(obj[key])
        new_group = false
        if typeof (group) is "undefined"
          group = {}
          group[key] = obj[key]
          group[value_property] = 0
          new_group = true
        value = obj[value_property]
        if obj.fund
          group[value_property] += value
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

  new BudgetService()

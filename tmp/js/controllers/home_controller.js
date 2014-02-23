lex_app.controller('HomeController', function($scope, $http) {
  var extract_fund_data, group_data, setup_all_funds_chart, setup_general_services_chart;
  group_data = function(data, key, value_property) {
    var end_slice, float_value, get_group, group, grouped_data, groups_with_other, grp, main_groups, max_slices, new_group, obj, other_group, other_groups, value, value_sorter, _i, _j, _len, _len1;
    grouped_data = [];
    get_group = function(key_value) {
      var obj, _i, _len;
      for (_i = 0, _len = grouped_data.length; _i < _len; _i++) {
        obj = grouped_data[_i];
        if (obj[key] === key_value) {
          return obj;
        }
      }
      return void 0;
    };
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      obj = data[_i];
      group = get_group(obj[key]);
      new_group = false;
      if (typeof group === "undefined") {
        group = {};
        group[key] = obj[key];
        group[value_property] = 0;
        new_group = true;
      }
      value = obj[value_property];
      if (typeof value !== 'undefined' && value !== '') {
        float_value = parseFloat(value.replace(/,/, ''));
        if (value.indexOf('(') < 0 || value.indexOf(')') < 0) {
          group[value_property] += float_value;
        }
      }
      if (new_group) {
        grouped_data.push(group);
      }
    }
    value_sorter = function(a, b) {
      var a_value, b_value;
      a_value = a[value_property];
      b_value = b[value_property];
      if (a_value > b_value) {
        return -1;
      }
      if (a_value < b_value) {
        return 1;
      }
      return 0;
    };
    grouped_data.sort(value_sorter);
    max_slices = 5;
    if (grouped_data.length < max_slices) {
      end_slice = grouped_data.length;
    } else {
      end_slice = max_slices;
    }
    main_groups = grouped_data.slice(0, end_slice);
    other_groups = grouped_data.slice(end_slice, grouped_data.length);
    other_group = {};
    other_group[key] = 'Other';
    other_group[value_property] = 0;
    for (_j = 0, _len1 = other_groups.length; _j < _len1; _j++) {
      grp = other_groups[_j];
      other_group[value_property] += grp[value_property];
    }
    groups_with_other = main_groups.concat(other_group);
    groups_with_other.sort(value_sorter);
    return groups_with_other;
  };
  extract_fund_data = function(fund, data) {
    var datum, fund_data, _i, _len;
    fund_data = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      datum = data[_i];
      if (datum.fund === fund) {
        fund_data.push(datum);
      }
    }
    return fund_data;
  };
  setup_all_funds_chart = function(all_data) {
    var all_funds_data, chart, color;
    all_funds_data = group_data(all_data, 'fund_name', 'fy_2014_adopted');
    color = d3.scale.category20();
    chart = new PieChart('#all-funds-pie', color, 'fy_2014_adopted');
    chart.create_root(all_funds_data);
    chart.create_pie_slices(function(value) {
      return numeral(value).format("$ 0,0[.]00");
    });
    chart.label_pie_slices(function(value) {
      return numeral(value).format("($ 0.0 a)");
    });
    return chart.add_legend('fund_name');
  };
  setup_general_services_chart = function(all_data) {
    var chart, color, general_services_data;
    general_services_data = group_data(extract_fund_data(1101, all_data), 'division_name', 'fy_2014_adopted');
    color = d3.scale.category20();
    chart = new PieChart('#general-services-pie', color, 'fy_2014_adopted');
    chart.create_root(general_services_data);
    chart.create_pie_slices(function(value) {
      return numeral(value).format("$ 0,0[.]00");
    });
    chart.label_pie_slices(function(value) {
      return numeral(value).format("($ 0.0 a)");
    });
    return chart.add_legend('division_name');
  };
  return $scope.init = function() {
    return $http.get('/2014-lexington-ky-budget.json').success(function(data) {
      setup_all_funds_chart(data);
      return setup_general_services_chart(data);
    });
  };
});

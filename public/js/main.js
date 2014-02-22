function setup_chart(data) {
  var width = 800;
  var height = 600;
  var radius = 300;
  var color = d3.scale.category20c();
  var vis = d3.select('#pie-chart').append('svg:svg').data([data]).
               attr('width', width).attr('height', height).
               append('svg:g').
               attr('transform', 'translate(' + radius + ',' + radius + ')');
  var arc = d3.svg.arc().outerRadius(radius);
  var pie = d3.layout.pie().value(function (d) {
    return d.fy_2014_adopted;
  });
  var arcs = vis.selectAll('g.slice').data(pie).enter().
                 append('svg:g').attr('class', 'slice');
  arcs.append('svg:path').attr('fill', function (d, i) {
    return color(i);
  }).attr('d', arc);
  arcs.append('svg:text').attr('transform', function (d) {
    d.innerRadius = 0;
    d.outerRadius = radius;
    return 'translate(' + arc.centroid(d) + ')';
  }).attr('text-anchor', 'middle').text(function (d, i) {
    return data[i].fund_name;
  });
}

function group_data(data, key, value_property) {
  var grouped_data = [];
  var get_group = function (key_value) {
    for (var i=0; i<grouped_data.length; i++) {
      var obj = grouped_data[i];
      if (obj[key] === key_value) {
        return obj;
      }
    }
    return undefined;
  };
  for (var i=0; i<data.length; i++) {
    var obj = data[i];
    var group = get_group(obj[key]);
    var new_group = false;
    if (typeof(group) === 'undefined') {
      group = {};
      group[key] = obj[key];
      group[value_property] = 0;
      new_group = true;
    }
    var value = obj[value_property];
    if (typeof(value) !== 'undefined' && value != '') {
      var float_value = parseFloat(value.replace(/,/, ''));
      // Parentheses in value, don't include
      if (value.indexOf('(') < 0 || value.indexOf(')') < 0) {
        group[value_property] += float_value;
      }
    }
    if (new_group) {
      grouped_data.push(group);
    }
  }
  grouped_data.sort(function (a, b) {
    var a_value = a[value_property];
    var b_value = b[value_property];
    if (a_value > b_value) {
      return -1;
    }
    if (a_value < b_value) {
      return 1;
    }
    return 0;
  });
  console.log(grouped_data);
  var max_slices = 5;
  var end_slice = grouped_data.length < max_slices ? grouped_data.length
                                                   : max_slices;
  return grouped_data.slice(0, end_slice);
}

$(function() {
  var chart = $('#pie-chart');
  var json_url = '/2014-lexington-ky-budget.json';
  $.getJSON(json_url, function(response) {
    setup_chart(group_data(response, 'fund_name', 'fy_2014_adopted'));
  });
});

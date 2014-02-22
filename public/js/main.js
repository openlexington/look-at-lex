function setup_chart(data) {
  var width = 640;
  var height = 480;
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
  // console.log('before it exists:', get_group('General Services District'));
  // grouped_data.push({fund_name: 'General Services District', fy_2014_adopted: 15});
  // console.log('after it exists:', get_group('General Services District'));
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
      if (value.indexOf('(') < 0 || value.indexOf(')') < 0) {
        group[value_property] += float_value;
      }
    }
    if (new_group) {
      grouped_data.push(group);
    }
  }
  console.log(grouped_data);
  return grouped_data;
}

$(function() {
  var chart = $('#pie-chart');
  var json_url = '/2014-lexington-ky-budget.json';
  $.getJSON(json_url, function(response) {
    console.log('got the data');
    setup_chart(group_data(response, 'fund_name', 'fy_2014_adopted'));
  });
});

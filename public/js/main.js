// Thanks to http://plnkr.co/edit/3G0ALAVNACNhutOqDelk?p=preview
function is_point_in_arc(arc, pt, ptData, d3Arc) {
  // Center of the arc is assumed to be 0,0
  // (pt.x, pt.y) are assumed to be relative to the center
  var r1 = arc.innerRadius()(ptData),
      r2 = arc.outerRadius()(ptData),
      theta1 = arc.startAngle()(ptData),
      theta2 = arc.endAngle()(ptData);
  var dist = pt.x * pt.x + pt.y * pt.y,
      angle = Math.atan2(pt.x, -pt.y);
  angle = (angle < 0) ? (angle + Math.PI * 2) : angle;
  return (r1 * r1 <= dist) && (dist <= r2 * r2) &&
         (theta1 <= angle) && (angle <= theta2);
}

function format_dollars(dollars) {
  return numeral(dollars).format('($ 0.0 a)');
}

function format_long_dollars(dollars) {
  return numeral(dollars).format('$ 0,0[.]00');
}

function setup_chart(selector, color, data, label_key) {
  var chart_area = $(selector);
  var container_width = chart_area.parent().innerWidth();
  var legend_left_padding = 10;
  var width = Math.floor(container_width / 2.5) - legend_left_padding;
  var height = width;
  var line_height = 20;
  var legend_height = data.length * line_height;
  if (legend_height > height) {
    height = legend_height;
  }
  var radius = width / 2;
  var label_radius = radius + 30;
  var vis = d3.select(selector).append('svg:svg').
               attr('class', 'chart pie').data([data]).
               attr('width', width).attr('height', height).
               append('svg:g').
               attr('transform', 'translate(' + radius + ',' + radius + ')');
  var arc = d3.svg.arc().outerRadius(radius);
  var pie = d3.layout.pie().value(function (d) { return d.fy_2014_adopted; });
  var arcs = vis.selectAll('g.slice').data(pie).enter().
                 append('svg:g').attr('class', 'slice').
                 attr('title', function (d, i) {
                   return format_long_dollars(d.data.fy_2014_adopted);
                 });
  arcs.append('svg:path').attr('fill', function (d, i) { return color(i); }).
       attr('d', arc);

  $('g.slice').tooltip({
    container: 'body',
    placement: 'right'
  });

  // Labels inside pie slices
  arcs.append('svg:text').attr('class', 'pie-label').
       attr('transform', function (d) {
                           d.innerRadius = 0;
                           d.outerRadius = radius;
                           return 'translate(' + arc.centroid(d) + ')';
                         }).
       attr('dy', '.35em').
       style('text-anchor', 'middle').
       text(function (d) {
              return format_dollars(d.data.fy_2014_adopted);
            }).
       each(function (d) {
         var bb = this.getBBox();
         var center = arc.centroid(d);
         var topLeft = {x: center[0] + bb.x, y: center[1] + bb.y};
         var topRight = {x: topLeft.x + bb.width, y: topLeft.y};
         var bottomLeft = {x: topLeft.x, y: topLeft.y + bb.height};
         var bottomRight = {x: topLeft.x + bb.width, y: topLeft.y + bb.height};
         d.visible = is_point_in_arc(arc, topLeft, d, arc) &&
                     is_point_in_arc(arc, topRight, d, arc) &&
                     is_point_in_arc(arc, bottomLeft, d, arc) &&
                     is_point_in_arc(arc, bottomRight, d, arc);
       }).
       style('display', function (d) { return d.visible ? null : 'none'; });
  // Normal HTML title on hover
  // arcs.append('svg:title').
  //      text(function (d, i) {
  //        return format_long_dollars(d.data.fy_2014_adopted);
  //      });

  // Color boxes and legend text
  var legend_width = width * 1.2;
  legend_height += (height / 2.0) - (legend_height / 2.0);
  legend = d3.select(selector).append('svg').attr('class', 'legend').
     attr('width', legend_width).
     attr('height', legend_height).
     selectAll('g').data(color.domain().slice()).enter().
     append('g').
     attr('transform', function (d, i) {
       return 'translate(0,' + i * line_height + ')';
     });
  legend.append('rect').attr('width', 18).attr('height', 18).
     style('fill', color);
  legend.append('text').attr('class', 'legend-label').
         attr('x', 24).attr('y', 9).
         attr('dy', '.35em').
         text(function (i) {
           return data[i][label_key];
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
  var value_sorter = function(a, b) {
    var a_value = a[value_property];
    var b_value = b[value_property];
    if (a_value > b_value) {
      return -1;
    }
    if (a_value < b_value) {
      return 1;
    }
    return 0;
  }
  grouped_data.sort(value_sorter);
  var max_slices = 5;
  var end_slice = grouped_data.length < max_slices ? grouped_data.length
                                                   : max_slices;
  var main_groups = grouped_data.slice(0, end_slice);
  var other_groups = grouped_data.slice(end_slice, grouped_data.length);
  var other_group = {};
  other_group[key] = 'Other';
  other_group[value_property] = 0;
  for (var i=0; i<other_groups.length; i++) {
    other_group[value_property] += other_groups[i][value_property];
  }
  var groups_with_other = main_groups.concat(other_group);
  groups_with_other.sort(value_sorter);
  return groups_with_other;
}

function extract_fund_data(fund, data) {
  var fund_data = [];
  for (var i=0; i<data.length; i++) {
    var obj = data[i];
    if (obj.fund === fund) {
      fund_data.push(obj);
    }
  }
  return fund_data;
}

$(function() {
  $('[data-toggle="tooltip"]').tooltip();
  var json_url = '/2014-lexington-ky-budget.json';
  $.getJSON(json_url, function(response) {
    var all_data = response;

    var all_funds_data = group_data(all_data, 'fund_name', 'fy_2014_adopted');
    setup_chart('#all-funds-pie', d3.scale.category20(), all_funds_data, 'fund_name');

    var general_services_data = group_data(extract_fund_data(1101, all_data),
                                           'division_name', 'fy_2014_adopted');
    setup_chart('#general-services-pie', d3.scale.category20(),
                general_services_data, 'division_name');
  });
});

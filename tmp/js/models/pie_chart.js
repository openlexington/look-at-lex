var PieChart;

PieChart = (function() {
  function PieChart(selector, color, value_property) {
    this.selector = selector;
    this.color = color;
    this.value_property = value_property;
    this.legend_left_padding = 10;
    this.line_height = 20;
    this.container_width = $(this.selector).parent().innerWidth();
    this.width = Math.floor(this.container_width / 2.5) - this.legend_left_padding;
    this.height = this.width;
    this.radius = this.width / 2;
    this.label_radius = this.radius + 30;
    this.arc = d3.svg.arc().outerRadius(this.radius);
    this.pie = d3.layout.pie().value((function(_this) {
      return function(d) {
        return d[_this.value_property];
      };
    })(this));
  }

  PieChart.prototype.create_root = function(data) {
    this.data = data;
    this.legend_height = this.data.length * this.line_height;
    if (this.legend_height > this.height) {
      this.height = this.legend_height;
    }
    return this.vis = d3.select(this.selector).append('svg:svg').attr('class', 'chart pie').data([this.data]).attr('width', this.width).attr('height', this.height).append('svg:g').attr('transform', "translate(" + this.radius + "," + this.radius + ")");
  };

  PieChart.prototype.create_pie_slices = function(get_title) {
    this.arcs = this.vis.selectAll('g.slice').data(this.pie).enter().append('svg:g').attr('class', 'slice').attr('title', (function(_this) {
      return function(d, i) {
        return get_title(d.data[_this.value_property]);
      };
    })(this));
    this.arcs.append('svg:path').attr('fill', (function(_this) {
      return function(d, i) {
        return _this.color(i);
      };
    })(this)).attr('d', this.arc);
    return $('g.slice').tooltip({
      container: 'body',
      placement: 'right'
    });
  };

  PieChart.prototype.is_point_in_arc = function(pt, pt_data) {
    var angle, dist, r1, r2, theta1, theta2;
    r1 = this.arc.innerRadius()(pt_data);
    r2 = this.arc.outerRadius()(pt_data);
    theta1 = this.arc.startAngle()(pt_data);
    theta2 = this.arc.endAngle()(pt_data);
    dist = pt.x * pt.x + pt.y * pt.y;
    angle = Math.atan2(pt.x, -pt.y);
    angle = (angle < 0 ? angle + Math.PI * 2 : angle);
    return (r1 * r1 <= dist) && (dist <= r2 * r2) && (theta1 <= angle) && (angle <= theta2);
  };

  PieChart.prototype.label_pie_slices = function(get_label) {
    var any_hidden, hide_if_doesnt_fit, labeler, me, set_visible_property, transformer;
    transformer = (function(_this) {
      return function(d) {
        d.innerRadius = 0;
        d.outerRadius = _this.radius;
        return "translate(" + (_this.arc.centroid(d)) + ")";
      };
    })(this);
    labeler = (function(_this) {
      return function(d) {
        return get_label(d.data[_this.value_property]);
      };
    })(this);
    me = this;
    set_visible_property = function(d) {
      var bb, bottomLeft, bottomRight, center, topLeft, topRight;
      bb = this.getBBox();
      center = me.arc.centroid(d);
      topLeft = {
        x: center[0] + bb.x,
        y: center[1] + bb.y
      };
      topRight = {
        x: topLeft.x + bb.width,
        y: topLeft.y
      };
      bottomLeft = {
        x: topLeft.x,
        y: topLeft.y + bb.height
      };
      bottomRight = {
        x: topLeft.x + bb.width,
        y: topLeft.y + bb.height
      };
      return d.visible = me.is_point_in_arc(topLeft, d) && me.is_point_in_arc(topRight, d) && me.is_point_in_arc(bottomLeft, d) && me.is_point_in_arc(bottomRight, d);
    };
    any_hidden = false;
    hide_if_doesnt_fit = function(d) {
      if (d.visible && !any_hidden) {
        return null;
      }
      any_hidden = true;
      return 'none';
    };
    return this.arcs.append('svg:text').attr('class', 'pie-label').attr('transform', transformer).attr('dy', '.35em').style('text-anchor', 'middle').text(labeler).each(set_visible_property).style('display', hide_if_doesnt_fit);
  };

  PieChart.prototype.add_legend = function(label_key) {
    this.label_key = label_key;
    this.legend_width = this.width * 1.2;
    this.legend_height += (this.height / 2.0) - (this.legend_height / 2.0);
    this.legend = d3.select(this.selector).append('svg').attr('class', 'legend').attr('width', this.legend_width).attr('height', this.legend_height).selectAll('g').data(this.color.domain().slice()).enter().append('g').attr('transform', (function(_this) {
      return function(d, i) {
        return "translate(0," + (i * _this.line_height) + ")";
      };
    })(this));
    this.legend.append('rect').attr('width', 18).attr('height', 18).style('fill', this.color);
    return this.legend.append('text').attr('class', 'legend-label').attr('x', 24).attr('y', 9).attr('dy', '.35em').text((function(_this) {
      return function(i) {
        return _this.data[i][_this.label_key];
      };
    })(this));
  };

  return PieChart;

})();

(typeof exports !== "undefined" && exports !== null ? exports : this).PieChart = PieChart;

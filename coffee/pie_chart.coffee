class PieChart
  constructor: (selector, color, value_property) ->
    @selector = selector
    @color = color
    @value_property = value_property
    @legend_left_padding = 10
    @line_height = 20
    @container_width = $(@selector).parent().innerWidth()
    @width = Math.floor(@container_width / 2.5) - @legend_left_padding
    @height = @width
    @radius = @width / 2
    @label_radius = @radius + 30
    @arc = d3.svg.arc().outerRadius(@radius)
    @pie = d3.layout.pie().value((d) => d[@value_property])

  create_root: (data) ->
    @data = data
    @legend_height = @data.length * @line_height
    @height = @legend_height if @legend_height > @height
    @vis = d3.select(@selector).append('svg:svg').attr('class', 'chart pie').
              data([@data]).attr('width', @width).attr('height', @height).
              append('svg:g').
              attr('transform', "translate(#{@radius},#{@radius})")

  create_pie_slices: (get_title) ->
    @arcs = @vis.selectAll('g.slice').data(@pie).enter().append('svg:g').
                 attr('class', 'slice').
                 attr('title', (d, i) => get_title(d.data[@value_property]))
    @arcs.append('svg:path').attr('fill', (d, i) => @color(i)).attr('d', @arc)
    $('g.slice').tooltip
      container: 'body'
      placement: 'right'

  # Thanks to http://plnkr.co/edit/3G0ALAVNACNhutOqDelk?p=preview
  is_point_in_arc: (pt, pt_data) ->
    # Center of the arc is assumed to be 0,0
    # (pt.x, pt.y) are assumed to be relative to the center
    r1 = @arc.innerRadius()(pt_data)
    r2 = @arc.outerRadius()(pt_data)
    theta1 = @arc.startAngle()(pt_data)
    theta2 = @arc.endAngle()(pt_data)
    dist = pt.x * pt.x + pt.y * pt.y
    angle = Math.atan2(pt.x, -pt.y)
    angle = (if (angle < 0) then (angle + Math.PI * 2) else angle)
    (r1 * r1 <= dist) and (dist <= r2 * r2) and (theta1 <= angle) and (angle <= theta2)

  label_pie_slices: (get_label) ->
    transformer = (d) =>
      d.innerRadius = 0
      d.outerRadius = @radius
      "translate(#{@arc.centroid(d)})"
    labeler = (d) => get_label(d.data[@value_property])
    me = this
    set_visible_property = (d) ->
      bb = this.getBBox()
      center = me.arc.centroid(d)
      topLeft =
        x: center[0] + bb.x
        y: center[1] + bb.y
      topRight =
        x: topLeft.x + bb.width
        y: topLeft.y
      bottomLeft =
        x: topLeft.x
        y: topLeft.y + bb.height
      bottomRight =
        x: topLeft.x + bb.width
        y: topLeft.y + bb.height
      d.visible = me.is_point_in_arc(topLeft, d) and me.is_point_in_arc(topRight, d) and me.is_point_in_arc(bottomLeft, d) and me.is_point_in_arc(bottomRight, d)
    hide_if_doesnt_fit = (d) -> (if d.visible then null else 'none')
    @arcs.append('svg:text').attr('class', 'pie-label').
          attr('transform', transformer).attr('dy', '.35em').
          style('text-anchor', 'middle').text(labeler).
          each(set_visible_property).
          style('display', hide_if_doesnt_fit)

  add_legend: (label_key) ->
    @label_key = label_key
    @legend_width = @width * 1.2
    @legend_height += (@height / 2.0) - (@legend_height / 2.0)
    @legend = d3.select(@selector).append('svg').attr('class', 'legend').
                 attr('width', @legend_width).attr('height', @legend_height).
                 selectAll('g').data(@color.domain().slice()).enter().
                 append('g').
                 attr('transform', (d, i) => "translate(0,#{i * @line_height})")
    @legend.append('rect').attr('width', 18).attr('height', 18).
            style('fill', @color)
    @legend.append('text').attr('class', 'legend-label').
            attr('x', 24).attr('y', 9).attr('dy', '.35em').
            text((i) => @data[i][@label_key])

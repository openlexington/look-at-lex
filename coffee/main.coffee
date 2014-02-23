# Thanks to http://plnkr.co/edit/3G0ALAVNACNhutOqDelk?p=preview
is_point_in_arc = (arc, pt, ptData, d3Arc) ->
  # Center of the arc is assumed to be 0,0
  # (pt.x, pt.y) are assumed to be relative to the center
  r1 = arc.innerRadius()(ptData)
  r2 = arc.outerRadius()(ptData)
  theta1 = arc.startAngle()(ptData)
  theta2 = arc.endAngle()(ptData)
  dist = pt.x * pt.x + pt.y * pt.y
  angle = Math.atan2(pt.x, -pt.y)
  angle = (if (angle < 0) then (angle + Math.PI * 2) else angle)
  (r1 * r1 <= dist) and (dist <= r2 * r2) and (theta1 <= angle) and (angle <= theta2)

format_dollars = (dollars) ->
  numeral(dollars).format "($ 0.0 a)"

format_long_dollars = (dollars) ->
  numeral(dollars).format "$ 0,0[.]00"

setup_chart = (selector, color, data, label_key) ->
  chart_area = $(selector)
  container_width = chart_area.parent().innerWidth()
  legend_left_padding = 10
  width = Math.floor(container_width / 2.5) - legend_left_padding
  height = width
  line_height = 20
  legend_height = data.length * line_height
  height = legend_height  if legend_height > height
  radius = width / 2
  label_radius = radius + 30
  vis = d3.select(selector).append("svg:svg").attr("class", "chart pie").data([data]).attr("width", width).attr("height", height).append("svg:g").attr("transform", "translate(" + radius + "," + radius + ")")
  arc = d3.svg.arc().outerRadius(radius)
  pie = d3.layout.pie().value((d) ->
    d.fy_2014_adopted
  )
  arcs = vis.selectAll("g.slice").data(pie).enter().append("svg:g").attr("class", "slice").attr("title", (d, i) ->
    format_long_dollars d.data.fy_2014_adopted
  )
  arcs.append("svg:path").attr("fill", (d, i) ->
    color i
  ).attr "d", arc
  $("g.slice").tooltip
    container: "body"
    placement: "right"

  # Labels inside pie slices
  arcs.append("svg:text").attr("class", "pie-label").attr("transform", (d) ->
    d.innerRadius = 0
    d.outerRadius = radius
    "translate(" + arc.centroid(d) + ")"
  ).attr("dy", ".35em").style("text-anchor", "middle").text((d) ->
    format_dollars d.data.fy_2014_adopted
  ).each((d) ->
    bb = @getBBox()
    center = arc.centroid(d)
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
    d.visible = is_point_in_arc(arc, topLeft, d, arc) and is_point_in_arc(arc, topRight, d, arc) and is_point_in_arc(arc, bottomLeft, d, arc) and is_point_in_arc(arc, bottomRight, d, arc)
  ).style "display", (d) ->
    (if d.visible then null else "none")

  # Normal HTML title on hover
  # arcs.append('svg:title').
  #      text(function (d, i) {
  #        return format_long_dollars(d.data.fy_2014_adopted);
  #      });

  # Color boxes and legend text
  legend_width = width * 1.2
  legend_height += (height / 2.0) - (legend_height / 2.0)
  legend = d3.select(selector).append("svg").attr("class", "legend").attr("width", legend_width).attr("height", legend_height).selectAll("g").data(color.domain().slice()).enter().append("g").attr("transform", (d, i) ->
    "translate(0," + i * line_height + ")"
  )
  legend.append("rect").attr("width", 18).attr("height", 18).style "fill", color
  legend.append("text").attr("class", "legend-label").attr("x", 24).attr("y", 9).attr("dy", ".35em").text (i) ->
    data[i][label_key]

group_data = (data, key, value_property) ->
  grouped_data = []
  get_group = (key_value) ->
    i = 0

    while i < grouped_data.length
      obj = grouped_data[i]
      return obj  if obj[key] is key_value
      i++
    `undefined`
  i = 0
  while i < data.length
    obj = data[i]
    group = get_group(obj[key])
    new_group = false
    if typeof (group) is "undefined"
      group = {}
      group[key] = obj[key]
      group[value_property] = 0
      new_group = true
    value = obj[value_property]
    if typeof (value) isnt "undefined" and value isnt ""
      float_value = parseFloat(value.replace(/,/, ""))

      # Parentheses in value, don't include
      group[value_property] += float_value  if value.indexOf("(") < 0 or value.indexOf(")") < 0
    grouped_data.push group  if new_group
    i++

  value_sorter = (a, b) ->
    a_value = a[value_property]
    b_value = b[value_property]
    return -1  if a_value > b_value
    return 1  if a_value < b_value
    0

  grouped_data.sort value_sorter
  max_slices = 5
  end_slice = (if grouped_data.length < max_slices then grouped_data.length else max_slices)
  main_groups = grouped_data.slice(0, end_slice)
  other_groups = grouped_data.slice(end_slice, grouped_data.length)
  other_group = {}
  other_group[key] = "Other"
  other_group[value_property] = 0
  i = 0
  while i < other_groups.length
    other_group[value_property] += other_groups[i][value_property]
    i++
  groups_with_other = main_groups.concat(other_group)
  groups_with_other.sort value_sorter
  groups_with_other

extract_fund_data = (fund, data) ->
  fund_data = []
  i = 0
  while i < data.length
    obj = data[i]
    fund_data.push obj  if obj.fund is fund
    i++
  fund_data

$ ->
  $("[data-toggle=\"tooltip\"]").tooltip()
  json_url = "/2014-lexington-ky-budget.json"
  $.getJSON json_url, (response) ->
    all_data = response
    all_funds_data = group_data(all_data, "fund_name", "fy_2014_adopted")
    setup_chart "#all-funds-pie", d3.scale.category20(), all_funds_data, "fund_name"
    general_services_data = group_data(extract_fund_data(1101, all_data), "division_name", "fy_2014_adopted")
    setup_chart "#general-services-pie", d3.scale.category20(), general_services_data, "division_name"

module StatsHelper

  def event_chart_tag(events, opt={})
    events = events.join(',') if events.is_a? Array
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(events: events)
    content_tag :div, "", opt
  end

  def chart_tag(opt={})
    opt[:data] ||= {}
    opt[:data][:graph] = admin_api_stats_path(chart_data(opt))
    content_tag :div, "", opt
  end

  def chart_data(opt={})
    data = nil
    if opt[:id].present?
      data = {opt[:id] => true}
    elsif opt[:event].present?
      data = {event: opt[:event]}
    end
    data
  end

  def graph_link_text(event)
    text = t("admin.stats.graph.#{event}")
    if text.to_s.match(/translation missing/)
      text = event
    end
    text
  end

end

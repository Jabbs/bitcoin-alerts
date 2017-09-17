module Charts

  def self.label_value_ary_to_pie_chart_data(label_value_ary)
    data = []
    # label_value_ary = [[label, value], [label, value], ...]
    label_value_ary.each_with_index do |label_value, index|
      item = {}
      item["label"]     = label_value[0]
      item["value"]     = label_value[1]
      item["color"]     = Charts.pie_chart_colors[index][0]
      item["highlight"] = Charts.pie_chart_colors[index][1]
      data << item
    end
    data
  end

  def self.pie_chart_colors
    # [[color, highlight], [color, highlight], ...]
    [["#F7464A", "#FF5A5E"], ["#46BFBD", "#5AD3D1"], ["#FDB45C", "#FFC870"], ["#949FB1", "#A8B3C5"], ["#4D5360", "#616774"], ["#f9a22e", "#f5bf47"]] * 16
  end

  def self.piedata_users_gender(users)
    ary = [] # [[label, value], [label, value], ...]

    if users.kind_of?(Array)
      male_count = users.select { |u| u.gender == "male" }.count
      female_count = users.select { |u| u.gender == "female" }.count
    else
      male_count = users.where(gender: "male").count
      female_count = users.where(gender: "female").count
    end
    total_count = male_count + female_count
    male_percent = ((male_count.to_f/total_count.to_f)*100).round(1)
    female_percent = ((female_count.to_f/total_count.to_f)*100).round(1)

    item = ["Male", male_percent]
    ary << item
    item = ["Female", female_percent]
    ary << item

    Charts.label_value_ary_to_pie_chart_data(ary)
  end

  def self.piedata_users_age(users)
    ary = [] # [[label, value], [label, value], ...]
    years = User.to_birth_years(users)
    year_today = Date.today.year
    years_13_24_count = years.select { |y| ((year_today - 24)..(year_today)).include?(y) }.count
    years_25_34_count = years.select { |y| ((year_today - 34)..(year_today - 25)).include?(y) }.count
    years_35_44_count = years.select { |y| ((year_today - 44)..(year_today - 35)).include?(y) }.count
    years_45_54_count = years.select { |y| ((year_today - 54)..(year_today - 45)).include?(y) }.count
    years_55_64_count = years.select { |y| ((year_today - 64)..(year_today - 55)).include?(y) }.count
    years_65_plus_count = years.select { |y| ((year_today - 150)..(year_today - 65)).include?(y) }.count
    total = years_13_24_count + years_25_34_count + years_35_44_count + years_45_54_count + years_55_64_count + years_65_plus_count

    item = ["13-24", (years_13_24_count.to_f/total.to_f*100).round(1)]
    ary << item
    item = ["25-34", (years_25_34_count.to_f/total.to_f*100).round(1)]
    ary << item
    item = ["35-44", (years_35_44_count.to_f/total.to_f*100).round(1)]
    ary << item
    item = ["45-54", (years_45_54_count.to_f/total.to_f*100).round(1)]
    ary << item
    item = ["55-64", (years_55_64_count.to_f/total.to_f*100).round(1)]
    ary << item
    item = ["65+", (years_65_plus_count.to_f/total.to_f*100).round(1)]
    ary << item

    Charts.label_value_ary_to_pie_chart_data(ary)
  end

  def self.piedata_users_zip(users)
    ary = [] # [[label, value], [label, value], ...]

    if users.kind_of?(Array)
      zips = users.map { |u| u.location.zip if u.location != "" }.select { |z| z.numeric? && z.size == 5 }
    else
      zips = users.includes(:location).where.not(:locations => {:zip => ""}).map { |p| p.location.zip }.select { |z| z.numeric? && z.size == 5 }
    end
    unique_zips = zips.uniq

    unique_zips.each do |zip|
      item = [(zips.count(zip).to_f/zips.count.to_f*100).round(1), zip]
      ary << item
    end

    # get <1% label and value
    one_percent_value = ary.select { |i| i[0] < 1 }.map { |i| i[0] }.sum.round(1)
    one_percent_label = ary.select { |i| i[0] < 1 }.map { |i| i[1] }.uniq.sort.to_sentence

    # flipped [value, label] to [label, value] after sort
    ary = ary.select { |i| !(i[0] < 1) }.sort.reverse.map { |i| [i[1], i[0]] }

    # add <1% label and value
    ary << [one_percent_label, one_percent_value]

    Charts.label_value_ary_to_pie_chart_data(ary)
  end

  def self.bardata_participation_monthly(object, month_count=6)
    month_labels = []
    likes_data = []
    comments_data = []
    month_count.times do |n|
      datetime = Time.now - n.month
      month_name = datetime.strftime("%B")
      month_labels << month_name
      likes_data << object.likes.where("likes.created_at > ?", datetime.beginning_of_month).where("likes.created_at < ?", datetime.end_of_month).count
      comments_data << object.comments.where("comments.created_at > ?", datetime.beginning_of_month).where("comments.created_at < ?", datetime.end_of_month).count
    end

    data = {}
    data["labels"] = month_labels.reverse
    datasets = []
    item = {}
    item["label"] = "Supports"
    item["fillColor"] = "rgba(220,220,220,0.5)"
    item["strokeColor"] = "rgba(220,220,220,0.8)"
    item["highlightFill:"] = "rgba(220,220,220,0.75)"
    item["highlightStroke:"] = "rgba(220,220,220,1)"
    item["data"] = likes_data.reverse
    datasets << item

    item = {}
    item["label"] = "Comments"
    item["fillColor"] = "rgba(151,187,205,0.5)"
    item["strokeColor"] = "rgba(151,187,205,0.8)"
    item["highlightFill"] = "rgba(151,187,205,0.75)"
    item["highlightStroke"] = "rgba(151,187,205,1)"
    item["data"] = comments_data.reverse
    datasets << item

    data["datasets"] = datasets
    data
  end

  def self.linedata_participation_monthly(object, month_count=6)
    month_labels = []
    likes_data = []
    comments_data = []
    month_count.times do |n|
      datetime = Time.now - n.month
      month_name = datetime.strftime("%B")
      month_labels << month_name
      likes_data << object.likes.where("likes.created_at > ?", datetime.beginning_of_month).where("likes.created_at < ?", datetime.end_of_month).count
      comments_data << object.comments.where("comments.created_at > ?", datetime.beginning_of_month).where("comments.created_at < ?", datetime.end_of_month).count
    end

    data = {}
    data["labels"] = month_labels.reverse
    datasets = []

    item = {}
    item["label"] = "Supporters"
    item["fillColor"] = "rgba(220,220,220,0.2)"
    item["strokeColor"] = "rgba(220,220,220,1)"
    item["pointColor"] = "rgba(220,220,220,1)"
    item["pointStrokeColor"] = "#fff"
    item["pointHighlightFill"] = "#fff"
    item["pointHighlightStroke"] = "rgba(220,220,220,1)"
    item["data"] = likes_data.reverse
    datasets << item

    item = {}
    item["label"] = "Comments"
    item["fillColor"] = "rgba(151,187,205,0.2)"
    item["strokeColor"] = "rgba(151,187,205,1)"
    item["pointColor"] = "rgba(151,187,205,1)"
    item["pointStrokeColor"] = "#fff"
    item["pointHighlightFill"] = "#fff"
    item["pointHighlightStroke"] = "rgba(151,187,205,1)"
    item["data"] = comments_data.reverse
    datasets << item

    data["datasets"] = datasets
    data
  end

end

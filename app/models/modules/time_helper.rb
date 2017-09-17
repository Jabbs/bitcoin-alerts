module TimeHelper
  def utc_datetime_convert_from_time_zone(year,month,day,hour,min,time_zone)
    datetime_str = year + "-" + month + "-" + day + " " + hour + ":" + min + ":00"
    new_datetime = datetime_str.in_time_zone(time_zone).utc.to_datetime
    new_datetime
  end
end

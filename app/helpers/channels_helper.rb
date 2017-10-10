module ChannelsHelper

  def frequency_text(channel)
    if channel.frequency_in_minutes % 60 == 0
      pluralize(channel.frequency_in_minutes/60, "hour")
    else
      pluralize(channel.frequency_in_minutes, "minute")
    end
  end

end

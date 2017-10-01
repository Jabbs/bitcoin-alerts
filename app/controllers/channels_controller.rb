class ChannelsController < ApplicationController

  def index
    @channels = Channel.all.shuffle.first(20)
  end
end

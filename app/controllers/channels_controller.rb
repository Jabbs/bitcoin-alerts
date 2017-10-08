class ChannelsController < ApplicationController

  def index
    @channels = Channel.all.shuffle.first(20)
  end

  def new
    @channel = Channel.new
    @channel.rules.build
  end

  def show_modal
    @channel = Channel.find_by_id(params[:channel_id])
  end

  private

  def channel_params
    params.require(:channel).permit(:name, :description, :currency_id, :source_name, :source_url, :frequency_in_minutes,
                    rules_attributes: [:id, :comparison_logic])
  end
end

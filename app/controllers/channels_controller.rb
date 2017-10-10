class ChannelsController < ApplicationController
  before_action :redirect_non_admin, only: [:new, :create]

  def index
    @channels = Channel.all.shuffle.first(20)
  end

  def new
    @channel = Channel.new
    @channel.rules.build
  end

  def create
    @channel = Channel.new(channel_params)
    if @channel.save
      redirect_to new_channel_path, notice: @channel.name + " has been created"
    else
      render 'new'
    end
  end

  def show_modal
    @channel = Channel.find_by_id(params[:channel_id])
  end

  private

  def channel_params
    params.require(:channel).permit(:name, :description, :currency_id, :source_name, :source_url, :frequency_in_minutes,
                    rules_attributes: [:id, :percent_increase, :percent_decrease, :ceiling, :floor, :operator,
                                       :comparison_logic, :lookback_minutes, :comparison_table, :comparison_table_column,
                                       :comparison_table_scope_method, :comparison_table_scope_value])
  end
end

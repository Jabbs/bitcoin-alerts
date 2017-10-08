class SubscriptionsController < ApplicationController
  def create
    @channel = Channel.find_by_id(params[:channel_id])
    current_user.subscriptions.create(channel_id: @channel.id, notification_type: "email")
  end

  def destroy
    @channel = Channel.find_by_id(params[:channel_id])
    current_user.subscriptions.find_by_channel_id(@channel.id).destroy
  end
end

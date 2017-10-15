class SubscriptionsController < ApplicationController
  def create
    @channel = Channel.find_by_id(params[:channel_id])
    current_user.subscriptions.create(channel_id: @channel.id, notification_type: "email")
  end

  def destroy
    @channel = Channel.find_by_id(params[:channel_id])
    current_user.subscriptions.find_by_channel_id(@channel.id).destroy
  end

  def unsubscribe
    if user = User.find_by_auth_token(params[:unsubscribe_id].to_s)
      user.update_attribute(:subscribed, false)
      redirect_to root_path, notice: "Your account has been successfully unsubscribed."
    else
      redirect_to root_path, alert: "There was an issue unsubscribing your email. Please message #{t('application.root.email')} for assistance."
    end
  end
end

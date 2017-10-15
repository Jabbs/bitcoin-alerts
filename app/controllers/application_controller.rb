class ApplicationController < ActionController::Base
  include SessionsHelper
  include ApplicationHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :ensure_domain

  def ensure_domain
    if Rails.env.production? && request.env['HTTP_HOST'] != I18n.t('application.root.domain')
      # HTTP 301 is a "permanent" redirect
      redirect_to "https://" + I18n.t('application.root.domain') + "#{request.path}", :status => 301
    end
  end

end

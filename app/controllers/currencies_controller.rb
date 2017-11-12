class CurrenciesController < ApplicationController
  def index
    currency_ids = Channel.where(active: true).pluck(:currency_id).uniq
    respond_to do |format|
      format.json { render json: Currency.where(id: currency_ids) }
    end
  end
end

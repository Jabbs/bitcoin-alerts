class RulesController < ApplicationController
  before_action :redirect_non_admin

  def edit
    @channel = Channel.find_by_id(params[:channel_id])
    @rule = Rule.find_by_id(params[:id])
  end

  def update
    @channel = Channel.find_by_id(params[:channel_id])
    @rule = Rule.find_by_id(params[:id])
    if @rule.update_attributes(rule_params)
      redirect_to edit_channel_rule_path(@channel, @rule), notice: "Rule has been updated."
    else
      redirect_to edit_channel_rule_path(@channel, @rule), alert: "There was an issue updating this rule."
    end
  end

  private

  def rule_params
    params.require(:rule).permit(:percent_increase, :percent_decrease, :ceiling, :floor, :operator,
                                 :comparison_logic, :lookback_minutes, :comparison_table, :comparison_table_column,
                                 :comparison_table_scope_method, :comparison_table_scope_value)
  end
end

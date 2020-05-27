require "touchpoints/engine"

module Touchpoints
  @@session_name = '_touchpoints'.freeze
  @@utm_params = %w(utm_source utm_medium utm_campaign utm_term utm_content utm_uid).freeze
  @@logging = false
  @@model = 'Touchpoint'.freeze
  @@model_id = :id
  @@model_foreign_id = :user_id
  @@current_user_method = :current_user
  @@capacity = 22

  def self.configure
    yield Touchpoints

    return unless @@logging

    Rails.logger.info "Touchpoint configuration: #{@@session_name}–#{@@utm_params}–#{@@logging}–"
  end

  def self.set(option, value)
    Touchpoints.class_variable_set '@@' << option.to_s, value
  end
end

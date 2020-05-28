require "touchpoints/engine"

module Touchpoints
  @@configuration = {
    session_name: '_touchpoints'.freeze,
    utm_params: %w(utm_source utm_medium utm_campaign utm_term utm_content utm_uid).freeze,
    logging: false,
    model: 'Touchpoint'.freeze,
    model_id: :id,
    model_foreign_id: :user_id,
    current_user_method: :current_user,
    capacity: 22,
  }

  def self.configure
    yield Touchpoints

    debug "Touchpoint configuration: #{@@configuration.inspect}"
  end

  def self.set(option, value)
    @@configuration[option] = value
  end

  def self.get(option)
    @@configuration[option]
  end

  def self.debug(message)
    return unless get(:logging)

    puts message
  end
end

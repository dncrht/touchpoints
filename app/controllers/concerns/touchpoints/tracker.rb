module Touchpoints
  module Tracker
    extend ActiveSupport::Concern

    included do
      before_action :_track_touchpoints
    end

    def _track_touchpoints
      return if request.domain == domain_from(request.referer.to_s)

      touchpoints = Array(session[@@session_name])
      touchpoints = keep_only_recent(touchpoints)
      touchpoints = add_if_different(touchpoints)

      info("Touchpoints: #{touchpoints.inspect}")

      session[@@session_name] = touchpoints
    end

    private

    def domain_from(string)
      uri = URI.parse string
      return unless uri.host

      uri.host.split('.').reverse[0..2].reverse.join('.')
    end

    def keep_only_recent(touchpoints)
      touchpoints.select { |touchpoint| touchpoint['touched_at'] > 60.days.ago }
    end

    def add_if_different(touchpoints)
      last_touchpoint = Hash(touchpoints.last)
      utm_params = params.permit(*@@utm_params).to_h

      new_touchpoint = { utm_params: utm_params, referer: request.referer, touched_at: Time.current }
      info("Touchpoint (new): #{new_touchpoint.inspect}")
      info("Touchpoint (last): #{last_touchpoint.inspect}")

      if new_touchpoint[:utm_params] != last_touchpoint[:utm_params] && new_touchpoint[:referer] != last_touchpoint[:referer]
        touchpoints << new_touchpoint
        info('Touchpoint added!')
      end

      touchpoints
    end

    def info(message)
      return unless @@logging

      Rails.logger.info message
    end
  end
end

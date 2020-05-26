module Touchpoints
  module Tracker
    extend ActiveSupport::Concern

    included do
      before_action :track_touchpoints
    end

    def track_touchpoints
      return if request.domain == domain_from(request.referer.to_s)

      touchpoints = Array(session[:touchpoints])
      touchpoints.select! { |touchpoint| touchpoint['touched_at'] > 60.days.ago }

      utm_params = params.permit('utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'utm_uid').to_h
      touchpoints << { utm_params: utm_params, referer: request.referer, touched_at: Time.current }

      session[:touchpoints] = touchpoints

      puts touchpoints.inspect
    end

    def domain_from(string)
      uri = URI.parse string
      return unless uri.host

      uri.host.split('.').reverse[0..2].reverse.join('.')
    end
  end
end

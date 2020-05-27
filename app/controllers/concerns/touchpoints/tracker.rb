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
      touchpoints = persist_if_logged_in(touchpoints)

      session[@@session_name] = touchpoints.last(@@capacity)
    end

    private

    def domain_from(string) # TODO: come up with a more resilient way of extracting the domain
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

      if different_touchpoints?(new_touchpoint, last_touchpoint)
        touchpoints << new_touchpoint
        info('Touchpoint added!')
      end

      info("Touchpoints: #{touchpoints.inspect}")

      touchpoints
    end

    def persist_if_logged_in(touchpoints)
      return touchpoints unless logged_in?

      last_touchpoint_persisted = @@model.constantize.where(@@model_foreign_id => user_id).last
      last_touchpoint_attributes = last_touchpoint_persisted ? last_touchpoint_persisted.attributes.slice(:utm_params, :referer) : {}
      touchpoints.each do |touchpoint|
        next if !different_touchpoints?(touchpoint, last_touchpoint_attributes)
        @@model.constantize.new(touchpoint).save
        last_touchpoint_persisted = nil
      end

      []
    end

    def logged_in?
      respond_to?(@@current_user_method) && send(@@current_user_method).present?
    end

    def user_id
      send(@@current_user_method).send(@@model_foreign_id)
    end

    def different_touchpoints?(a, b)
      a[:utm_params] != b[:utm_params] && a[:referer] != b[:referer]
    end

    def info(message)
      return unless @@logging

      Rails.logger.info message
    end
  end
end

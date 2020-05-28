module Touchpoints
  module Tracker
    extend ActiveSupport::Concern

    included do
      after_action :_track_touchpoints
    end

    def _track_touchpoints
      touchpoints = Array(session[get(:session_name)])
                      .then(&method(:keep_only_recent))
                      .then(&method(:add_if_different))
                      .then(&method(:persist_if_logged_in))

      Touchpoints.debug("Touchpoints: #{touchpoints.inspect}")

      session[get(:session_name)] = touchpoints.last(get(:capacity))
    end

    private

    def domain_from(string) # TODO: come up with a more resilient way of extracting the domain
      uri = URI.parse string
      return unless uri.host

      uri.host.split('.').reverse[0..2].reverse.join('.')
    end

    def keep_only_recent(touchpoints)
      touchpoints.select { |touchpoint| touchpoint['created_at'] > 60.days.ago }
    end

    def add_if_different(touchpoints)
      return touchpoints if domain_from(request.original_url) == domain_from(request.referer.to_s)

      last_touchpoint = Hash(touchpoints.last)
      utm_params = params.permit(*get(:utm_params)).to_h

      new_touchpoint = { 'utm_params' => utm_params, 'referer' => request.referer, 'created_at' => Time.current }

      Touchpoints.debug("Touchpoint (new): #{new_touchpoint.inspect}")
      Touchpoints.debug("Touchpoint (last): #{last_touchpoint.inspect}")

      if !equivalent_touchpoints?(new_touchpoint, last_touchpoint)
        touchpoints << new_touchpoint
        Touchpoints.debug('Touchpoint noted!')
      end

      touchpoints
    end

    def persist_if_logged_in(touchpoints)
      return touchpoints unless logged_in?

      last_touchpoint_persisted = get(:model).constantize.where(get(:model_foreign_id) => user_id).last
      last_touchpoint_attributes = last_touchpoint_persisted ? last_touchpoint_persisted.attributes.slice('utm_params', 'referer') : {}

      touchpoints.each do |touchpoint|
        next if equivalent_touchpoints?(touchpoint, last_touchpoint_attributes)

        touchpoint[get(:model_foreign_id)] = user_id if logged_in?
        get(:model).constantize.new(touchpoint).save
        Touchpoints.debug('Touchpoint persisted!')
        last_touchpoint_persisted = nil
      end

      []
    end

    def logged_in?
      respond_to?(get(:current_user_method)) && send(get(:current_user_method)).present?
    end

    def user_id
      send(get(:current_user_method)).send(get(:model_id))
    end

    def equivalent_touchpoints?(a, b)
      a['utm_params'] == b['utm_params'] && a['referer'] == b['referer']
    end

    def get(option)
      Touchpoints.get(option)
    end
  end
end

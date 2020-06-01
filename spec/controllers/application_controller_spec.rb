require 'rails_helper'

RSpec.describe ApplicationController do

  describe 'Tracking touchpoints in session' do

    it 'records a direct visit' do
      get :show

      expect(session['_touchpoints'].first).to include({ "utm_params" => {}, "referer" => nil })
    end

    it 'records only one direct visit' do
      get :show
      get :show

      expect(session['_touchpoints'].count).to eq 1
      expect(session['_touchpoints'].first).to include({ "utm_params" => {}, "referer" => nil })
    end

    it 'records nothing when navigating internally' do
      request.env['HTTP_REFERER'] = 'http://test.host/'

      get :show

      expect(session['_touchpoints'].count).to eq 0
    end

    it 'records a visit from Google' do
      request.env['HTTP_REFERER'] = 'http://google.com'

      get :show

      expect(session['_touchpoints'].first).to include({ "utm_params" => {}, "referer" => 'http://google.com' })
    end

    it 'records a direct visit and partner visit' do
      get :show
      get :show, params: { utm_source: 'Company' }

      expect(session['_touchpoints'].count).to eq 2
      expect(session['_touchpoints'].first).to include({ "utm_params" => {}, "referer" => nil })
      expect(session['_touchpoints'].last).to include({ "utm_params" => { "utm_source" => 'Company' }, "referer" => nil })
    end

    it 'records up to CAPACITY visits' do
      23.times { |i| get :show, params: { utm_source: i } }

      expect(session['_touchpoints'].count).to eq 22
    end
  end
end

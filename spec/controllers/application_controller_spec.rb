require 'rails_helper'

RSpec.describe ApplicationController do
  describe 'Engine is included in an application that identifies users' do
    it 'prompts to log in' do
      get :show

      expect(response.body).to include 'Log in'
    end

    it 'displays greeting' do
      get :show, session: { user_id: 1 }

      expect(response.body).to include 'Hi!'
    end
  end

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

  describe 'Tracking touchpoints in database' do
    it 'moves record to database once logged in' do
      get :show

      expect(session['_touchpoints'].first).to include({ "utm_params" => {}, "referer" => nil })

      get :show, session: { user_id: 1 }

      expect(session['_touchpoints']).to be_empty
      expect(Touchpoint.count).to eq 1
      expect(Touchpoint.first.attributes).to include({ "user_id" => 1, "utm_params" => {}, "referer" => nil })
    end
  end
end

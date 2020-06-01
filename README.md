A channel is a source of traffic to our application. It could be:
- direct: users enter our bare URL in their browser. No referrer.
- organic: users click on a link on a search engine. Referrer is the search engine URL.
- marketing: users click on a link of an affiliate or paid search result. UTM params are usually set. Referrer is the affiliate URL.
- campaign: users click on a link of an email/site or enter a URL. UTM params are usually set. Referrer may not.

A touchpoint is a visit from the outside world, to our website or set of websites under the same domain.

Attribution is the process of assigning a channel to a customer, so we can know what
channel we'd better put our money on.

Usually, the attributed channel is the first touchpoint found 1 month after the user signed up (or any other event we decide).

```
bin/rails generate migration CreateTouchpoints user_id:integer utm_params:jsonb referer:string created_at:timestamp
```

If we have several hosts with same domain operating as a whole, we must share the session cookie between them. In your `config/initializers/session_store.rb`:

```ruby
Rails.application.config.session_store :cookie_store, key: '_creditspring_session', domain: ENV.fetch('DOMAIN', 'localhost')
```

In your ApplicationController:
```ruby
include Touchpoints::Tracker
```

Configure the gem, in `config/initializers/touchpoints.rb`:
```ruby
Touchpoints.configure do |config|
  config.set :logging, true
  config.set :model_id, :entity_id
  config.set :model_foreign_id, :user_entity_id
end
```

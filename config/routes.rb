Rails.application.routes.draw do
      scope '/rails/action_mailbox', module: 'action_mailbox/ingresses' do
      post "/amazon_ses/inbound_emails" => "amazon_ses/inbound_emails#create", as: :rails_amazon_ses_inbound_emails, format: :json, module: 'action_mailbox/ingresses', constraints: lambda { |request| "require 'debug'; binding.break;"; JSON.parse(request.raw_post)["Type"] == "Notification" }
      post "/amazon_ses/inbound_emails"   => "amazon_ses/subscriptions#create",     as: :rails_amazon_ses_subscriptions_subscribe, format: :json,
        constraints: lambda { |request| JSON.parse(request.raw_post)["Type"] == "SubscriptionConfirmation" }
      post "/amazon_ses/inbound_emails"   => "amazon_ses/subscriptions#destroy",    as: :rails_amazon_ses_subscriptions_unsubscribe, format: :json,
        constraints: lambda { |request| JSON.parse(request.raw_post)["Type"] == "UnsubscribeConfirmation" }
    end

end

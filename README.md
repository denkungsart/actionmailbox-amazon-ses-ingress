# ActionMailboxAmazonSesIngress

Provides _Amazon SES/S3/SNS_ integration with [_Rails ActionMailbox_](https://guides.rubyonrails.org/action_mailbox_basics.html).

## Installation

Add following line to your application's Gemfile:

```ruby
gem 'actionmailbox_amazon_ses_ingress', github: "denkungsart/actionmailbox-amazon-ses-ingress"
```

## Configuration

### Amazon SES/S3/SNS

Configure the _SES_ to deliver incoming emails to an _S3_ bucket and notify an _SNS_ topic.

If your website is hosted at https://www.example.com then configure an _SNS subscription_ to publish the _SES notification_ to this _HTTPS_ endpoint:

https://example.com/rails/action_mailbox/amazon_ses/inbound_emails

### Rails

Configure _ActionMailbox_ to accept emails from Amazon SES:

```
# config/environments/production.rb
config.action_mailbox.ingress = :amazon_ses
```

Configure _SNS_ topics and _S3_ credentials:

```
# config/mailbox.yml
production:
  amazon_ses:
    subscribed_topics:
    - <%= ENV["SNS_TOPIC_ARN_1"] %>
    - <%= ENV["SNS_TOPIC_ARN_2"] %>
    s3:
      access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
      secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
```


## Credits
This gem was made possible by the contributions of *Bob Farrell*, *Chris Ortman* and *Marco Borromeo* to this [pull request](https://github.com/rails/rails/pull/39364).

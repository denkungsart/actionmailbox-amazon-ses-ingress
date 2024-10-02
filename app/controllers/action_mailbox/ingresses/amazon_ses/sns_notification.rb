# frozen_string_literal: true

begin
  require "aws-sdk-sns"
rescue LoadError => e
  raise LoadError,
        "Could not load the 'aws-sdk-sns' gem. Ensure that you've added the gem to your Gemfile.", e.backtrace
end

module ActionMailbox
  module Ingresses
    module AmazonSes
      class SnsNotification
        class MessageContentError < StandardError; end

        def initialize(request_body)
          @request_body = request_body
        end

        def subscription_confirmed?
          confirmation_response.code&.start_with?("2")
        end

        def verified?
          Aws::SNS::MessageVerifier.new.authentic?(@request_body)
        end

        def topic
          notification.fetch(:TopicArn)
        end

        def message_content
          if receipt? && content_in_s3?
            Rails.logger.warn "AmazonSes::Ingress #{message.fetch(:mail, {}).except(:headers).inspect}"

            raw_email = S3Download.new(bucket: bucket, key: key, region: region).content

            # Prepend BCC recipients to allow successful routing.
            bcc_recipients.each { |to| raw_email.prepend("X-Original-To: ", to, "\n") }

            return raw_email
          end

          raise MessageContentError, "Incoming emails must have notificationType `Received` and must be stored to S3"
        end

        private
          def notification
            @notification ||= JSON.parse(@request_body, symbolize_names: true)
          rescue JSON::ParserError => e
            Rails.logger.warn("Unable to parse SNS notification: #{e}")
            nil
          end

          def message
            @message ||= JSON.parse(notification[:Message], symbolize_names: true)
          end

          def action
            message.fetch(:receipt).fetch(:action)
          end

          def bucket
            action.fetch(:bucketName)
          end

          def region
            action.fetch(:topicArn).split(":")[3]
          end

          def key
            action.fetch(:objectKey)
          end

          def content_in_s3?
            action.fetch(:type) == "S3"
          end

          def receipt?
            message.fetch(:notificationType) == "Received"
          end

          def bcc_recipients
            message.fetch(:mail).fetch(:commonHeaders).fetch(:bcc, []).map { |email| Mail::Address.new(email).address }
          end

          def confirmation_response
            @confirmation_response ||= Net::HTTP.get_response(URI(notification[:SubscribeURL]))
          end
      end
    end
  end
end

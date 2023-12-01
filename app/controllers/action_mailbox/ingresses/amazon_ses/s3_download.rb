# frozen_string_literal: true

require "tempfile"

module ActionMailbox
  module Ingresses
    module AmazonSes
      class S3Download
        def initialize(bucket:, key:, region:)
          @bucket = bucket
          @key = key
          @region = region
        end

        def content
          s3_client = Aws::S3::Client.new(
            region: region,
            access_key_id: access_key_id,
            secret_access_key: secret_access_key
          )

          s3_object = s3_client.get_object(key: key, bucket: bucket)

          if (kms_cmk_id = JSON.parse(s3_object.metadata['x-amz-matdesc'])['kms_cmk_id'])
            s3_encryption_client = Aws::S3::EncryptionV2::Client.new(
              client: s3_client,
              kms_key_id: kms_cmk_id,
              key_wrap_schema: :kms_context,
              content_encryption_schema: :aes_gcm_no_padding,
              security_profile: :v2_and_legacy # SES currently uses V1 encryption schema to encrypt emails
            )

            s3_object = s3_encryption_client.get_object(key: key, bucket: bucket)
          end

          s3_object.body.string
        end

        private
          attr_reader :bucket, :key, :region

          def access_key_id
            AmazonSes.config.dig(:s3, :access_key_id)
          end

          def secret_access_key
            AmazonSes.config.dig(:s3, :secret_access_key)
          end
      end
    end
  end
end

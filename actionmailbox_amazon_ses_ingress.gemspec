require_relative "lib/actionmailbox_amazon_ses_ingress/version"

Gem::Specification.new do |spec|
  spec.name        = "actionmailbox_amazon_ses_ingress"
  spec.version     = ActionmailboxAmazonSesIngress::VERSION
  spec.authors     = ["Sunil Sharma"]
  spec.email       = ["sunilss395@gmail.com"]
  spec.summary     = "Add Amazon SES Ingress to ActionMailbox"


  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.7.2"
  spec.add_dependency 'aws-sdk-sns', '~> 1.65'
  spec.add_dependency 'aws-sdk-s3', '~> 1.134'

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'webmock', '~> 3.19', '>= 3.19.1'

end

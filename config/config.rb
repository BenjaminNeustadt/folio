require 'dotenv/load'
require 'aws-sdk-s3'

configure :development, :test do
  # Allow code to refresh without having to restart server
  register Sinatra::Reloader
  # AWS credentials
  Aws.config.update({
  region: 'eu-north-1',
  credentials: Aws::Credentials.new(ENV['S3_ACCESS_KEY'], ENV['S3_SECRET_KEY'])
  })
  set :s3, Aws::S3::Resource.new
  set :bucket, settings.s3.bucket('folio-test-bucket')
end



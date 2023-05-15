require 'exif'

data = Exif::Data.new(File.open('lib/test_images/test_spain.jpeg'))
require 'pry'
binding.pry
# p data.model
# p data.gps_longitude
# p data.date_time
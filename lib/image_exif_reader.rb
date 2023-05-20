require 'exif'

data = Exif::Data.new(File.open('lib/test_images/food_paris.jpeg'))
p data.gps_latitude
p data.gps_longitude

def convert_gps_coordinates(coordinate)
  degrees = coordinate[0].numerator.to_f / coordinate[0].denominator
  minutes = coordinate[1].numerator.to_f / coordinate[1].denominator / 60
  seconds = coordinate[2].numerator.to_f / coordinate[2].denominator / 3600
  
  decimal_coordinate = degrees + minutes + seconds
  decimal_coordinate
end

decimal_latitude = convert_gps_coordinates(data.gps_latitude)
decimal_longitude = convert_gps_coordinates(data.gps_longitude)

puts '~-+' * 15
puts 'Terminal Test: conversion of gps arrays'
puts "Decimal Latitude: #{decimal_latitude}"
puts "Decimal Longitude: #{decimal_longitude}"
puts '~-+' * 15

if $PROGRAM_NAME == __FILE__

  def inspection
    begin
      puts '~-+' * 15
      puts 'Terminal Test'
      puts '~-+' * 15
      yield if block_given?
    end if $debug
  end

  $debug = true
  inspection &-> do
    data = [
      :model,
      :date_time,
      :gps_longitude,
      :gps_latitude,
      :gps_altitude,
      :fnumber,
      :focal_length_in_35mm_film,
    ].map do |method|
      data.send method
    end.flatten
    puts <<~EOS % data
    Device Model: %s
            Date: %s
       Longitude: %.2f° %.2f" %.2f'
        Latitude: %.2f° %.2f" %.2f'
        Altitude: %.2f
        f_number: %.4f
    focal_length: %.2fmm
        EOS
  end

  $debug = false

end

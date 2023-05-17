require 'exif'

data = Exif::Data.new(File.open('lib/test_images/test_spain.jpeg'))

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

module EXIFReaderHelper

  def convert_gps_coordinates(coordinate)
    degrees = coordinate[0].numerator.to_f / coordinate[0].denominator
    minutes = coordinate[1].numerator.to_f / coordinate[1].denominator / 60
    seconds = coordinate[2].numerator.to_f / coordinate[2].denominator / 3600
    
    decimal_coordinate = degrees + minutes + seconds
    decimal_coordinate
  end

  def extract_exif_data(file)
    data = Exif::Data.new(File.open(file))
    @date_time = data.date_time
    @gps_longitude = convert_gps_coordinates(data.gps_longitude)
    @gps_latitude = convert_gps_coordinates(data.gps_latitude)
  end

end
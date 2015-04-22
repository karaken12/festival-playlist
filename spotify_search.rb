
require 'rspotify'
require 'yaml'

config_path = File.expand_path('app_secret.yml', File.dirname(__FILE__))
$app_config = YAML.load_file(config_path)

def process(file_name)
  data = YAML.load_file(file_name)
  artist_list = []

  RSpotify.authenticate($app_config['spotify']['client_id'], $app_config['spotify']['client_secret'])

  data.each do |artist_name|
    puts "Searching for #{artist_name}"
    search_string = "\"#{artist_name}\""
    artists = RSpotify::Artist.search(search_string, market: 'GB')
    if artists.count == 0
      puts "No artists found!"
    elsif artists.count == 1
      puts "One artist found: #{artists[0].name}"
      artist_list.push(artists[0])
    else
      puts "Several artists found; top artist is #{artists[0].name}"
      artist_list.push(artists[0])
    end
  end

  tracks = []
  artist_list.each do |artist|
    top_tracks = artist.top_tracks(:GB)
    puts top_tracks.size
    puts top_tracks.first.name
    top_tracks.take(3).each {|track| tracks.push(track)}
  end

  tracks.each do |track|
    puts "#{track.name} by #{track.artists.map{|a| a.name}.join(", ")} (#{track.id})"
  end
end

def create_playlist(user, playlist_name, tracks)
  playlist = user.create_playlist!(playlist_name)
  playlist.add_tracks!(tracks)
  return playlist
end

# Bit nasty, but should do the job
if (ARGV[0])
  process(ARGV[0])
end


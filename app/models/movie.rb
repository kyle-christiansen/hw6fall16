class Movie < ActiveRecord::Base
  def self.all_ratings
   %w(G PG PG-13 NC-17 R NA)
  end
  
def self.find_in_tmdb(string)
    movie_list_hash = []
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    movies_raw = []
    begin
      movies_raw = Tmdb::Movie.find(string)
      
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
    movies_raw.each do |movie|
      releases = Tmdb::Movie.releases(movie.id)["countries"]
      rating = Movie.getRating(releases)
      
      if(rating != nil) then
        movie_list_hash.push({:tmdb_id => movie.id, :title => movie.title, :rating => rating, :release_date => movie.release_date})
      end
    end
    
    return movie_list_hash
  end
  
  def self.getRating(releases)
    rating = nil
    releases.each do |release|
      if (release["iso_3166_1"] == "US" && (release["certification"] == "G" || release["certification"] == "PG" || release["certification"] == "PG-13" || release["certification"] == "R" || release["certification"] == "NC-17")) then
        rating = release["certification"]
      end
    end
    return rating
  end
  
  def self.create_from_tmdb(tmdb_movie_id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    movie_info = Tmdb::Movie.detail(tmdb_movie_id)
    releases = Tmdb::Movie.releases(tmdb_movie_id)["countries"]
    rating = Movie.getRating(releases)
    newMovie = Movie.new(:title => movie_info["original_title"], :release_date => movie_info["release_date"], :rating => rating)
    newMovie.save
  end
end

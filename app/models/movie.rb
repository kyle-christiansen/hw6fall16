class Movie < ActiveRecord::Base
  def self.all_ratings
   %w(G PG PG-13 NC-17 R NR)
  end

  class Movie::InvalidKeyError < StandardError ; end


  def self.find_in_tmdb(string)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      @searchedMovies = Tmdb::Movie.find(string)
      @movieList=[]
      @movieRating = nil
      if @searchedMovies != nil
        @searchedMovies.each do |movie|    
          @movieRating = getRating(movie.id)
          if !movie.release_date.blank?
            @movieList << {:title => movie.title, :rating => @movieRating, :tmdb_id => movie.id, :release_date => movie.release_date} 
          end
        end
      end
      return @movieList
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
  
  def self.getRating(id)
    rating = nil
      Tmdb::Movie.releases(id)["countries"].each do |results|
        if results["iso_3166_1"] == "US"
          rating = results["certification"]
          break
        end
      end
      if rating.to_s.strip.length == 0 
        rating = "NR"
      end
    return rating  
  end
  

  def self.create_from_tmdb(tmdb_movie_id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    movie_info = Tmdb::Movie.detail(tmdb_movie_id)
    rating = getRating(tmdb_movie_id)
    if rating.to_s.strip.length == 0
      rating = "NR"
    end
    Movie.create!(:title => movie_info["title"], :rating => rating,:description => movie_info["overview"], :release_date => movie_info["release_date"])
  end
end

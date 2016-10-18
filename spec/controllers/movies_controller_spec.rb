require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    
    it 'should select the Search Results template for rendering' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end
    
    
    it 'should check for invalid search terms then notify user' do
      post :search_tmdb, {:search_terms => ''}
      expect(response).to redirect_to(movies_path)
      expect(flash[:warning]).to eq("Invalid search term")
    end 
    
    it 'should check for no match from search then notify user' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'movie title with no match'}
      expect(response).to redirect_to(movies_path)
      expect(flash[:warning]).to eq("No matching movies were found on TMDb")
    end
    
    it 'should redirect the user if no match for search terms' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to redirect_to(movies_path)
    end 
    
    it 'should create two instance variables for communication with the view' do
      fake_results = 'fake'
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'fake'}
      expect(assigns(:search_terms)).to eq 'fake'
      expect(assigns(:movies)).to eq 'fake'
    end
   
    it 'if flash "No Movies Selected" if no movies checked' do 
      post :add_tmdb, {:tmdb_movies => []}
      expect(response).to redirect_to(movies_path)
      expect(flash[:warning]).to eq("No movies selected")
    end
  end
end
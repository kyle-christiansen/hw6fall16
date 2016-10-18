require 'spec_helper'
require 'rails_helper'


describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
      
      
      it 'should return an empty array if Tmdb does not find movie' do
        no_results = []
        allow(Tmdb::Movie).to receive(:find).with('Inception').and_return(no_results)
        expect(Movie.find_in_tmdb('Inception').empty?).to be true
      end
      
      it 'should return an array of hashes' do
        
        lethal_movie = [Tmdb::Movie.new({id: 941, title: 'Lethal Weapon', release_date: "1987-03-06"})]
        expect(Tmdb::Movie).to receive(:find).with('Lethal Weapon').and_return(lethal_movie)
        allow(Movie).to receive(:get_rating).with(941).and_return('R')
        test_result = Movie.find_in_tmdb('Lethal Weapon')[0]
        
        expect(test_result[:tmdb_id]).to eq(941)
        expect(test_result[:title]).to eq('Lethal Weapon')
        expect(test_result[:release_date]).to eq("1987-03-06")
        expect(test_result[:rating]).to eq('R')
      end
    end
    
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
    
    
  end
  
end

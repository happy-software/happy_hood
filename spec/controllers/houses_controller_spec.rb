require 'rails_helper'

describe HousesController, type: :request do
  describe 'GET valuations' do
    context 'with zpid that does not exist' do
      it 'returns an error message' do
        get '/house_valuations/xxx'
        expect(response).to_not be_successful
        expect(response.status).to eq(404)
      end
    end

    context 'with an existing house' do
      let(:hood)            { Hood.create!(name: 'TestHood') }
      let(:house)           { House.create!(price_history: history, hood: hood) }
      let(:house_metadatum) { HouseMetadatum.create!(house: house, zpid: '123') }
      let(:history) do
        {
          '2021-01-01' => 123,
          '2021-01-02' => 124,
        }
      end

      it 'should return the price history' do
        get "/house_valuations/#{house_metadatum.zpid}"
        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).dig('data')).to eq(history)
      end
    end
  end
end
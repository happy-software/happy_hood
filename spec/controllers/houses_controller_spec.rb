require 'rails_helper'

describe HousesController, type: :request do
  let(:hood)            { Hood.create!(name: 'TestHood') }
  let(:house)           { House.create!(price_history: history, hood: hood) }
  let(:house_metadatum) { HouseMetadatum.create!(house: house, zpid: '123') }
  let(:history) do
    {
      '2021-01-01' => 123,
      '2021-01-02' => 124,
    }
  end
  let(:mock_api_token) { "mock-token" }
  let(:encrypted_mock_api_token) { ActionController::HttpAuthentication::Token.encode_credentials(mock_api_token) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:[]).with("HAPPY_HOUSE_API_TOKEN").and_return(mock_api_token)
  end

  describe 'GET valuations' do
    context 'with zpid that does not exist' do
      it 'returns an error message' do
        get '/house_valuations/xxx',
            headers: { "HTTP_AUTHORIZATION" => encrypted_mock_api_token }
        expect(response).to_not be_successful
        expect(response.status).to eq(404)
      end
    end

    context 'with an existing house' do
      it 'should return the price history' do
        get "/house_valuations/#{house_metadatum.zpid}",
            headers: { "HTTP_AUTHORIZATION" => encrypted_mock_api_token }
        expect(response).to be_successful
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).dig('data')).to eq(history)
      end
    end
  end

  describe 'POST valuations' do
    context 'with a zpid that does not exist' do
      it 'returns an error message' do
        post '/house_valuations/xxx',
             headers: { "HTTP_AUTHORIZATION" => encrypted_mock_api_token }
        expect(response).to_not be_successful
        expect(response.status).to eq(404)
      end
    end

    context 'with an existing house' do
      let(:valuations_to_import) do
        {
          '2021-01-03' => 125,
          '2021-01-04' => 126,
        }.to_json
      end
      it 'should append imported data to house.price_history' do
        expect(house.price_history).to eq(history)
        post "/house_valuations/#{house_metadatum.zpid}",
             headers: { "HTTP_AUTHORIZATION" => encrypted_mock_api_token },
             params: {valuations: valuations_to_import}
        expect(house.reload.price_history).to eq(history.merge(JSON.parse valuations_to_import))
        expect(response.status).to eq(200)
      end
    end

    context 'without any valuations passed in' do
      it 'returns an error message' do
        post "/house_valuations/#{house_metadatum.zpid}",
             headers: { "HTTP_AUTHORIZATION" => encrypted_mock_api_token },
             params: {}
        expect(response).not_to be_successful
        expect(response.status).to eq(400)
      end
    end
  end
end

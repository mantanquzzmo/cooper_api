# frozen_string_literal: true

RSpec.describe Api::V1::PerformanceDataController, type: :request do
  let(:user) { create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  describe 'POST /api/v1/performance_data' do
    before do
      post '/api/v1/performance_data',
          params: {
            performance_data: {
              data: { message: 'Average' }
            }
          },
          headers: headers
    end

    it 'returns a 200 response status' do
      expect(response).to have_http_status 200
    end

    it 'successfully creates a data entry' do
      entry = PerformanceData.last
      expect(entry.data).to eq 'message' => 'Average'
    end
  end

  describe 'GET /api/v1/performance_data' do
    let!(:existing_entries) do
      5.times do
        create(:performance_data,
              data: { message: 'Average' },
              user: user)
      end
    end

    before do
      get '/api/v1/performance_data', headers: headers
    end

    it 'returns a 200 response status' do
      expect(response).to have_http_status 200
    end

    it 'returns a collection of performance data' do
      expect(response_json['entries'].count).to eq 5
    end
  end

  describe 'user gets collection of only its own data' do
    let!(:another_user) { create(:user, email: 'coach@craftacademy.se') }
    let!(:existing_entry1) do
      create(:performance_data,
            data: { message: 'Average' },
            user: user)
    end
    let!(:existing_entry2) do
      create(:performance_data,
            data: { message: 'Excellent' },
            user: another_user)
    end

    before do
      sign_in user
      get '/api/v1/performance_data', headers: headers
    end
    it 'returns a 200 response status' do
      expect(response).to have_http_status 200
    end
    it 'returns the users performance data' do
      entry = PerformanceData.find_by(user_id: user.id)
      expect(entry.data).to eq 'message' => 'Average'
    end
  end
end

require 'spec_helper'

describe '/api/v1/conferences/*/proposals' do
  before {
    @conference = FactoryGirl.create(:conference_with_3_proposals)
    @stem = "/api/v1/conferences/#{@conference.conference_year}/proposals"
    sign_in_as_a_admin_user
  }

  describe 'search' do
    it 'should return an array of proposals without a status' do
      get "#{@stem}/search"
      expect(response.status).to eql(200)

      expect(json.length).to eql(3)
    end

    it 'should return an accepted proposal when status=accept' do
      @proposal = FactoryGirl.create(:accepted_proposal_with_presenter)
      conference = @proposal.conference
      get "/api/v1/conferences/#{conference.conference_year}/proposals/search?status=accept"
      expect(response.status).to eql(200)

      expect(json.length).to eql(1)
    end

    it 'should not return an accepted proposal when status is not set' do
      @proposal = FactoryGirl.create(:accepted_proposal_with_presenter)
      conference = @proposal.conference
      get "/api/v1/conferences/#{conference.conference_year}/proposals/search"
      expect(response.status).to eql(200)

      expect(json.length).to eql(0)
    end
  end
end
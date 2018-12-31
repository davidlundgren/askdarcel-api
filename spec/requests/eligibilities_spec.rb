# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Eligibilities' do
  context 'index' do
    let!(:eligibilities) { create_list :eligibility, 3 }

    it 'returns all eligibilities ordered by name' do
      get '/eligibilities'

      expect(response).to be_ok
      items = response_json['eligibilities']
      expect(items.size).to eq(3)
      names = items.map { |item| item['name'] }
      expect(names).to eq(names.sort)
    end
  end

  context 'featured' do
    let!(:eligibilities) { create_list :eligibility, 3 }

    before do
      # e1 and e2 are featured, but not e3.
      # e2 has highest rank.
      e1, e2 = eligibilities[0..1]
      e1.update(feature_rank: 2)
      e2.update(feature_rank: 1)

      # e2 is associated with 2 resources
      2.times { e2.services << create(:service, resource: create(:resource)) }
      # e1 is associated with 1 resource
      e1.services << create(:service, resource: create(:resource))
    end

    it 'returns all featured eligibilities, ordered by feature_rank, along with resource counts' do
      get '/eligibilities/featured'

      expect(response).to be_ok
      items = response_json['eligibilities']
      expect(items.size).to eq(2)

      e1, e2 = eligibilities[0..1]
      expect(items[0]['id']).to eq(e2.id)
      expect(items[0]['resource_count']).to eq(2)
      expect(items[1]['id']).to eq(e1.id)
      expect(items[1]['resource_count']).to eq(1)
    end
  end
end

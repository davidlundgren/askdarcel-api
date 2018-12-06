# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Algolia Reindex Job' do
  context 'when scheduling a reindex job' do
    it 'enqueues a new background job properly' do
      expect(Delayed::Job.all).to be_empty

      AlgoliaReindexJob.perform_async

      expect(Delayed::Job.count).to eq(1)
      delayed_job = Delayed::Job.first
      expect(delayed_job.handler).to include('AlgoliaReindexJob')
    end
  end

  context 'when executing a reindex job' do
    it 'runs Algolia reindex operation on the expected models' do
      resource_query = double
      expect(Resource).to receive(:where).with(status: :approved).and_return(resource_query)
      expect(resource_query).to receive(:reindex)

      service_query = double
      expect(Service).to receive(:where).with(status: :approved).and_return(service_query)
      expect(service_query).to receive(:reindex!)

      AlgoliaReindexJob.new.perform
    end
  end
end

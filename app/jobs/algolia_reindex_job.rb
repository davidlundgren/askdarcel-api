# frozen_string_literal: true

# Background job to reindex all relevant database records in Algolia.
#
# Usage:
#
# To send job to a background worker to execute:
#
# > AlgoliaReindexJob.perform_async
#
# To execute in-line immediately from Rails console:
#
# > AlgoliaReindexJob.new.perform
#
class AlgoliaReindexJob
  def self.perform_async
    Delayed::Job.enqueue(AlgoliaReindexJob.new)
  end

  def perform
    Resource.where(status: :approved).reindex
    # Since Service and Resource share an algolia index, we use `reindex!` so
    # Service reindexing does not clear out Resource index records.
    Service.where(status: :approved).reindex!
  end
end

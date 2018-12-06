# frozen_string_literal: true

namespace :algolia do
  task reindex: :environment do
    print "Reindexing resource/service index... "
    AlgoliaReindexJob.new.perform
    puts "success."
  end
end

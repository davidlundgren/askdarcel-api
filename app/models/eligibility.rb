# frozen_string_literal: true

class Eligibility < ApplicationRecord
  has_and_belongs_to_many :services

  # Given a list of eligibility ids, return a map from eligibility id to number
  # of resources associated with that eligibility.
  #
  # Performance note: For efficiency, this method only executes two SQL
  # queries. It relies on the assumption that the number of associations
  # between eligibilities and resources is small enough to fit in memory easily
  # (i.e. on the order of 100s).
  #
  # @param :eligibility_ids [ Array<Integer> ] array of eligibility ids
  # @return [ Hash ] map whose keys are eligibility ids and whose values are
  # the number of resources associated with the eligibility
  def self.resource_counts(eligibility_ids)
    # Compute map from eligibility_id to set of service_ids
    pairs = EligibilitiesService.where(eligibility_id: eligibility_ids).pluck(:eligibility_id, :service_id)
    eligibility_to_services = Hash.new { |h, k| h[k] = Set.new }
    pairs.each do |eligibility_id, service_id|
      eligibility_to_services[eligibility_id] << service_id
    end
    service_ids = pairs.map(&:last).uniq

    # Compute map from service_id to resource_id
    service_to_resource = Service.where(id: service_ids).pluck(:id, :resource_id).to_h

    # Using the two maps above, compute map from eligibility_id to set of resource_ids
    eligibility_to_resources = Hash.new { |h, k| h[k] = Set.new }
    eligibility_to_services.each do |eligibility_id, service_ids|
      service_ids.each do |service_id|
        resource_id = service_to_resource[service_id]
        next if resource_id.nil?
        eligibility_to_resources[eligibility_id] << resource_id
      end
    end

    # Return map from eligibility_id to count of resource_ids
    eligibility_to_resources.map do |eligibility_id, resource_ids|
      [eligibility_id, resource_ids.size]
    end.to_h
  end
end

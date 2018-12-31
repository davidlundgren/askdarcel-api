# frozen_string_literal: true

class EligibilitiesController < ApplicationController
  # GET /eligibilities
  def index
    eligibilities = Eligibility.order(:name)

    render json: EligibilityPresenter.present(eligibilities)
  end

  # GET /eligibilities/featured
  #
  # Returns featured eligibilities sorted by `feature_rank`. In addition,
  # returns the number of resources associated with each eligibility.
  def featured
    eligibilities = Eligibility.order(:feature_rank).where.not(feature_rank: nil).to_a

    eligibility_resource_counts = Eligibility.resource_counts(eligibilities.map(&:id))

    items = EligibilityPresenter.present(eligibilities)
    items.each do |item|
      item['resource_count'] = eligibility_resource_counts[item['id']]
    end

    render json: { eligibilities: items }
  end
end

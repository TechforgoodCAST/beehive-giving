module Funds
  module FilterSort
    def country(state = nil)
      state.blank? ? all : joins(:countries).where('countries.alpha2': state)
    end

    def eligibility(state = nil)
      eligibility = {
        'eligible'   => ELIGIBLE,
        'ineligible' => INELIGIBLE,
        'to-check'   => [UNASSESSED, INCOMPLETE]
      }[state]

      eligibility ? where('assessments.eligibility_status': eligibility) : all
    end

    def filter_sort(proposal = nil, params = {})
      join(proposal)
        .includes(:funder, :themes, :geo_area)
        .order_by(params[:sort])
        .country(params[:country])
        .eligibility(params[:eligibility])
        .funding_type(params[:type])
        .revealed(params[:revealed])
        .active
        .select_view_columns
    end

    def funding_type(state = nil)
      type = { 'capital' => 1, 'revenue' => 2 }[state]
      type ? where("permitted_costs @> '[#{type}]'") : all
    end

    def join(proposal = nil)
      joins(
        'LEFT JOIN assessments ' \
        'ON funds.id = assessments.fund_id ' \
        "AND assessments.proposal_id = #{proposal&.id || 'NULL'}"
      )
    end

    def order_by(col = nil)
      order = [
        'assessments.revealed',
        ('assessments.eligibility_status DESC' unless col == 'name'),
        'funds.name'
      ]
      order(*order)
    end

    def revealed(state)
      state.to_s == 'true' ? where('assessments.revealed': state) : all
    end

    def select_view_columns
      select(
        'funds.*',
        'assessments.id AS assessment_id',
        'assessments.proposal_id',
        'assessments.eligibility_status',
        'assessments.revealed'
      )
    end
  end
end

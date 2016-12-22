class Admin::Api::StatsController < Admin::Api::BaseController

  def show

    unless params[:event].present? ||
           params[:visits].present? ||
           params[:unverified_users].present? ||
           params[:spending_proposals].present? ||
           params[:user_voted_budgets].present?
      return render json: {}, status: :bad_request
    end

    ds = Ahoy::DataSource.new

    if params[:event].present?
      ds.add params[:event].titleize, Ahoy::Event.where(name: params[:event]).group_by_day(:time).count
    end

    if params[:visits].present?
      ds.add "Visits", Visit.group_by_day(:started_at).count
    end

    if params[:unverified_users].present?
      ds.add "Usuarios sin verificar", User.with_hidden.unverified.group_by_day(:created_at).count
    end

    if params[:spending_proposals].present?
      ds.add "Spending proposals", SpendingProposal.group_by_day(:created_at).count
    end

    if params[:user_voted_budgets].present?
      ds.add "User voted budgets", Ballot.where('ballot_lines_count > ?', 0).group_by_day(:updated_at).count
    end
    render json: ds.build
  end
end

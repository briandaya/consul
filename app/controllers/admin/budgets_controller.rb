class Admin::BudgetsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  has_filters %w{current finished}, only: :index

  before_action :load_budget
  load_and_authorize_resource

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
  end

  def edit
  end

  def update
    if @budget.update(budget_params)
      redirect_to admin_budget_path(@budget), notice: t('admin.budgets.update.notice')
    else
      render :edit
    end
  end

  def create
    @budget = Budget.new(budget_params)
    if @budget.save
      redirect_to admin_budget_path(@budget), notice: t('admin.budgets.create.notice')
    else
      render :new
    end
  end

  private

    def budget_params
      descriptions = Budget::PHASES.map{|p| "description_#{p}"}.map(&:to_sym)
      valid_attributes = [:name, :phase, :currency_symbol] + descriptions
      params.require(:budget).permit(*valid_attributes)
    end

    def load_budget
      @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
    end

end

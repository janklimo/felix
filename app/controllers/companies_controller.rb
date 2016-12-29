class CompaniesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_company, only: [:edit, :update]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.admin_id = current_admin.id
    if @company.save
      flash[:notice] = "Yay! Your company has been created."
      redirect_to admin_home_path
    else
      render :new
    end
  end

  def edit
    authorize! :manage, @company
  end

  def update
    authorize! :manage, @company
    if @company.update(company_params)
      flash[:notice] = "Yay! Your company has been updated."
      redirect_to admin_home_path
    else
      render :edit
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :size)
  end
end

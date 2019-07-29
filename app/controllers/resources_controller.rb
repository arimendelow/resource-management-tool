class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user

  # GET /resources
  # GET /resources.json
  def index
    params[:selected_skills] = [] if !params[:selected_skills]
    # @resources = Resource.all
    # .values turns the result from a hash map into an array
    # .flatten ensures that the array is only one dimensional
    @skills = ActiveRecord::Base.connection.execute(
      "SELECT DISTINCT *
      FROM
      (
        SELECT unnest(skills)
        FROM public.resources
      ) AS all_skills"
    ).values.flatten
    selected_skills = params[:selected_skills] || []
    @resources = Resource.where("skills @> :selected_skills", selected_skills: selected_skills.to_s.sub('[','{').sub(']','}'))
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    # Get the skills an array, stripping leading/trailing whitespace
    skills_arr = resource_params[:skills].split(/\s*,\s*/)
    @resource = Resource.new(resource_params)
    # Put 'skills' in as an array
    @resource.update_attribute(:skills, skills_arr)

    respond_to do |format|
      if @resource.save
        format.html { redirect_to @resource, notice: 'Resource was successfully created.' }
        format.json { render :show, status: :created, location: @resource }
      else
        format.html { render :new }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    respond_to do |format|
      # Put 'skills' in as an array
      skills_arr = resource_params[:skills].split(/\s*,\s*/)
      if @resource.update(resource_params) && @resource.update_attribute(:skills, skills_arr)
        format.html { redirect_to @resource, notice: 'Resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @resource }
      else
        format.html { render :edit }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url, notice: 'Resource was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:uid, :name, :skills, :portfolio, :start_date, :location, :manager)
    end
end

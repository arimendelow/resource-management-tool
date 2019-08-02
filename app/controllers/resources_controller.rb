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
    # .sort to make it sorted alphabetically
    @skills = ActiveRecord::Base.connection.execute(
      "SELECT DISTINCT unnest(skills)
        FROM public.resources"
    ).values.flatten.sort
    selected_skills = params[:selected_skills] || []
    @attributes = Resource.attribute_names
    selected_attributes = params[:selected_attributes] || ["id", "name", "uid", "skills"]
    # Get filter the resources, and need to change the [] from the Ruby array to the {} of the SQL array. Also, sort it by UID.
    # Also, note that passing an empty array will return everything, rather than nothing
    @resources = Resource.where(
      "skills @> :selected_skills", selected_skills: selected_skills.to_s.sub('[','{').sub(']','}')
      )
      .select(selected_attributes.join(', '))
      .order(uid: :asc)

    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=Exported Resources at #{Time.now.to_s}.xlsx"
      }
      format.html { render :index }
    end
  end

  # GET /resources/1
  def show
  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
  end

  # POST /resources/new
  def create
    # Get the skills as an array, stripping leading/trailing whitespace, and make it all title case, and then sort it
    skills_arr = resource_params[:skills].split(/\s*,\s*/).map(&:downcase).map(&:titleize).sort
    # Put 'skills' in as an array
    params = resource_params # 'resource_params' is immutable, apparently
    params[:skills] = skills_arr
    @resource = Resource.new(params)

    if @resource.save
      # 'current_user' is from 'sessions_helper'
      current_user.microposts.create!(content: "<p>created a resource <a href='/resources/#{@resource.id}'>#{@resource.name}</a> with UID #{@resource.uid}</p>")
      flash[:success] = "Resource #{@resource.name} successfully created."
      redirect_to @resource
    else
      @resource.destroy
      render :new
    end
  end

  # PATCH/PUT /resources/1/edit
  def update
    # Get the skills as an array, stripping leading/trailing whitespace, and make it all title case, and then sort it
    skills_arr = resource_params[:skills].split(/\s*,\s*/).map(&:downcase).map(&:titleize).sort
    # Put 'skills' in as an array
    params = resource_params # 'resource_params' is immutable, apparently
    params[:skills] = skills_arr
    if @resource.update_attributes(params)
      # 'current_user' is from 'sessions_helper'
      current_user.microposts.create!(content: "<p>edited the resource <a href='/resources/#{@resource.id}'>#{@resource.name}</a> with UID #{@resource.uid}</p>")
      flash[:success] = "Resource #{@resource.name} successfully edited."
      redirect_to @resource
    else
      render :edit
    end
  end

  # DELETE /resources/1
  def destroy
    uid = @resource.uid
    name = @resource.name
    @resource.destroy

    current_user.microposts.create!(content: "<p>destroyed the resource #{name} with UID #{uid}</p>")
    flash[:success] = "Resource #{name} successfully destroyed."
    redirect_to resources_url 
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

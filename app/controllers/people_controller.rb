class PeopleController < ApplicationController

  def index
    render json: Person.all.map{|p| p.merge(uri: person_url(p[:id]) ) }
  end

  def show
    render json: Person.new(params[:id])
  end

end

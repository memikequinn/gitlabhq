class Admin::VaporsController < Admin::ApplicationController
  def index
    @vapors = Vapor.all
  end

  def new
    @vapor = Vapor.new(params[:vapor])
  end

  def show
    @vapor = Vapor.find(params[:id])
  end

  def create
    @vapor = Vapor.create(params[:vapor])
    puts @vapor.inspect
    respond_to do |format|
      if @vapor.save
        format.html { redirect_to admin_vapor_path(@vapor), notice: 'Vapor was successfully created.' }
      else
        format.html { render "new" }
        format.json { render json: @vapor.errors, status: :unprocessable_entity }
      end

    end
  end

  def update
    @vapor = Vapor.find(params[:id])
    if @vapor.update_attributes(params[:vapor])
      redirect_to admin_vapors_path
    else
      render "edit"
    end
  end

  def edit
    @vapor = Vapor.find(params[:id])
  end

  def destroy
    Vapor.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to admin_vapors_path }
      format.json { head :ok }
    end
  end
end
class ToothbrushesController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    if params[:query].present?
      results = Toothbrush.search(params[:query])
      noresult
      @toothbrushes = []
      @markers = []
      results.each do |toothbrush|
        toothbrush_hash = {
          lat: toothbrush.latitude,
          lng: toothbrush.longitude,
          infoWindow: render_to_string(partial: "info_window", locals: { toothbrush: toothbrush })
        }
        @markers << toothbrush_hash
        @toothbrushes << toothbrush
      end
      policy_scope(Toothbrush)
    else
      @toothbrushes = policy_scope(Toothbrush)
      @markers = @toothbrushes.geocoded.map do |toothbrush|
        {
        lat: toothbrush.latitude,
        lng: toothbrush.longitude,
        infoWindow: render_to_string(partial: "info_window", locals: { toothbrush: toothbrush })
        }
      end
    end
  end

  def noresult
    if results == nil

    end
  end

  def show
    @toothbrush = Toothbrush.find(params[:id])
    @toothbrushes = @toothbrush.user.toothbrushes.reject{ |toothbrush| toothbrush == @toothbrush }
    @review = Review.new
    authorize @toothbrush
  end

  def new
    @toothbrush = Toothbrush.new
    authorize @toothbrush
  end

  def create
    user = current_user
    @toothbrush = Toothbrush.new(toothbrush_params)
    authorize @toothbrush
    @toothbrush.user = user
    if @toothbrush.save
      redirect_to toothbrush_path(@toothbrush)
    else
      render 'new'
    end
  end

  def edit
    @toothbrush = Toothbrush.find(params[:id])
    authorize @toothbrush
  end

  def update
    @toothbrush = Toothbrush.find(params[:id])
    authorize @toothbrush
    if @toothbrush.update(toothbrush_params)
      redirect_to toothbrush_path(@toothbrush)
    else
      render 'edit'
    end
  end

  def destroy
    @toothbrush = Toothbrush.find(params[:id])
    authorize @toothbrush
    @toothbrush.destroy
    redirect_to toothbrushes_path
  end

  private

  def toothbrush_params
    params.require(:toothbrush).permit(:title, :description, :status, :photo, :price, :address)
  end
end

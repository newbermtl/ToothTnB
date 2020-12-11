class ToothbrushesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :count]
  before_action :set_counter

  def index
    if params[:query].present?
      results = Toothbrush.includes(:photo_attachment, :user, :toothbrush_tags, :tags).search(params[:query])
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
      policy_scope(Toothbrush.includes(:photo_attachment, :user, :toothbrush_tags, :tags))
    else
      @toothbrushes = policy_scope(Toothbrush.includes(:photo_attachment, [user: :photo_attachment], [toothbrush_tags: :tag]))
      @toothbrushes = @toothbrushes.where(status: "Available")
      @markers = @toothbrushes.geocoded.map do |toothbrush|
        {
          lat: toothbrush.latitude,
          lng: toothbrush.longitude,
          infoWindow: render_to_string(partial: "info_window", locals: { toothbrush: toothbrush })
        }
      end
    end
  end

  def show
    @toothbrush = Toothbrush.find(params[:id])
    @toothbrushes = @toothbrush.user.toothbrushes.reject { |toothbrush| toothbrush == @toothbrush }
    @review = Review.new
    authorize @toothbrush
  end

  def new
    @toothbrush = Toothbrush.new
    @tag = Tag.all
    authorize @toothbrush
  end

  def create
    @tag = Tag.all
    user = current_user
    @toothbrush = Toothbrush.new(toothbrush_params)
    authorize @toothbrush
    @toothbrush.user = user
    if @toothbrush.save
      tag_ids = params[:toothbrush][:tags]
      if tag_ids
        tag_ids.each do |tag|
          new_tag = ToothbrushTag.new(toothbrush_id: @toothbrush.id, tag_id: tag)
          new_tag.save!
        end
      end
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

  def count
    @toothbrush = Toothbrush.new
    authorize @toothbrush
    render json: { count: Toothbrush.where(status: "Available").count }
  end

  private

  def toothbrush_params
    params.require(:toothbrush).permit(:title, :description, :status, :photo, :price, :address)
  end

  def set_counter
    @toothbrushes_count = Toothbrush.where(status: "Available").count
  end
end

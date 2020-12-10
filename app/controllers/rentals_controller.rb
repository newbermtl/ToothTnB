class RentalsController < ApplicationController
  def new
    @rental = Rental.new
    @toothbrush = Toothbrush.find(params[:toothbrush_id])
    authorize @rental
  end

  def create
    @rental = Rental.new(rental_params)
    @toothbrush = Toothbrush.find(params[:toothbrush_id])
    @rental.user = current_user
    @rental.toothbrush = @toothbrush
    @rental.status = "Pending"
    authorize @rental
    if @rental.save!
      redirect_to rental_path(@rental)
    else
      render 'new'
    end
  end

  def index
    @rentals = policy_scope(Rental)
    @toothbrushes = Toothbrush.includes(:photo_attachment).all.select{ |toothbrush| toothbrush.user_id == current_user.id }
  end

  def show
    @rental = Rental.find(params[:id])
    @user = User.find(@rental[:user_id])
    @toothbrush = Toothbrush.find(@rental[:toothbrush_id])
    authorize @rental
  end

  def accept
    @rental = Rental.find(params[:id])
    # @toothbrush = Toothbrush.find(@rental[:toothbrush_id])
    authorize @rental
    @rental.status = "Accepted"
    @rental.save!
    redirect_to rental_path(@rental)
  end

  def deny
    @rental = Rental.find(params[:id])
    # @toothbrush = Toothbrush.find(@rental[:toothbrush_id])
    authorize @rental
    @rental.status = "Denied"
    @rental.save!
    redirect_to rental_path(@rental)
  end

  private

  def rental_params
    params.require(:rental).permit(:date)
  end
end

class ReviewsController < ApplicationController

  def index
    @reviews = Review.all.order(:created_at)
  end

  def show
    @review = Review.find(params[:id])
  end

  def new 

  end

  def create

  end
  
  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(create_update_params)
      redirect_to reviews_path, notice: 'Review updated successfully'
    else
      flash[:alert] = 'Review could not be edited'
      render :edit, status: :unprocessable_content
    end
  end

  def destroy

  end

private 
  def create_update_params
    params.require(:review).permit(:user, :book, :description, :rating)
  end
end

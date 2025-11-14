class XInterestsController < ApplicationController
  before_action :set_x_interest, only: %i[ show edit update destroy ]

  # GET /x_interests or /x_interests.json
  def index
    @x_interests = XInterest.all
  end

  # GET /x_interests/1 or /x_interests/1.json
  def show
  end

  # GET /x_interests/new
  def new
    @x_interest = XInterest.new
  end

  # GET /x_interests/1/edit
  def edit
  end

  # POST /x_interests or /x_interests.json
  def create
    @x_interest = XInterest.new(x_interest_params)

    respond_to do |format|
      if @x_interest.save
        format.html { redirect_to @x_interest, notice: "X interest was successfully created." }
        format.json { render :show, status: :created, location: @x_interest }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @x_interest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /x_interests/1 or /x_interests/1.json
  def update
    respond_to do |format|
      if @x_interest.update(x_interest_params)
        format.html { redirect_to @x_interest, notice: "X interest was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @x_interest }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @x_interest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /x_interests/1 or /x_interests/1.json
  def destroy
    @x_interest.destroy!

    respond_to do |format|
      format.html { redirect_to x_interests_path, notice: "X interest was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_x_interest
      @x_interest = XInterest.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def x_interest_params
      params.expect(x_interest: [ :type, :query, :user_id ])
    end
end

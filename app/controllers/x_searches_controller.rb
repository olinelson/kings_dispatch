class XSearchesController < ApplicationController
  before_action :set_x_search, only: %i[ show edit update destroy ]

  # GET /x_topics/:x_topic_id/x_searches
  def index
    @x_searches = XSearch.all
  end

  # GET /x_searches/1 or /x_searches/1.json
  def show
  end

  # GET /x_searches/new
  def new
    @x_search = XSearch.new
  end

  # GET /x_searches/1/edit
  def edit
  end

  # POST /x_searches or /x_searches.json
  def create
    @x_search = XSearch.new(x_search_params)
    respond_to do |format|
      if @x_search.save
        format.html { redirect_to  @x_search, notice: "X search was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /x_searches/1 or /x_searches/1.json
  def update
    respond_to do |format|
      if @x_search.update(x_search_params)
        format.html { redirect_to @x_search, notice: "X search was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @x_search }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @x_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /x_searches/1 or /x_searches/1.json
  def destroy
    @x_search.destroy!

    respond_to do |format|
      format.html { redirect_to x_searches_path, notice: "X search was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_x_search
      @x_search = XSearch.find(params.expect(:id))
    end

    def x_search_params
      params.expect(x_search: [ :x_topic_id, :start_time, :end_time ])
    end
end

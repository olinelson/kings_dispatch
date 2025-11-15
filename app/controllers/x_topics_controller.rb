class XTopicsController < ApplicationController
  before_action :set_x_topic, only: %i[ show edit update destroy ]

  # GET /x_topics or /x_topics.json
  def index
    @x_topics = XTopic.all
  end

  # GET /x_topics/1 or /x_topics/1.json
  def show
  end

  # GET /x_topics/new
  def new
    @x_topic = XTopic.new
  end

  # GET /x_topics/1/edit
  def edit
  end

  # POST /x_topics or /x_topics.json
  def create
    @x_topic = XTopic.new(x_topic_params)

    respond_to do |format|
      if @x_topic.save
        format.html { redirect_to @x_topic, notice: "X topic was successfully created." }
        format.json { render :show, status: :created, location: @x_topic }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @x_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /x_topics/1 or /x_topics/1.json
  def update
    respond_to do |format|
      if @x_topic.update(x_topic_params)
        format.html { redirect_to @x_topic, notice: "X topic was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @x_topic }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @x_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /x_topics/1 or /x_topics/1.json
  def destroy
    @x_topic.destroy!

    respond_to do |format|
      format.html { redirect_to x_topics_path, notice: "X topic was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_x_topic
      @x_topic = XTopic.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def x_topic_params
      params.expect(x_topic: [ :title, :description, :query ])
    end
end

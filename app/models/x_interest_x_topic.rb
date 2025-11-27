class XInterestXTopic < ApplicationRecord
  belongs_to :x_interest
  belongs_to :x_topic

  after_create_commit :broadcast_topic_to_x_interest
  after_destroy_commit :broadcast_remove_topic_from_x_interest

  private

  def broadcast_topic_to_x_interest
    x_topic.broadcast_append_to x_interest, partial: "x_topics/x_topic", locals: { x_topic: x_topic }, target: "x_topics"
  end

  def broadcast_remove_topic_from_x_interest
    x_topic.broadcast_remove_to x_interest
  end
end

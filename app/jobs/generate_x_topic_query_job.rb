class GenerateXTopicQueryJob < ApplicationJob
  queue_as :default

  def perform(x_topic)
    x_topic.generate_query
  end
end

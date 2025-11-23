class GenerateXTopicsJob < ApplicationJob
  queue_as :default

  def perform(x_interest)
    x_interest.generate_topics
  end
end

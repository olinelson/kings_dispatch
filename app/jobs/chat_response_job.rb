class ChatResponseJob < ApplicationJob
  # Batch configuration: broadcast every N milliseconds or every M chunks, whichever comes first
  BATCH_INTERVAL_MS = 150 # Broadcast at least every 150ms
  MIN_CHUNKS_PER_BATCH = 3 # Or every 3 chunks, whichever comes first

  def perform(chat_id, content)
    chat = Chat.find(chat_id)
    accumulated_content = ""
    chunk_count = 0
    last_broadcast_time = Time.current

    chat.ask(content) do |chunk|
      if chunk.content && !chunk.content.blank?
        message = chat.messages.last
        accumulated_content += chunk.content
        chunk_count += 1

        # Broadcast if we've hit the time threshold or chunk threshold
        time_since_last_broadcast = (Time.current - last_broadcast_time).in_milliseconds.to_i

        if time_since_last_broadcast >= BATCH_INTERVAL_MS || chunk_count >= MIN_CHUNKS_PER_BATCH
          message.broadcast_replace_content(accumulated_content)
          last_broadcast_time = Time.current
          chunk_count = 0
        end
      end
    end

    if accumulated_content.present?
      message = chat.messages.last
      message.broadcast_replace_content(accumulated_content)
    end
  end
end

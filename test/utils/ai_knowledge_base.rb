# frozen_string_literal: true

require('securerandom')

module AiKnowledgeBaseExample
  def self.generate
    StarkInfra::AiKnowledgeBase.new(
      name: "sdk-ruby-#{SecureRandom.hex(6)}",
      root_url: 'https://docs.starkinfra.com',
      is_recursive: false,
      tags: %w[sdk-ruby test]
    )
  end
end

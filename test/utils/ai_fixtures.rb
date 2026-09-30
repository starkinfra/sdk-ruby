# frozen_string_literal: true

require('securerandom')
require_relative('../test_helper.rb')
require_relative('ai_knowledge_base.rb')

module AiFixtures
  @created = { knowledge_base: nil, agent: nil, chat: nil }

  def self.unique_name(prefix)
    "#{prefix}-#{SecureRandom.hex(6)}"
  end

  def self.knowledge_base
    @created[:knowledge_base] ||= StarkInfra::AiKnowledgeBase.create(AiKnowledgeBaseExample.generate)
  end

  def self.agent
    @created[:agent] ||= StarkInfra::AiAgent.create(example_agent(knowledge_base_ids: [knowledge_base.id]))
  end

  def self.chat
    @created[:chat] ||= StarkInfra::AiChat.create(
      StarkInfra::AiChat.new(agent_id: agent.id, title: unique_name('sdk-ruby-chat'), tags: %w[sdk-ruby], context: { 'order_id' => '123' })
    )
  end

  def self.example_agent(knowledge_base_ids: nil)
    StarkInfra::AiAgent.new(
      name: unique_name('sdk-ruby-agent'),
      model: 'bender-1.0',
      system_prompt: 'Answer in one short sentence.',
      knowledge_base_ids: knowledge_base_ids,
      metadata_schema: { 'order_id' => { 'type' => 'string', 'description' => 'Order the customer mentions' } }
    )
  end

  def self.eventually(attempts: 30, delay: 2)
    result = nil
    attempts.times do
      result = yield
      return result if result

      sleep(delay)
    end
    result
  end

  def self.speech_audio
    finished = StarkInfra::AiSpeech.query(limit: 100).find { |speech| speech.status == 'success' }
    return nil if finished.nil?

    StarkInfra::AiSpeech.get(finished.id).audio
  end

  def self.cleanup
    [[:chat, StarkInfra::AiChat], [:agent, StarkInfra::AiAgent], [:knowledge_base, StarkInfra::AiKnowledgeBase]].each do |key, resource|
      entity = @created[key]
      next if entity.nil?

      resource.delete(ids: [entity.id])
    end
  end
end

Minitest.after_run { AiFixtures.cleanup }

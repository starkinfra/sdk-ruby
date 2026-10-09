# frozen_string_literal: true

require('json')
require('net/http')
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

class FakeHttpResponse
  attr_reader :code, :body

  def initialize(body)
    @code = '200'
    @body = body.to_json
  end
end

def with_http_answers(*bodies)
  requests = []
  original = Net::HTTP.method(:start)
  Net::HTTP.define_singleton_method(:start) do |*_args, **_options, &block|
    connection = Object.new
    connection.define_singleton_method(:request) do |request|
      requests << request
      FakeHttpResponse.new(bodies[[requests.length, bodies.length].min - 1])
    end
    block.call(connection)
  end
  yield requests
ensure
  Net::HTTP.define_singleton_method(:start, original)
end

def with_http_answer(body, &block)
  with_http_answers(body, &block)
end

def query_of(request)
  URI.decode_www_form(URI(request.path).query.to_s).to_h
end

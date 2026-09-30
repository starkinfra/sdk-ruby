# frozen_string_literal: true

require('json')
require('net/http')
require('securerandom')
require_relative('../test_helper.rb')
require_relative('ai_knowledge_base.rb')

# Voices, speeches and transcripts cannot be deleted, so they are only read live and created at the HTTP boundary.
# Agents, chats and knowledge bases can be deleted: one of each is shared by every test in the process
# and removed when it ends. They are created on first use, so loading a file or running only the boundary
# tests touches no credential.
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
    @created[:chat] ||= StarkInfra::AiChat.create(StarkInfra::AiChat.new(agent_id: agent.id, title: unique_name('sdk-ruby-chat')))
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

  def self.cleanup
    [[:chat, StarkInfra::AiChat], [:agent, StarkInfra::AiAgent], [:knowledge_base, StarkInfra::AiKnowledgeBase]].each do |key, resource|
      entity = @created[key]
      next if entity.nil?

      begin
        resource.delete(ids: [entity.id])
      rescue StarkCore::Error::InternalServerError
        warn("#{key} #{entity.id} was not deleted: the API answered 500")
      end
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

# Replaces only Net::HTTP.start; each call answers with the next body, the last one repeating.
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

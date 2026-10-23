# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiAgent, '#ai-agent#') do
  let(:agent) { AiFixtures.agent }

  it 'create returns the agent with the schema keys in camelCase' do
    expect(agent.id).wont_be_nil
    expect(agent.model).must_equal('bender-1.0')
    expect(agent.knowledge_base_ids).must_equal([AiFixtures.knowledge_base.id])
    expect(agent.metadata_schema.keys).must_equal(%w[orderId])
    expect(agent.created).must_be_kind_of(DateTime)
  end

  it 'get and expand knowledge bases' do
    plain = StarkInfra::AiAgent.get(agent.id)
    expect(plain.id).must_equal(agent.id)
    expect(plain.knowledge_bases).must_be_nil
    expanded = StarkInfra::AiAgent.get(agent.id, expand: %w[knowledgeBases])
    expect(expanded.knowledge_bases.map(&:id)).must_equal([AiFixtures.knowledge_base.id])
    expect(expanded.knowledge_bases[0]).must_be_kind_of(StarkInfra::AiKnowledgeBase)
  end

  it 'query and page list the agent' do
    expect(AiFixtures.eventually { StarkInfra::AiAgent.query.find { |entity| entity.id == agent.id } }).wont_be_nil
    page_entities, = StarkInfra::AiAgent.page(limit: 1)
    expect(page_entities.length).must_equal(1)
  end

  it 'query with expand brings the knowledge bases' do
    found = AiFixtures.eventually { StarkInfra::AiAgent.query(expand: %w[knowledgeBases]).find { |entity| entity.id == agent.id } }
    expect(found.knowledge_bases.map(&:id)).must_equal([AiFixtures.knowledge_base.id])
  end

  it 'update changes the name and the API keeps what is not sent' do
    original = StarkInfra::AiAgent.get(agent.id)
    renamed = StarkInfra::AiAgent.update(agent.id, name: 'renamed-by-sdk')
    expect(renamed.name).must_equal('renamed-by-sdk')
    expect(renamed.knowledge_base_ids).must_equal([AiFixtures.knowledge_base.id])
    expect(renamed.metadata_schema.keys).must_equal(%w[orderId])
  ensure
    StarkInfra::AiAgent.update(agent.id, name: original.name) unless original.nil?
  end

  it 'update with an empty list clears the knowledge bases' do
    short_lived = StarkInfra::AiAgent.create(AiFixtures.example_agent(knowledge_base_ids: [AiFixtures.knowledge_base.id]))
    cleared = StarkInfra::AiAgent.update(short_lived.id, knowledge_base_ids: [])
    expect(cleared.knowledge_base_ids).must_equal([])
  ensure
    StarkInfra::AiAgent.delete(ids: [short_lived.id]) unless short_lived.nil?
  end

  it 'delete returns the deleted agents' do
    short_lived = StarkInfra::AiAgent.create(AiFixtures.example_agent)
    deleted = StarkInfra::AiAgent.delete(ids: [short_lived.id])
    expect(deleted.map(&:id)).must_equal([short_lived.id])
  end

  it 'create with invalid model raises input errors' do
    invalid = StarkInfra::AiAgent.new(name: 'invalid', model: 'gpt')
    expect { StarkInfra::AiAgent.create(invalid) }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'get unknown id raises input errors' do
    expect { StarkInfra::AiAgent.get('0000000000000000') }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'limit above the maximum raises the API error' do
    expect { StarkInfra::AiAgent.page(limit: 101) }.must_raise(StarkCore::Error::InputErrors)
  end
end

# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiAgent, '#ai-agent#') do
  let(:agent) { AiFixtures.agent }

  it 'create returns the agent with the schema keys as written' do
    expect(agent.id).wont_be_nil
    expect(agent.model).must_equal('bender-1.0')
    expect(agent.knowledge_base_ids).must_equal([AiFixtures.knowledge_base.id])
    expect(agent.metadata_schema.keys).must_equal(%w[order_id])
    expect(agent.created).must_be_kind_of(DateTime)
  end

  it 'get and expand knowledge bases' do
    plain = StarkInfra::AiAgent.get(agent.id)
    expect(plain.id).must_equal(agent.id)
    expect(plain.knowledge_bases).must_be_nil
    expanded = StarkInfra::AiAgent.get(agent.id, expand: %w[knowledge_bases])
    expect(expanded.knowledge_bases.map(&:id)).must_equal([AiFixtures.knowledge_base.id])
    expect(expanded.knowledge_bases[0]).must_be_kind_of(StarkInfra::AiKnowledgeBase)
  end

  it 'query with fields' do
    found = StarkInfra::AiAgent.query(fields: %w[id name]).find { |entity| entity.id == agent.id }
    expect(found.name).must_equal(agent.name)
    expect(found.model).must_be_nil
  end

  it 'update keeps the knowledge bases it was not asked to change' do
    original = StarkInfra::AiAgent.get(agent.id)
    renamed = StarkInfra::AiAgent.update(agent.id, name: 'renamed-by-sdk')
    expect(renamed.name).must_equal('renamed-by-sdk')
    expect(renamed.knowledge_base_ids).must_equal([AiFixtures.knowledge_base.id])
    expect(renamed.metadata_schema.keys).must_equal(%w[order_id])
  ensure
    StarkInfra::AiAgent.update(agent.id, name: original.name)
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
end

describe(StarkInfra::AiAgent, '#ai-agent at the http boundary#') do
  let(:agent_json) do
    {
      'id' => '5740688905863168', 'name' => 'Support assistant', 'model' => 'bender-1.0',
      'systemPrompt' => 'Answer in one short sentence.', 'voiceId' => '', 'knowledgeBaseIds' => %w[5083538508480512],
      'metadataSchema' => { 'order_id' => { 'type' => 'string' }, 'isUrgent' => { 'type' => 'boolean' } },
      'created' => '2026-09-30T15:42:56.879325+00:00', 'updated' => '2026-09-30T15:42:56.879334+00:00'
    }
  end

  it 'create sends only the creatable fields and leaves the schema keys alone' do
    schema = { 'order_id' => { 'type' => 'string' }, 'isUrgent' => { 'type' => 'boolean' } }
    returned = StarkInfra::AiAgent.new(
      name: 'Support assistant', model: 'bender-1.0', system_prompt: 'Be brief.', voice_id: '5632499082330112',
      knowledge_base_ids: %w[5083538508480512], metadata_schema: schema, id: '5740688905863168',
      created: '2026-09-30T15:42:56+00:00', updated: '2026-09-30T15:42:56+00:00'
    )
    created = nil
    with_http_answer('agent' => agent_json) do |requests|
      created = StarkInfra::AiAgent.create(returned)
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-agent')
      expect(JSON.parse(requests[0].body)).must_equal(
        'name' => 'Support assistant', 'model' => 'bender-1.0', 'systemPrompt' => 'Be brief.',
        'voiceId' => '5632499082330112', 'knowledgeBaseIds' => %w[5083538508480512], 'metadataSchema' => schema
      )
    end
    expect(created.metadata_schema).must_equal(schema)
    expect(created.knowledge_base_ids).must_equal(%w[5083538508480512])
  end

  it 'an agent fetched without a voice can be created again' do
    with_http_answer('agent' => agent_json) do |requests|
      StarkInfra::AiAgent.create(StarkInfra::AiAgent.new(name: 'a', model: 'bender-1.0', voice_id: ''))
      expect(JSON.parse(requests[0].body)).must_equal('name' => 'a', 'model' => 'bender-1.0')
    end
  end

  it 'create keeps false and empty lists' do
    agent = StarkInfra::AiAgent.new(name: 'a', model: 'prime-1.0', knowledge_base_ids: [], metadata_schema: { 'flag_one' => { 'type' => 'boolean' } })
    with_http_answer('agent' => agent_json) do |requests|
      StarkInfra::AiAgent.create(agent)
      expect(JSON.parse(requests[0].body)).must_equal(
        'name' => 'a', 'model' => 'prime-1.0', 'knowledgeBaseIds' => [], 'metadataSchema' => { 'flag_one' => { 'type' => 'boolean' } }
      )
    end
  end

  it 'get with expand parses the knowledge bases' do
    expanded = agent_json.merge(
      'knowledgeBases' => [{ 'id' => '5083538508480512', 'name' => 'Docs', 'rootUrl' => 'https://docs.starkinfra.com', 'status' => 'success' }]
    )
    with_http_answer('agent' => expanded) do |requests|
      agent = StarkInfra::AiAgent.get('5740688905863168', fields: %w[id knowledge_bases], expand: %w[knowledge_bases])
      expect(requests[0].path).must_equal('/v2/ai-agent/5740688905863168?fields=id%2CknowledgeBases&expand=knowledgeBases')
      expect(agent.knowledge_bases[0]).must_be_kind_of(StarkInfra::AiKnowledgeBase)
      expect(agent.knowledge_bases[0].root_url).must_equal('https://docs.starkinfra.com')
    end
  end

  it 'update without knowledge base ids reads them first and sends them back' do
    with_http_answers(
      { 'agent' => { 'id' => '5740688905863168', 'knowledgeBaseIds' => %w[5083538508480512] } },
      { 'agent' => agent_json }
    ) do |requests|
      StarkInfra::AiAgent.update('5740688905863168', name: 'Renamed')
      expect(requests.length).must_equal(2)
      expect(requests[0].method).must_equal('GET')
      expect(requests[0].path).must_equal('/v2/ai-agent/5740688905863168?fields=knowledgeBaseIds')
      expect(requests[1].method).must_equal('PATCH')
      expect(JSON.parse(requests[1].body)).must_equal('name' => 'Renamed', 'knowledgeBaseIds' => %w[5083538508480512])
    end
  end

  it 'update with knowledge base ids does not read the agent' do
    with_http_answer('agent' => agent_json) do |requests|
      StarkInfra::AiAgent.update('5740688905863168', knowledge_base_ids: [])
      expect(requests.length).must_equal(1)
      expect(requests[0].method).must_equal('PATCH')
      expect(JSON.parse(requests[0].body)).must_equal('knowledgeBaseIds' => [])
    end
  end

  it 'update leaves the schema keys alone' do
    schema = { 'order_id' => { 'type' => 'string' } }
    with_http_answer('agent' => agent_json) do |requests|
      StarkInfra::AiAgent.update('5740688905863168', knowledge_base_ids: %w[1], metadata_schema: schema)
      expect(JSON.parse(requests[0].body)['metadataSchema']).must_equal(schema)
    end
  end

  it 'delete sends ids in the query string without a body' do
    deleted = nil
    with_http_answer('agents' => [agent_json]) do |requests|
      deleted = StarkInfra::AiAgent.delete(ids: %w[5740688905863168 5740688905863169])
      expect(requests[0].method).must_equal('DELETE')
      expect(requests[0].path).must_equal('/v2/ai-agent?ids=5740688905863168%2C5740688905863169')
      expect(requests[0].body.to_s).must_equal('')
    end
    expect(deleted.map(&:id)).must_equal(%w[5740688905863168])
  end
end

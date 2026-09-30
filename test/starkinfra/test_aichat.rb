# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiChat, '#ai-chat#') do
  let(:chat) { AiFixtures.chat }

  it 'create returns the chat' do
    expect(chat.id).wont_be_nil
    expect(chat.agent_id).must_equal(AiFixtures.agent.id)
    expect(chat.title).must_match(/\Asdk-ruby-chat/)
    expect(chat.updated).must_be_kind_of(DateTime)
  end

  it 'get and expand the agent name' do
    plain = StarkInfra::AiChat.get(chat.id)
    expect(plain.agent_name).must_be_nil
    expanded = StarkInfra::AiChat.get(chat.id, expand: %w[agent_name])
    expect(expanded.agent_name).must_equal(AiFixtures.agent.name)
  end

  it 'query with fields' do
    found = StarkInfra::AiChat.query(fields: %w[id title]).find { |entity| entity.id == chat.id }
    expect(found.title).must_equal(chat.title)
    expect(found.agent_id).must_be_nil
  end

  it 'update changes the title only' do
    renamed = StarkInfra::AiChat.update(chat.id, title: 'renamed-by-sdk')
    expect(renamed.title).must_equal('renamed-by-sdk')
    expect(renamed.agent_id).must_equal(chat.agent_id)
  ensure
    StarkInfra::AiChat.update(chat.id, title: chat.title)
  end

  it 'delete returns the deleted chats' do
    short_lived = StarkInfra::AiChat.create(StarkInfra::AiChat.new(agent_id: AiFixtures.agent.id))
    deleted = StarkInfra::AiChat.delete(ids: [short_lived.id])
    expect(deleted.map(&:id)).must_equal([short_lived.id])
  end

  it 'create with unknown agent raises input errors' do
    expect { StarkInfra::AiChat.create(StarkInfra::AiChat.new(agent_id: '0000000000000000')) }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'get unknown id raises input errors' do
    expect { StarkInfra::AiChat.get('0000000000000000') }.must_raise(StarkCore::Error::InputErrors)
  end
end

describe(StarkInfra::AiChat, '#ai-chat at the http boundary#') do
  let(:chat_json) do
    { 'id' => '5632499082330112', 'agentId' => '5740688905863168', 'title' => 'Greeting', 'updated' => '2026-10-01T14:28:02.652375+00:00' }
  end

  it 'create sends only the creatable fields' do
    returned = StarkInfra::AiChat.new(
      agent_id: '5740688905863168', title: 'Greeting', id: '5632499082330112', agent_name: 'Support',
      updated: '2026-10-01T14:28:02+00:00'
    )
    with_http_answer('chat' => chat_json) do |requests|
      StarkInfra::AiChat.create(returned)
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-chat')
      expect(JSON.parse(requests[0].body)).must_equal('agentId' => '5740688905863168', 'title' => 'Greeting')
    end
  end

  it 'update sends the given fields and an empty object when none is given' do
    with_http_answers({ 'chat' => chat_json }) do |requests|
      StarkInfra::AiChat.update('5632499082330112', title: 'Greeting', agent_id: '5740688905863168')
      StarkInfra::AiChat.update('5632499082330112')
      expect(requests[0].method).must_equal('PATCH')
      expect(requests[0].path).must_equal('/v2/ai-chat/5632499082330112')
      expect(JSON.parse(requests[0].body)).must_equal('title' => 'Greeting', 'agentId' => '5740688905863168')
      expect(requests[1].body).must_equal('{}')
    end
  end

  it 'query sends fields and expand in camel case' do
    with_http_answer('chats' => [chat_json]) do |requests|
      found = StarkInfra::AiChat.query(fields: %w[id agent_name], expand: %w[agent_name]).to_a
      expect(requests[0].path).must_equal('/v2/ai-chat?fields=id%2CagentName&expand=agentName')
      expect(found.map(&:id)).must_equal(%w[5632499082330112])
    end
  end

  it 'delete sends ids in the query string without a body' do
    deleted = nil
    with_http_answer('chats' => [chat_json]) do |requests|
      deleted = StarkInfra::AiChat.delete(ids: %w[5632499082330112 5632499082330113])
      expect(requests[0].method).must_equal('DELETE')
      expect(requests[0].path).must_equal('/v2/ai-chat?ids=5632499082330112%2C5632499082330113')
      expect(requests[0].body.to_s).must_equal('')
    end
    expect(deleted.map(&:id)).must_equal(%w[5632499082330112])
  end
end

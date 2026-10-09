# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiChat, '#ai-chat#') do
  let(:chat) { AiFixtures.chat }

  it 'create returns the chat with tags and context' do
    expect(chat.id).wont_be_nil
    expect(chat.agent_id).must_equal(AiFixtures.agent.id)
    expect(chat.title).must_match(/\Asdk-ruby-chat/)
    expect(chat.tags).must_equal(%w[sdk-ruby])
    expect(chat.context).must_equal('order_id' => '123')
    expect(chat.updated).must_be_kind_of(DateTime)
  end

  it 'create without optionals returns empty tags and context' do
    short_lived = StarkInfra::AiChat.create(StarkInfra::AiChat.new(agent_id: AiFixtures.agent.id))
    expect(short_lived.tags).must_equal([])
    expect(short_lived.context).must_equal({})
  ensure
    StarkInfra::AiChat.delete(ids: [short_lived.id]) unless short_lived.nil?
  end

  it 'get and expand the agent name' do
    plain = StarkInfra::AiChat.get(chat.id)
    expect(plain.agent_name).must_be_nil
    expanded = StarkInfra::AiChat.get(chat.id, expand: %w[agent_name])
    expect(expanded.agent_name).must_equal(AiFixtures.agent.name)
  end

  it 'query and page filter by tags' do
    expect(AiFixtures.eventually { StarkInfra::AiChat.query(tags: %w[sdk-ruby]).find { |entity| entity.id == chat.id } }).wont_be_nil
    page_entities, = StarkInfra::AiChat.page(limit: 1, tags: %w[sdk-ruby])
    expect(page_entities.length).must_equal(1)
    expect(page_entities[0].tags).must_include('sdk-ruby')
    expect(StarkInfra::AiChat.query(tags: %w[no-chat-has-this-tag]).to_a).must_equal([])
  end

  it 'query with expand brings the agent name' do
    found = AiFixtures.eventually do
      StarkInfra::AiChat.query(expand: %w[agent_name], tags: %w[sdk-ruby]).find { |entity| entity.id == chat.id }
    end
    expect(found).wont_be_nil
    expect(found.agent_name).must_equal(AiFixtures.agent.name)
  end

  it 'update changes the title and tags, and absent values change nothing' do
    renamed = StarkInfra::AiChat.update(chat.id, title: 'renamed-by-sdk', tags: %w[sdk-ruby renamed])
    expect(renamed.title).must_equal('renamed-by-sdk')
    expect(renamed.tags).must_equal(%w[sdk-ruby renamed])
    expect(renamed.agent_id).must_equal(chat.agent_id)
    expect(renamed.context).must_equal('order_id' => '123')
  ensure
    StarkInfra::AiChat.update(chat.id, title: chat.title, tags: chat.tags)
  end

  it 'update with empty values clears tags and context' do
    short_lived = StarkInfra::AiChat.create(
      StarkInfra::AiChat.new(agent_id: AiFixtures.agent.id, tags: %w[a], context: { 'customerId' => '1' })
    )
    expect(short_lived.context).must_equal('customerId' => '1')
    cleared = StarkInfra::AiChat.update(short_lived.id, tags: [], context: {})
    expect(cleared.tags).must_equal([])
    expect(cleared.context).must_equal({})
  ensure
    StarkInfra::AiChat.delete(ids: [short_lived.id]) unless short_lived.nil?
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

  it 'limit above the maximum raises the API error' do
    expect { StarkInfra::AiChat.page(limit: 101) }.must_raise(StarkCore::Error::InputErrors)
  end
end

describe(StarkInfra::AiChat, '#ai-chat at the http boundary#') do
  let(:chat_json) do
    {
      'id' => '5632499082330112', 'agentId' => '5740688905863168', 'title' => 'Greeting', 'tags' => %w[vip],
      'context' => { 'customerId' => '42' }, 'updated' => '2026-10-01T14:28:02.652375+00:00'
    }
  end

  it 'create sends the four keys and leaves the context keys alone' do
    chat = StarkInfra::AiChat.new(
      agent_id: '5740688905863168', title: 'Greeting', tags: %w[vip], context: { 'customerId' => '42', 'order_id' => '1' }
    )
    created = nil
    with_http_answer('chat' => chat_json) do |requests|
      created = StarkInfra::AiChat.create(chat)
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-chat')
      expect(JSON.parse(requests[0].body)).must_equal(
        'agentId' => '5740688905863168', 'title' => 'Greeting', 'tags' => %w[vip],
        'context' => { 'customerId' => '42', 'order_id' => '1' }
      )
    end
    expect(created.tags).must_equal(%w[vip])
    expect(created.context).must_equal('customerId' => '42')
  end

  it 'create sends absent optionals as null' do
    with_http_answer('chat' => chat_json) do |requests|
      StarkInfra::AiChat.create(StarkInfra::AiChat.new(agent_id: '5740688905863168'))
      expect(JSON.parse(requests[0].body)).must_equal('agentId' => '5740688905863168', 'title' => nil, 'tags' => nil, 'context' => nil)
    end
  end

  it 'update names every key and sends absent ones as null' do
    with_http_answers('chat' => chat_json) do |requests|
      StarkInfra::AiChat.update('5632499082330112', title: 'Greeting', tags: [], context: { 'customerId' => '42' })
      StarkInfra::AiChat.update('5632499082330112')
      expect(requests[0].method).must_equal('PATCH')
      expect(requests[0].path).must_equal('/v2/ai-chat/5632499082330112')
      expect(JSON.parse(requests[0].body)).must_equal(
        'title' => 'Greeting', 'agentId' => nil, 'tags' => [], 'context' => { 'customerId' => '42' }
      )
      expect(JSON.parse(requests[1].body)).must_equal('title' => nil, 'agentId' => nil, 'tags' => nil, 'context' => nil)
    end
  end

  it 'get sends expand in camel case' do
    with_http_answer('chat' => chat_json) do |requests|
      StarkInfra::AiChat.get('5632499082330112', expand: %w[agent_name])
      expect(requests[0].path).must_equal('/v2/ai-chat/5632499082330112?expand=agentName')
    end
  end

  it 'page sends tags comma-separated, returns the items and the cursor' do
    with_http_answer('cursor' => 'next-page', 'chats' => [chat_json]) do |requests|
      items, cursor = StarkInfra::AiChat.page(cursor: 'current-page', limit: 1, expand: %w[agent_name], tags: %w[vip gold])
      expect(query_of(requests[0])).must_equal(
        'cursor' => 'current-page', 'limit' => '1', 'expand' => 'agentName', 'tags' => 'vip,gold'
      )
      expect(items.map(&:id)).must_equal(%w[5632499082330112])
      expect(cursor).must_equal('next-page')
    end
  end

  it 'page returns a null cursor on the last page' do
    with_http_answer('cursor' => nil, 'chats' => [chat_json]) do
      _, cursor = StarkInfra::AiChat.page
      expect(cursor).must_be_nil
    end
  end

  it 'query sends tags and follows the cursor' do
    with_http_answers({ 'cursor' => 'next-page', 'chats' => [chat_json] }, { 'cursor' => nil, 'chats' => [chat_json] }) do |requests|
      expect(StarkInfra::AiChat.query(tags: %w[vip gold]).to_a.length).must_equal(2)
      expect(query_of(requests[0])).must_equal('tags' => 'vip,gold')
      expect(query_of(requests[1])).must_equal('tags' => 'vip,gold', 'cursor' => 'next-page')
    end
  end

  it 'create sends non-ASCII context values as UTF-8 that round-trips' do
    context = { 'note' => 'olá 日本 "q"' }
    with_http_answer('chat' => chat_json) do |requests|
      StarkInfra::AiChat.create(StarkInfra::AiChat.new(agent_id: '5740688905863168', context: context))
      body = requests[0].body.dup.force_encoding(Encoding::UTF_8)
      expect(body).must_include('olá 日本 \\"q\\"')
      expect(JSON.parse(body)['context']).must_equal(context)
    end
  end

  it 'page sends tags with non-ASCII and spaces percent-encoded' do
    with_http_answer('cursor' => nil, 'chats' => [chat_json]) do |requests|
      StarkInfra::AiChat.page(tags: ['café', 'a b'])
      expect(requests[0].path).must_equal('/v2/ai-chat?tags=caf%C3%A9%2Ca%20b')
      expect(query_of(requests[0])['tags']).must_equal('café,a b')
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

# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiChat, '#ai-chat#') do
  let(:chat) { AiFixtures.chat }

  it 'create returns the chat with tags and context' do
    expect(chat.id).wont_be_nil
    expect(chat.agent_id).must_equal(AiFixtures.agent.id)
    expect(chat.title).must_match(/\Asdk-ruby-chat/)
    expect(chat.tags).must_equal(%w[sdk-ruby])
    expect(chat.context).must_equal('orderId' => '123')
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
    expanded = StarkInfra::AiChat.get(chat.id, expand: %w[agentName])
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
      StarkInfra::AiChat.query(expand: %w[agentName], tags: %w[sdk-ruby]).find { |entity| entity.id == chat.id }
    end
    expect(found).wont_be_nil
    expect(found.agent_name).must_equal(AiFixtures.agent.name)
  end

  it 'update changes the title and tags, and absent values change nothing' do
    renamed = StarkInfra::AiChat.update(chat.id, title: 'renamed-by-sdk', tags: %w[sdk-ruby renamed])
    expect(renamed.title).must_equal('renamed-by-sdk')
    expect(renamed.tags).must_equal(%w[sdk-ruby renamed])
    expect(renamed.agent_id).must_equal(chat.agent_id)
    expect(renamed.context).must_equal('orderId' => '123')
  ensure
    StarkInfra::AiChat.update(chat.id, title: chat.title, tags: chat.tags)
  end

  it 'update with empty values clears tags and context' do
    short_lived = StarkInfra::AiChat.create(
      StarkInfra::AiChat.new(agent_id: AiFixtures.agent.id, tags: %w[a], context: { 'customer_id' => '1' })
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

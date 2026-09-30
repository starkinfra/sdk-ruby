# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

describe(StarkInfra::AiKnowledgeBase, '#ai-knowledge-base#') do
  let(:knowledge_base) { AiFixtures.knowledge_base }

  it 'create returns the knowledge base' do
    expect(knowledge_base.id).wont_be_nil
    expect(%w[processing success failed]).must_include(knowledge_base.status)
    expect(knowledge_base.root_url).must_equal('https://docs.starkinfra.com')
    expect(knowledge_base.is_recursive).must_equal(false)
    expect(knowledge_base.tags).must_equal(%w[sdk-ruby test])
    expect(knowledge_base.created).must_be_kind_of(DateTime)
    expect(knowledge_base.updated).must_be_kind_of(DateTime)
  end

  it 'get' do
    fetched = StarkInfra::AiKnowledgeBase.get(knowledge_base.id)
    expect(fetched.id).must_equal(knowledge_base.id)
    expect(fetched.name).must_equal(knowledge_base.name)
  end

  it 'query filters by ids' do
    found = StarkInfra::AiKnowledgeBase.query(ids: [knowledge_base.id]).to_a
    expect(found.map(&:id)).must_equal([knowledge_base.id])
  end

  it 'query filters by name and status' do
    current_status = StarkInfra::AiKnowledgeBase.get(knowledge_base.id).status
    found = StarkInfra::AiKnowledgeBase.query(name: knowledge_base.name, status: current_status).to_a
    expect(found.map(&:id)).must_include(knowledge_base.id)
  end

  it 'query without match is empty' do
    found = StarkInfra::AiKnowledgeBase.query(name: 'no-knowledge-base-has-this-name').to_a
    expect(found).must_equal([])
  end

  it 'update changes name and tags only' do
    updated = StarkInfra::AiKnowledgeBase.update(knowledge_base.id, name: 'renamed-by-sdk', tags: %w[renamed])
    expect(updated.name).must_equal('renamed-by-sdk')
    expect(updated.tags).must_equal(%w[renamed])
    expect(updated.root_url).must_equal(knowledge_base.root_url)
  ensure
    StarkInfra::AiKnowledgeBase.update(knowledge_base.id, name: knowledge_base.name, tags: knowledge_base.tags)
  end

  it 'create with invalid root url raises input errors' do
    invalid = StarkInfra::AiKnowledgeBase.new(name: 'invalid', root_url: 'not-a-url')
    expect { StarkInfra::AiKnowledgeBase.create(invalid) }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'get unknown id raises input errors' do
    expect { StarkInfra::AiKnowledgeBase.get('0000000000000000') }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'page returns the base and a cursor that is null on the last page' do
    entities, cursor = StarkInfra::AiKnowledgeBase.page(ids: [knowledge_base.id], limit: 1)
    expect(entities.map(&:id)).must_equal([knowledge_base.id])
    expect(cursor.nil? || cursor.is_a?(String)).must_equal(true)
  end

  it 'query with limit stops at the limit' do
    expect(StarkInfra::AiKnowledgeBase.query(limit: 1).to_a.length).must_equal(1)
  end

  it 'limit above the maximum raises the API error' do
    expect { StarkInfra::AiKnowledgeBase.page(limit: 101) }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'limit zero raises the API error' do
    expect { StarkInfra::AiKnowledgeBase.query(limit: 0).to_a }.must_raise(StarkCore::Error::InputErrors)
  end
end

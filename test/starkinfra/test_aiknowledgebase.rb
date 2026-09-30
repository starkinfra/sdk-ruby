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

describe(StarkInfra::AiKnowledgeBase, '#ai-knowledge-base at the http boundary#') do
  it 'hosts groups pages by host with snake case keys' do
    body = {
      'hosts' => {
        'docs.starkinfra.com' => [{
          'originalUrl' => 'https://docs.starkinfra.com/get-started',
          'status' => 'success',
          'storageUrl' => 'https://storage.googleapis.com/ai-knowledge/6767676767676767/get-started.md'
        }]
      }
    }
    hosts = nil
    with_http_answer(body) do |requests|
      hosts = StarkInfra::AiKnowledgeBase.hosts('6767676767676767')
      expect(requests.length).must_equal(1)
      expect(requests[0].method).must_equal('GET')
      expect(requests[0].path).must_equal('/v2/ai-knowledge-base/6767676767676767/hosts')
    end
    expect(hosts).must_equal(
      'docs.starkinfra.com' => [{
        'original_url' => 'https://docs.starkinfra.com/get-started',
        'status' => 'success',
        'storage_url' => 'https://storage.googleapis.com/ai-knowledge/6767676767676767/get-started.md'
      }]
    )
  end

  it 'delete sends ids in the query string without a body and returns the deleted objects' do
    body = {
      'knowledgeBases' => [{
        'id' => '6767676767676767',
        'name' => 'Public Documentation',
        'rootUrl' => 'https://docs.starkinfra.com',
        'isRecursive' => true,
        'status' => 'success',
        'tags' => %w[support],
        'created' => '2022-01-01T00:00:00.000000+00:00',
        'updated' => '2022-01-02T00:00:00.000000+00:00'
      }]
    }
    deleted = nil
    with_http_answer(body) do |requests|
      deleted = StarkInfra::AiKnowledgeBase.delete(ids: %w[6767676767676767 6767676767676768])
      expect(requests.length).must_equal(1)
      expect(requests[0].method).must_equal('DELETE')
      expect(requests[0].path).must_equal('/v2/ai-knowledge-base?ids=6767676767676767%2C6767676767676768')
      expect(requests[0].body.to_s).must_equal('')
    end
    expect(deleted.map(&:id)).must_equal(%w[6767676767676767])
    expect(deleted[0].name).must_equal('Public Documentation')
  end

  it 'create sends the creatable fields and drops absent ones' do
    returned = StarkInfra::AiKnowledgeBase.new(
      name: 'Public Documentation',
      root_url: 'https://docs.starkinfra.com',
      is_recursive: false,
      tags: %w[support]
    )
    body = { 'knowledgeBase' => { 'id' => '6767676767676768', 'name' => 'Public Documentation', 'rootUrl' => 'https://docs.starkinfra.com' } }
    with_http_answer(body) do |requests|
      StarkInfra::AiKnowledgeBase.create(returned)
      expect(requests[0].method).must_equal('POST')
      expect(JSON.parse(requests[0].body)).must_equal(
        'name' => 'Public Documentation',
        'rootUrl' => 'https://docs.starkinfra.com',
        'isRecursive' => false,
        'tags' => %w[support]
      )
    end
  end

  it 'update keeps false and drops absent fields' do
    body = { 'knowledgeBase' => { 'id' => '6767676767676767', 'name' => 'x', 'rootUrl' => 'https://docs.starkinfra.com' } }
    with_http_answer(body) do |requests|
      StarkInfra::AiKnowledgeBase.update('6767676767676767', is_recursive: false)
      expect(requests[0].method).must_equal('PATCH')
      expect(JSON.parse(requests[0].body)).must_equal('isRecursive' => false)
    end
  end

  let(:base_json) { { 'id' => '6767676767676767', 'name' => 'Docs', 'rootUrl' => 'https://docs.starkinfra.com', 'status' => 'success' } }

  it 'page sends ids comma-separated and the filters, and returns the items and the cursor' do
    with_http_answer('cursor' => 'next-page', 'knowledgeBases' => [base_json]) do |requests|
      items, cursor = StarkInfra::AiKnowledgeBase.page(
        cursor: 'current-page', limit: 5, ids: %w[1 2], name: 'docs', status: 'success'
      )
      expect(requests[0].path).must_match(%r{\A/v2/ai-knowledge-base\?})
      expect(query_of(requests[0])).must_equal(
        'cursor' => 'current-page', 'limit' => '5', 'ids' => '1,2', 'name' => 'docs', 'status' => 'success'
      )
      expect(items.map(&:id)).must_equal(%w[6767676767676767])
      expect(cursor).must_equal('next-page')
    end
  end

  it 'page returns a null cursor on the last page' do
    with_http_answer('cursor' => nil, 'knowledgeBases' => [base_json]) do |requests|
      _, cursor = StarkInfra::AiKnowledgeBase.page
      expect(cursor).must_be_nil
      expect(requests[0].path).must_equal('/v2/ai-knowledge-base')
    end
  end

  it 'query follows the cursor through an empty page' do
    pages = [
      { 'cursor' => 'second', 'knowledgeBases' => [] },
      { 'cursor' => 'third', 'knowledgeBases' => [base_json] },
      { 'cursor' => nil, 'knowledgeBases' => [base_json.merge('id' => '6767676767676768')] }
    ]
    with_http_answers(*pages) do |requests|
      found = StarkInfra::AiKnowledgeBase.query(name: 'docs').to_a
      expect(found.map(&:id)).must_equal(%w[6767676767676767 6767676767676768])
      expect(requests.length).must_equal(3)
      expect(query_of(requests[1])).must_equal('name' => 'docs', 'cursor' => 'second')
      expect(query_of(requests[2])).must_equal('name' => 'docs', 'cursor' => 'third')
    end
  end

  it 'query honours the limit across pages' do
    hundred = Array.new(100) { |index| base_json.merge('id' => index.to_s) }
    fifty = Array.new(50) { |index| base_json.merge('id' => "b#{index}") }
    with_http_answers({ 'cursor' => 'second', 'knowledgeBases' => hundred }, { 'cursor' => 'third', 'knowledgeBases' => fifty }) do |requests|
      expect(StarkInfra::AiKnowledgeBase.query(limit: 150).to_a.length).must_equal(150)
      expect(requests.length).must_equal(2)
      expect(query_of(requests[0])).must_equal('limit' => '100')
      expect(query_of(requests[1])).must_equal('limit' => '50', 'cursor' => 'second')
    end
  end

  it 'query without limit asks no limit' do
    with_http_answer('cursor' => nil, 'knowledgeBases' => [base_json]) do |requests|
      StarkInfra::AiKnowledgeBase.query.to_a
      expect(requests[0].path).must_equal('/v2/ai-knowledge-base')
    end
  end

  it 'get reads the knowledgeBase key' do
    with_http_answer('knowledgeBase' => base_json) do |requests|
      expect(StarkInfra::AiKnowledgeBase.get('6767676767676767').name).must_equal('Docs')
      expect(requests[0].path).must_equal('/v2/ai-knowledge-base/6767676767676767')
    end
  end
end

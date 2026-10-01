# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

# One knowledge base per run: the sandbox cannot delete them, so the whole file shares a single one.
# It is created on first use, so loading the file or running only the boundary tests touches no credential.
module SharedKnowledgeBase
  def self.get
    @knowledge_base ||= StarkInfra::AiKnowledgeBase.create(AiKnowledgeBaseExample.generate)
  end

  def self.created?
    !@knowledge_base.nil?
  end
end

Minitest.after_run do
  next unless SharedKnowledgeBase.created?

  begin
    StarkInfra::AiKnowledgeBase.delete(ids: [SharedKnowledgeBase.get.id])
  rescue StarkCore::Error::InternalServerError
    warn("AiKnowledgeBase #{SharedKnowledgeBase.get.id} was not deleted: the API answered 500")
  end
end

describe(StarkInfra::AiKnowledgeBase, '#ai-knowledge-base#') do
  let(:knowledge_base) { SharedKnowledgeBase.get }

  it 'create returns a processing knowledge base' do
    expect(knowledge_base.id).wont_be_nil
    expect(knowledge_base.status).must_equal('processing')
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
    # the crawl status moves on its own, so filter by the one the base has right now
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
    # the other tests share this base and look it up by its original name
    StarkInfra::AiKnowledgeBase.update(knowledge_base.id, name: knowledge_base.name, tags: knowledge_base.tags)
  end

  it 'create with invalid root url raises input errors' do
    invalid = StarkInfra::AiKnowledgeBase.new(name: 'invalid', root_url: 'not-a-url')
    expect { StarkInfra::AiKnowledgeBase.create(invalid) }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'get unknown id raises input errors' do
    expect { StarkInfra::AiKnowledgeBase.get('0000000000000000') }.must_raise(StarkCore::Error::InputErrors)
  end
end

# The sandbox answers 500 to hosts and delete for a valid id, so these are checked at the HTTP boundary
# with the payloads documented for the API. Only Net::HTTP.start is replaced.
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

  it 'create sends only the creatable fields' do
    returned = StarkInfra::AiKnowledgeBase.new(
      id: '6767676767676767',
      name: 'Public Documentation',
      root_url: 'https://docs.starkinfra.com',
      is_recursive: false,
      tags: %w[support],
      status: 'success',
      created: '2022-01-01T00:00:00.000000+00:00',
      updated: '2022-01-02T00:00:00.000000+00:00'
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
end

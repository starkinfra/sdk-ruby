# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # AiKnowledgeBase object
  #
  # An AiKnowledgeBase turns a website into material an AiAgent can read. You give it a root URL; Stark Infra
  # crawls the page, follows its links, converts everything to Markdown and indexes it for retrieval.
  #
  # When you initialize an AiKnowledgeBase, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - name [string]: name of the knowledge base. Between 1 and 100 characters. ex: 'Product Documentation'
  # - root_url [string]: absolute http or https URL the crawl starts from. ex: 'https://docs.starkinfra.com'
  #
  # ## Parameters (optional):
  # - is_recursive [bool, default nil]: whether the crawl may follow links into other subdomains of the root URL's registered domain. The API defaults to true. ex: false
  # - tags [list of strings, default nil]: list of up to 100 strings for reference when searching for AiKnowledgeBases. ex: ['support', 'public']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiKnowledgeBase is created. ex: '5656565656565656'
  # - status [string]: current status of the knowledge base. Options: 'processing', 'success', 'failed'. An agent retrieves from a base only once it reaches 'success'.
  # - created [DateTime]: creation datetime for the AiKnowledgeBase. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the AiKnowledgeBase. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiKnowledgeBase < StarkCore::Utils::Resource
    attr_reader :name, :root_url, :is_recursive, :tags, :id, :status, :created, :updated
    def initialize(
      name:, root_url:, is_recursive: nil, tags: nil, id: nil, status: nil, created: nil, updated: nil
    )
      super(id)
      @name = name
      @root_url = root_url
      @is_recursive = is_recursive
      @tags = tags
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiKnowledgeBase
    #
    # Send an AiKnowledgeBase object for creation at the Stark Infra API and start crawling it.
    # The call returns immediately with the knowledge base in 'processing' status.
    # The core would read the response under 'base', so this function reads the 'knowledgeBase' key the API answers with.
    #
    # ## Parameters (required):
    # - knowledge_base [AiKnowledgeBase object]: AiKnowledgeBase object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiKnowledgeBase object with updated attributes
    def self.create(knowledge_base, user: nil)
      response = StarkInfra::Utils::Rest.post_raw(
        path: StarkCore::Utils::API.endpoint(resource[:resource_name]),
        payload: StarkCore::Utils::API.cast_json_to_api_format(
          name: knowledge_base.name,
          root_url: knowledge_base.root_url,
          is_recursive: knowledge_base.is_recursive,
          tags: knowledge_base.tags
        ),
        raiseException: true,
        user: user
      )
      _parse(response.json['knowledgeBase'])
    end

    # # Retrieve an AiKnowledgeBase
    #
    # Receive a single AiKnowledgeBase object previously created in the Stark Infra API by its id.
    # This is the call to poll while the crawl runs.
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiKnowledgeBase object that corresponds to the given id.
    def self.get(id, user: nil)
      response = StarkInfra::Utils::Rest.get_raw(
        path: "#{StarkCore::Utils::API.endpoint(resource[:resource_name])}/#{id}",
        raiseException: true,
        user: user
      )
      _parse(response.json['knowledgeBase'])
    end

    # # Retrieve AiKnowledgeBases
    #
    # Receive a generator of AiKnowledgeBase objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - name [string, default nil]: case-insensitive substring of the name to filter retrieved objects. ex: 'docs'
    # - status [string, default nil]: filter for status of retrieved objects. Options: 'processing', 'success', 'failed'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiKnowledgeBase objects with updated attributes
    def self.query(limit: nil, ids: nil, name: nil, status: nil, user: nil)
      Enumerator.new do |enum|
        cursor = nil
        remaining = limit
        loop do
          entities, cursor = page(
            cursor: cursor,
            limit: remaining.nil? ? nil : [remaining, 100].min,
            ids: ids,
            name: name,
            status: status,
            user: user
          )
          entities.each { |entity| enum << entity }
          remaining -= entities.length unless remaining.nil?
          break if cursor.nil? || cursor.empty? || (!remaining.nil? && remaining <= 0)
        end
      end
    end

    # # Retrieve paged AiKnowledgeBases
    #
    # Receive a list of up to 100 AiKnowledgeBase objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    # The name filter applies to each page, so a page can come back empty with a cursor: keep following it until the cursor is nil.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default nil]: maximum number of objects to be retrieved. The API accepts up to 100 and answers with an error above it. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - name [string, default nil]: case-insensitive substring of the name to filter retrieved objects. ex: 'docs'
    # - status [string, default nil]: filter for status of retrieved objects. Options: 'processing', 'success', 'failed'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of AiKnowledgeBase objects with updated attributes
    # - cursor to retrieve the next page of AiKnowledgeBase objects, nil on the last page
    def self.page(cursor: nil, limit: nil, ids: nil, name: nil, status: nil, user: nil)
      response = StarkInfra::Utils::Rest.get_raw(
        path: StarkCore::Utils::API.endpoint(resource[:resource_name]),
        query: { cursor: cursor, limit: limit, ids: ids, name: name, status: status },
        raiseException: true,
        user: user
      )
      content = response.json
      [content['knowledgeBases'].map { |entity| _parse(entity) }, content['cursor']]
    end

    # # Update an AiKnowledgeBase entity
    #
    # Rename a knowledge base, retag it or change whether its crawl is recursive. The root URL cannot be changed.
    #
    # ## Parameters (required):
    # - id [string]: AiKnowledgeBase unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - name [string, default nil]: new name of the knowledge base. Between 1 and 100 characters.
    # - is_recursive [bool, default nil]: whether the next crawl may follow links into other subdomains of the root URL's registered domain.
    # - tags [list of strings, default nil]: new list of up to 100 strings. Replaces the current list.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiKnowledgeBase with updated attributes
    def self.update(id, name: nil, is_recursive: nil, tags: nil, user: nil)
      response = StarkInfra::Utils::Rest.patch_raw(
        path: "#{StarkCore::Utils::API.endpoint(resource[:resource_name])}/#{id}",
        payload: StarkCore::Utils::API.cast_json_to_api_format(name: name, is_recursive: is_recursive, tags: tags),
        raiseException: true,
        user: user
      )
      _parse(response.json['knowledgeBase'])
    end

    # # List the pages of an AiKnowledgeBase
    #
    # Receive every page the crawler has seen, grouped by host. While a crawl is running this is the live picture,
    # merged with the last finished one.
    #
    # ## Parameters (required):
    # - id [string]: AiKnowledgeBase unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - hash mapping each host to its list of pages. Each page is a hash with 'original_url', 'storage_url' and 'status' ('pending', 'success' or 'failed')
    def self.hosts(id, user: nil)
      response = StarkInfra::Utils::Rest.get_raw(
        path: "#{StarkCore::Utils::API.endpoint(resource[:resource_name])}/#{id}/hosts",
        raiseException: true,
        user: user
      )
      response.json['hosts'].transform_values do |pages|
        pages.map { |page| page.transform_keys { |key| StarkCore::Utils::Case.camel_to_snake(key) } }
      end
    end

    # # Delete AiKnowledgeBases
    #
    # Delete up to 100 AiKnowledgeBases at once. Agents still referencing a deleted base simply retrieve nothing from it.
    #
    # ## Parameters (required):
    # - ids [list of strings]: ids of the AiKnowledgeBases to be deleted. Up to 100 ids. ex: ['5656565656565656', '4545454545454545']
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of deleted AiKnowledgeBase objects
    def self.delete(ids:, user: nil)
      response = StarkInfra::Utils::Rest.delete_raw(
        path: StarkCore::Utils::API.endpoint(resource[:resource_name]),
        query: { ids: ids },
        raiseException: true,
        user: user
      )
      response.json['knowledgeBases'].map { |entity| _parse(entity) }
    end

    def self._parse(json)
      StarkCore::Utils::API.from_api_json(resource[:resource_maker], json)
    end

    def self.resource
      {
        resource_name: 'AiKnowledgeBase',
        resource_maker: proc { |json|
          AiKnowledgeBase.new(
            id: json['id'],
            name: json['name'],
            root_url: json['root_url'],
            is_recursive: json['is_recursive'],
            tags: json['tags'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end

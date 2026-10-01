# frozen_string_literal: true

require('starkcore')
require_relative('../utils/ai_api')
require_relative('../ai_knowledge_base/ai_knowledge_base')

module StarkInfra
  # # AiAgent object
  #
  # An AiAgent is the configuration of an assistant: the model, the instructions, the knowledge it may consult and
  # the voice it speaks with. The agent never changes during a conversation; the conversation lives in an AiChat
  # and each turn is an AiMessage.
  #
  # When you initialize an AiAgent, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - name [string]: name of the agent. Between 1 and 100 characters. ex: 'Support assistant'
  # - model [string]: AI model the agent runs on. Options: 'bender-1.0' for everyday conversations, 'prime-1.0' for harder reasoning.
  #
  # ## Parameters (optional):
  # - system_prompt [string, default nil]: instructions that define the agent's persona, tone and domain behavior. Up to 100000 characters. The API falls back to its default assistant prompt when omitted.
  # - voice_id [string, default nil]: id of the AiVoice the agent speaks with. When set, every reply also carries a speech string ready to be sent to AiSpeech. The API does not check that the voice exists.
  # - knowledge_base_ids [list of strings, default nil]: ids of up to 100 AiKnowledgeBases the agent retrieves from before answering. The API does not check that they exist.
  # - metadata_schema [hash, default nil]: flat hash whose keys are the fields the agent must extract on every reply. Each field takes a 'type' (string, integer, number, boolean or array), an optional 'description' of up to 2000 characters, an optional 'enum' of up to 20 strings for string fields. The keys are yours and are sent exactly as written. ex: { 'order_id' => { 'type' => 'string', 'description' => 'Order the customer mentions' } }
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiAgent is created. ex: '5656565656565656'
  # - knowledge_bases [list of AiKnowledgeBase objects]: the knowledge bases themselves. Only present when requested with expand: ['knowledge_bases'].
  # - created [DateTime]: creation datetime for the AiAgent. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the AiAgent. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiAgent < StarkCore::Utils::Resource
    attr_reader :name, :model, :system_prompt, :voice_id, :knowledge_base_ids, :metadata_schema, :id,
                :knowledge_bases, :created, :updated
    def initialize(
      name:, model:, system_prompt: nil, voice_id: nil, knowledge_base_ids: nil, metadata_schema: nil, id: nil,
      knowledge_bases: nil, created: nil, updated: nil
    )
      super(id)
      @name = name
      @model = model
      @system_prompt = system_prompt
      @voice_id = voice_id
      @knowledge_base_ids = knowledge_base_ids
      @metadata_schema = metadata_schema
      @knowledge_bases = knowledge_bases&.map { |entity| _parse_knowledge_base(entity) }
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiAgent
    #
    # Send an AiAgent object for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - agent [AiAgent object]: AiAgent object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiAgent object with updated attributes
    def self.create(agent, user: nil)
      StarkInfra::Utils::AiApi.create_one(
        path: PATH,
        key: 'agent',
        resource_maker: resource[:resource_maker],
        payload: _payload(
          name: agent.name,
          model: agent.model,
          system_prompt: agent.system_prompt,
          voice_id: agent.voice_id,
          knowledge_base_ids: agent.knowledge_base_ids,
          metadata_schema: agent.metadata_schema
        ),
        user: user
      )
    end

    # # Retrieve a specific AiAgent
    #
    # Receive a single AiAgent object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - fields [list of strings, default nil]: attributes to keep in the response. ex: ['id', 'name']
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'knowledge_bases'. When fields is also given, the expanded attribute must be listed there too.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiAgent object with updated attributes
    def self.get(id, fields: nil, expand: nil, user: nil)
      StarkInfra::Utils::AiApi.get_one(
        path: PATH,
        key: 'agent',
        resource_maker: resource[:resource_maker],
        id: id,
        query: StarkInfra::Utils::AiApi.fields_and_expand(fields, expand),
        user: user
      )
    end

    # # Retrieve AiAgents
    #
    # Receive a generator of AiAgent objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - fields [list of strings, default nil]: attributes to keep in the response. ex: ['id', 'name']
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'knowledge_bases'. When fields is also given, the expanded attribute must be listed there too.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiAgent objects with updated attributes
    def self.query(fields: nil, expand: nil, user: nil)
      # this route is not paginated and rejects limit, cursor and every filter (invalidQueryString)
      StarkInfra::Utils::AiApi.list_all(
        path: PATH,
        key: 'agents',
        resource_maker: resource[:resource_maker],
        query: StarkInfra::Utils::AiApi.fields_and_expand(fields, expand),
        user: user
      )
    end

    # # Update AiAgent entity
    #
    # Update an AiAgent's parameters by passing its id. Only the parameters you give are changed.
    # The API replaces the knowledge base list with whatever the request carries and clears it when the request
    # carries none, so when knowledge_base_ids is not given this function reads the agent first and sends its
    # current list back. Pass an empty list to clear the knowledge bases on purpose.
    # The read and the update are two requests, so a knowledge base change made by someone else between them is overwritten.
    #
    # ## Parameters (required):
    # - id [string]: AiAgent unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - name [string, default nil]: new name for the agent. Between 1 and 100 characters.
    # - model [string, default nil]: new AI model. Options: 'bender-1.0', 'prime-1.0'
    # - system_prompt [string, default nil]: new instructions for the agent. Up to 100000 characters.
    # - voice_id [string, default nil]: new AiVoice id.
    # - knowledge_base_ids [list of strings, default nil]: the AiKnowledgeBase ids the agent should end up with. Replaces the current list.
    # - metadata_schema [hash, default nil]: new schema of the structured data the agent must extract.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiAgent with updated attributes
    def self.update(
      id, name: nil, model: nil, system_prompt: nil, voice_id: nil, knowledge_base_ids: nil, metadata_schema: nil,
      user: nil
    )
      knowledge_base_ids = get(id, fields: %w[knowledge_base_ids], user: user).knowledge_base_ids if knowledge_base_ids.nil?
      StarkInfra::Utils::AiApi.patch_one(
        path: PATH,
        key: 'agent',
        resource_maker: resource[:resource_maker],
        id: id,
        payload: _payload(
          name: name,
          model: model,
          system_prompt: system_prompt,
          voice_id: voice_id,
          knowledge_base_ids: knowledge_base_ids,
          metadata_schema: metadata_schema
        ),
        user: user
      )
    end

    # # Delete AiAgents
    #
    # Delete up to 100 AiAgents at once.
    #
    # ## Parameters (required):
    # - ids [list of strings]: ids of the AiAgents to be deleted. Up to 100 ids. ex: ['5656565656565656', '4545454545454545']
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of deleted AiAgent objects
    def self.delete(ids:, user: nil)
      StarkInfra::Utils::AiApi.delete_many(
        path: PATH,
        key: 'agents',
        resource_maker: resource[:resource_maker],
        ids: ids,
        user: user
      )
    end

    # the path has no leading slash: the request code already joins it to the base url with one
    PATH = 'ai-agent'

    # written out key by key: metadata_schema keys belong to the caller and must not be case-converted
    # an agent without a voice comes back with voice_id "", which the API rejects, so "" is treated as not given
    def self._payload(name:, model:, system_prompt:, voice_id:, knowledge_base_ids:, metadata_schema:)
      StarkInfra::Utils::AiApi.drop_nil(
        name: name,
        model: model,
        systemPrompt: system_prompt,
        voiceId: voice_id.to_s.empty? ? nil : voice_id,
        knowledgeBaseIds: knowledge_base_ids,
        metadataSchema: metadata_schema
      )
    end

    def self.resource
      {
        resource_name: 'AiAgent',
        resource_maker: proc { |json|
          AiAgent.new(
            id: json['id'],
            name: json['name'],
            model: json['model'],
            system_prompt: json['system_prompt'],
            voice_id: json['voice_id'],
            knowledge_base_ids: json['knowledge_base_ids'],
            metadata_schema: json['metadata_schema'],
            knowledge_bases: json['knowledge_bases'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end

    private

    def _parse_knowledge_base(entity)
      return entity unless entity.is_a?(Hash)

      StarkCore::Utils::API.from_api_json(AiKnowledgeBase.resource[:resource_maker], entity)
    end
  end
end

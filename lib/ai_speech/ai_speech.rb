# frozen_string_literal: true

require('starkcore')
require_relative('../utils/ai_api')

module StarkInfra
  # # AiSpeech object
  #
  # An AiSpeech is a text read out loud by an AiVoice. The audio is synthesized during the create call,
  # so the speech comes back already in 'success' status carrying the audio.
  #
  # When you initialize an AiSpeech, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - voice_id [string]: id of the AiVoice that reads the text. Only a voice in 'success' status can speak. ex: '5656565656565656'
  # - text [string]: text to be read out loud. ex: 'Your order has shipped.'
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiSpeech is created. ex: '5656565656565656'
  # - status [string]: current status of the speech. Options: 'processing', 'success', 'failed'
  # - audio [string]: base64-encoded audio. Left out of query, and of get when fields is given without it.
  # - voice_name [string]: name of the voice. Only present when requested with expand: ['voice_name'].
  # - errors [list of strings]: reasons the synthesis failed. Empty when it worked.
  # - created [DateTime]: creation datetime for the AiSpeech. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the AiSpeech. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiSpeech < StarkCore::Utils::Resource
    attr_reader :voice_id, :text, :id, :status, :audio, :voice_name, :errors, :created, :updated
    def initialize(
      voice_id:, text:, id: nil, status: nil, audio: nil, voice_name: nil, errors: nil, created: nil, updated: nil
    )
      super(id)
      @voice_id = voice_id
      @text = text
      @status = status
      @audio = audio
      @voice_name = voice_name
      @errors = errors
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiSpeech
    #
    # Send an AiSpeech object for creation at the Stark Infra API. The audio is synthesized during the call.
    #
    # ## Parameters (required):
    # - speech [AiSpeech object]: AiSpeech object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiSpeech object with updated attributes
    def self.create(speech, user: nil)
      StarkInfra::Utils::AiApi.create_one(
        path: PATH,
        key: 'speech',
        resource_maker: resource[:resource_maker],
        payload: { voiceId: speech.voice_id, text: speech.text },
        user: user
      )
    end

    # # Retrieve a specific AiSpeech
    #
    # Receive a single AiSpeech object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - fields [list of strings, default nil]: attributes to keep in the response. The audio is only attached when fields is omitted or lists 'audio'. ex: ['id', 'status', 'audio']
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'voice_name'. When fields is also given, the expanded attribute must be listed there too.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiSpeech object with updated attributes
    def self.get(id, fields: nil, expand: nil, user: nil)
      StarkInfra::Utils::AiApi.get_one(
        path: PATH,
        key: 'speech',
        resource_maker: resource[:resource_maker],
        id: id,
        query: StarkInfra::Utils::AiApi.fields_and_expand(fields, expand),
        user: user
      )
    end

    # # Retrieve AiSpeeches
    #
    # Receive a generator of AiSpeech objects previously created in the Stark Infra API. The audio is left out of the results.
    #
    # ## Parameters (optional):
    # - fields [list of strings, default nil]: attributes to keep in the response. ex: ['id', 'status']
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'voice_name'. When fields is also given, the expanded attribute must be listed there too.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiSpeech objects with updated attributes
    def self.query(fields: nil, expand: nil, user: nil)
      # this route is not paginated and rejects limit, cursor and every filter (invalidQueryString)
      StarkInfra::Utils::AiApi.list_all(
        path: PATH,
        key: 'speeches',
        resource_maker: resource[:resource_maker],
        query: StarkInfra::Utils::AiApi.fields_and_expand(fields, expand),
        user: user
      )
    end

    # the path has no leading slash: the request code already joins it to the base url with one
    PATH = 'ai-speech'

    def self.resource
      {
        resource_name: 'AiSpeech',
        resource_maker: proc { |json|
          AiSpeech.new(
            id: json['id'],
            voice_id: json['voice_id'],
            text: json['text'],
            status: json['status'],
            audio: json['audio'],
            voice_name: json['voice_name'],
            errors: json['errors'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end

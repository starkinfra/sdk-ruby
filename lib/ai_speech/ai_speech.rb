# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

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
  # - audio [string]: base64-encoded audio. Left out of query and page.
  # - voice_name [string]: name of the voice. Only present when requested with expand: ['voiceName'].
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
      StarkInfra::Utils::Rest.post_single(entity: speech, user: user, **resource)
    end

    # # Retrieve a specific AiSpeech
    #
    # Receive a single AiSpeech object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'voiceName'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiSpeech object with updated attributes
    def self.get(id, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, expand: expand, user: user, **resource)
    end

    # # Retrieve AiSpeeches
    #
    # Receive a generator of AiSpeech objects previously created in the Stark Infra API. The audio is left out of the results.
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'voiceName'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiSpeech objects with updated attributes
    def self.query(limit: nil, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(limit: limit, expand: expand, user: user, **resource)
    end

    # # Retrieve paged AiSpeeches
    #
    # Receive a list of up to 100 AiSpeech objects previously created in the Stark Infra API and the cursor to the next page. The audio is left out of the results.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default nil]: maximum number of objects to be retrieved. The API accepts up to 100 and answers with an error above it. ex: 35
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'voiceName'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of AiSpeech objects with updated attributes
    # - cursor to retrieve the next page of AiSpeech objects, nil on the last page
    def self.page(cursor: nil, limit: nil, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(cursor: cursor, limit: limit, expand: expand, user: user, **resource)
    end

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

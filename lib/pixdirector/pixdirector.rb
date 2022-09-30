# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/resource')

module StarkInfra
  # # PixDirector object
  #
  # Mandatory data that must be registered within the Central Bank for
  # emergency contact purposes.
  #
  # When you initialize a PixDirector, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - name [string]: name of the PixDirector. ex: 'Edward Stark'.
  # - tax_id [string]: tax ID (CPF) of the PixDirector. ex: '012.345.678-90'
  # - phone [string]: phone of the PixDirector. ex: '+551198989898'
  # - email [string]: email of the PixDirector. ex: 'ned.stark@starkbank.com'
  # - password [string]: password of the PixDirector. ex: '12345678'
  # - team_email [string]: team email. ex: 'pix.team@company.com'
  # - team_phones [list of strings]: list of phones of the team. ex: ['+5511988889999', '+5511988889998']
  #
  # ## Attributes (return-only):
  # - status [string]: current PixDirector status. ex: 'success'
  class PixDirector < StarkInfra::Utils::SubResource
    attr_reader :name, :tax_id, :phone, :email, :password, :team_email, :team_phones, :status
    def initialize(name:, tax_id:, phone:, email:, password:, team_email:, team_phones:, status: nil)
      @name = name
      @tax_id = tax_id
      @phone = phone
      @email = email
      @password = password
      @team_email = team_email
      @team_phones = team_phones
      @status = status
    end

    # # Create a PixDirector
    #
    # Send a PixDirector object for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - director [PixDirector object]: PixDirector object to be created in the API. ex: PixDirector.new()
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixDirector object with updated attributes.
    def self.create(director, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: director, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'PixDirector',
        resource_maker: proc { |json|
          PixDirector.new(
            name: json['name'],
            tax_id: json['tax_id'],
            phone: json['phone'],
            email: json['email'],
            password: json['password'],
            team_email: json['team_email'],
            team_phones: json['team_phones'],
            status: json['status']
          )
        }
      }
    end
  end
end

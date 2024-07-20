# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../utils/parse')

module StarkInfra

    class Request

        # # Retrieve any StarkInfra resource
        #
        # Receive a json of resources previously created in StarkInfra's API
        #
        # Parameters (required):
        #
        # - path [string]: StarkInfra resource's route. ex: "/pix-request/"
        # - query [dict, default None]: Query parameters. ex: {"limit": 1, "status": paid}
        #
        # Parameters (optional):
        #
        # - user [Organization/Project object, default None]: Organization or Project object. Not necessary if StarkInfra.user
        #     was set before function call
        #
        # Return:
        # - dict of StarkInfra objects with updated attributes

        def self.get(path:, user: nil, query: nil)
            content = StarkInfra::Utils::Rest.get_raw(
                path: path,
                user: user,
                prefix: "Joker",
                raiseException: false,
                query: query
            )
        end

        # # Create any StarkInfra resource
        #
        # Send a json to create StarkBank resources
        #
        # Parameters (required):
        #
        # - path [string]: StarkInfra resource's route. ex: "/pix-request/"
        # - body [dict]: request parameters. ex: {"requests": [{"amount": 100, "name": "Iron Bank S.A.", "taxId": "20.018.183/0001-80"}]}
        #
        # Parameters (optional):
        #
        # - user [Organization/Project object, default None]: Organization or Project object. Not necessary if StarkInfra.user
        #     was set before function call
        # - query [dict, default None]: Query parameters. ex: {"limit": 1, "status": paid}
        #
        # Return:
        #
        # - list of resources jsons with updated attributes

        def self.post(path:, payload:, query: nil, user: nil)
            content = StarkInfra::Utils::Rest.post_raw(
                path: path,
                query: query,
                payload: payload,
                user: user,
                prefix: "Joker",
                raiseException: false
            )
        end

        # # Update any StarkInfra resource
        #
        # Send a json with parameters of StarkBank resources to update them
        #
        # Parameters (required):
        #
        # - path [string]: StarkInfra resource's route. ex: "/pix-request/5699165527090460"
        # - body [dict]: request parameters. ex: {"amount": 100}
        #
        # Parameters (optional):
        #
        # - user [Organization/Project object, default None]: Organization or Project object. Not necessary if StarkInfra.user
        #     was set before function call
        #
        # Return:
        # - json of the resource with updated attributes

        def self.patch(path:, payload:, query: nil, user: nil)
            content = StarkInfra::Utils::Rest.patch_raw(
                path: path,
                query: query,
                payload: payload,
                user: user,
                prefix: "Joker",
                raiseException: false
            )
        end

        # # Put any StarkInfra resource
        #
        # Send a json with parameters of a StarkBank resources to create them. 
        # If the resource already exists, you will update it.
        #
        # Parameters (required):
        #
        # - path [string]: StarkInfra resource's route. ex: "/pix-request"
        # - body [dict]: request parameters. ex: {"amount": 100}
        #
        # Parameters (optional):
        #
        # - user [Organization/Project object, default None]: Organization or Project object. Not necessary if StarkInfra.user
        #     was set before function call
        #
        # Return:
        # - json of the resource with updated attributes

        def self.put(path:, payload:, query: nil, user: nil)
            content = StarkInfra::Utils::Rest.put_raw(
                path: path,
                query: query,
                payload: payload,
                user: user,
                prefix: "Joker",
                raiseException: false
            )
        end

        # # Delete any StarkInfra resource
        #
        # Send parameters of StarkBank resources and delete them
        #
        # Parameters (required):
        #
        # - path [string]: StarkInfra resource's route. ex: "/pix-request/5699165527090460"
        # - body [dict]: request parameters. ex: {"amount": 100}
        #
        # Parameters (optional):
        #
        # - user [Organization/Project object, default None]: Organization or Project object. Not necessary if StarkInfra.user
        #     was set before function call
        #
        # Return:
        # - json of the resource with updated attributes
        
        def self.delete(path:, query: nil, user: nil)
            content = StarkInfra::Utils::Rest.delete_raw(
                path: path,
                query: query,
                user: user,
                prefix: "Joker",
                raiseException: false
            )
        end
    end
end
# frozen_string_literal: true

require('starkcore')

module StarkInfra
  class PixDispute
    # # PixDispute::Transaction object
    #
    # Transactions linked to a PixDispute as part of the graph analysis. This object
    # is return-only; it is never created by the user.
    #
    # ## Attributes (return-only):
    # - end_to_end_id [string]: central bank's unique transaction id. ex: 'E20018183202201201450u34sDGd19lz'
    # - amount [integer]: refundable amount in cents. ex: 11234 (= R$ 112.34)
    # - nominal_amount [integer]: transaction amount in cents. ex: 11234 (= R$ 112.34)
    # - receiver_type [string]: receiver's type. Options: 'individual', 'business'
    # - receiver_tax_id_created [string]: receiver's taxId creation date (business type only).
    # - receiver_account_created [string]: receiver's account creation date.
    # - receiver_bank_code [string]: receiver's bank code. ex: '20018183'
    # - receiver_id [string]: identifier of the accountholder in the graph.
    # - sender_type [string]: sender's type. Options: 'individual', 'business'
    # - sender_tax_id_created [string]: sender's taxId creation date (business type only).
    # - sender_account_created [string]: sender's account creation date.
    # - sender_bank_code [string]: sender's bank code. ex: '20018183'
    # - sender_id [string]: identifier of the accountholder in the graph.
    # - settled [DateTime]: settled datetime of the transaction. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Transaction < StarkCore::Utils::SubResource
      attr_reader :end_to_end_id, :amount, :nominal_amount, :receiver_type, :receiver_tax_id_created,
                  :receiver_account_created, :receiver_bank_code, :receiver_id, :sender_type, :sender_tax_id_created,
                  :sender_account_created, :sender_bank_code, :sender_id, :settled
      def initialize(
        end_to_end_id: nil, amount: nil, nominal_amount: nil, receiver_type: nil, receiver_tax_id_created: nil,
        receiver_account_created: nil, receiver_bank_code: nil, receiver_id: nil, sender_type: nil,
        sender_tax_id_created: nil, sender_account_created: nil, sender_bank_code: nil, sender_id: nil, settled: nil
      )
        @end_to_end_id = end_to_end_id
        @amount = amount
        @nominal_amount = nominal_amount
        @receiver_type = receiver_type
        @receiver_tax_id_created = receiver_tax_id_created
        @receiver_account_created = receiver_account_created
        @receiver_bank_code = receiver_bank_code
        @receiver_id = receiver_id
        @sender_type = sender_type
        @sender_tax_id_created = sender_tax_id_created
        @sender_account_created = sender_account_created
        @sender_bank_code = sender_bank_code
        @sender_id = sender_id
        @settled = StarkCore::Utils::Checks.check_datetime(settled)
      end

      def self.parse_transactions(transactions)
        resource_maker = StarkInfra::PixDispute::Transaction.resource[:resource_maker]
        return transactions if transactions.nil?

        parsed_transactions = []
        transactions.each do |transaction|
          unless transaction.is_a? Transaction
            transaction = StarkCore::Utils::API.from_api_json(resource_maker, transaction)
          end
          parsed_transactions << transaction
        end
        parsed_transactions
      end

      def self.resource
        {
          resource_name: 'PixDisputeTransaction',
          resource_maker: proc { |json|
            Transaction.new(
              end_to_end_id: json['end_to_end_id'],
              amount: json['amount'],
              nominal_amount: json['nominal_amount'],
              receiver_type: json['receiver_type'],
              receiver_tax_id_created: json['receiver_tax_id_created'],
              receiver_account_created: json['receiver_account_created'],
              receiver_bank_code: json['receiver_bank_code'],
              receiver_id: json['receiver_id'],
              sender_type: json['sender_type'],
              sender_tax_id_created: json['sender_tax_id_created'],
              sender_account_created: json['sender_account_created'],
              sender_bank_code: json['sender_bank_code'],
              sender_id: json['sender_id'],
              settled: json['settled']
            )
          }
        }
      end
    end
  end
end

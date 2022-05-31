# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../user')

content = '{"acquirerId": "236090", "amount": 100, "cardId": "5671893688385536", "cardTags": [], "endToEndId": "2fa7ef9f-b889-4bae-ac02-16749c04a3b6", "holderId": "5917814565109760", "holderTags": [], "isPartialAllowed": false, "issuerAmount": 100, "issuerCurrencyCode": "BRL", "merchantAmount": 100, "merchantCategoryCode": "bookStores", "merchantCountryCode": "BRA", "merchantCurrencyCode": "BRL", "merchantFee": 0, "merchantId": "204933612653639", "merchantName": "COMPANY 123", "methodCode": "token", "purpose": "purchase", "score": null, "tax": 0, "walletId": ""}'
valid_signature = 'MEUCIBxymWEpit50lDqFKFHYOgyyqvE5kiHERi0ZM6cJpcvmAiEA2wwIkxcsuexh9BjcyAbZxprpRUyjcZJ2vBAjdd7o28Q='
invalid_signature = 'MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk='

describe(StarkInfra::IssuingAuthorization, '#issuing-authorization#') do
  it 'response success' do
    response = StarkInfra::IssuingAuthorization.response(status: "ok")
  end

  it 'valid signature success' do
    authorization = StarkInfra::IssuingAuthorization.parse(content: content, signature: valid_signature)
  end

  it 'invalid signature success' do
    begin
      StarkInfra::IssuingAuthorization.parse(content: content, signature: invalid_signature)
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'invalid signature was not detected')
    end
  end
end

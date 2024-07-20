# frozen_string_literal: false

require_relative('../test_helper.rb')
require('securerandom')

describe(StarkInfra::Request, '#request#') do
  it 'get success' do
    path = "/pix-request"
    query = {"limit": 10}
    content = StarkInfra::Request.get(path: path, query: query).json()
    expect(content["requests"][0]["id"]).wont_be_nil
  end

  it 'post success' do
    data = {
        "holders": [
            {
                "name": "Jaime Lannister",
                "externalId": SecureRandom.base64,
                "taxId": "012.345.678-90"
            }
        ]
    }
    path = "/issuing-holder"
    content = StarkInfra::Request.post(path: path, payload: data).json()
    expect(content["holders"][0]["id"]).wont_be_nil
  end

  it 'patch success' do
    data = {
        "holders": [
            {
                "name": "Jaime Lannister",
                "externalId": SecureRandom.base64,
                "taxId": "012.345.678-90"
            }
        ]
    }
    path = "/issuing-holder"
    content = StarkInfra::Request.post(path: path, payload: data).json()

    content_id = content["holders"][0]["id"]

    data = {"tags": [SecureRandom.base64]}

    path = "/issuing-holder/#{content_id}"
    content = StarkInfra::Request.patch(path: path, payload: data).json()

    expect(content["holder"]["id"]).wont_be_nil
  end

  it 'delete success' do
    data = {
        "holders": [
            {
                "name": "Jaime Lannister",
                "externalId": SecureRandom.base64,
                "taxId": "012.345.678-90"
            }
        ]
    }
    path = "/issuing-holder"
    content = StarkInfra::Request.post(path: path, payload: data).json()

    path += "/#{content["holders"][0]["id"]}"

    content = StarkInfra::Request.delete(path: path).json()

    expect(content["holder"]["id"]).wont_be_nil
  end

end

# frozen_string_literal: false

module BankCode
  def self.bank_code
    ENV['SANDBOX_BANK_CODE']
  end
end

StarkInfra.user = StarkInfra::Project.new(
  environment: 'sandbox',
  id: ENV['SANDBOX_ID'], # '9999999999999999',
  private_key: ENV['SANDBOX_PRIVATE_KEY'] # '-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEIBEcEJZLk/DyuXVsEjz0w4vrE7plPXhQxODvcG1Jc0WToAcGBSuBBAAK\noUQDQgAE6t4OGx1XYktOzH/7HV6FBukxq0Xs2As6oeN6re1Ttso2fwrh5BJXDq75\nmSYHeclthCRgU8zl6H1lFQ4BKZ5RCQ==\n-----END EC PRIVATE KEY-----'
)

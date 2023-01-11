# Stark Infra Ruby SDK Beta

Welcome to the Stark Infra Ruby SDK! This tool is made for Ruby 
developers who want to easily integrate with our API.
This SDK version is compatible with the Stark Infra API v2.

# Introduction

### Index

- [Introduction](#introduction)
  - [Supported Ruby versions](#supported-ruby-versions)
  - [API documentation](#stark-infra-api-documentation)
  - [Versioning](#versioning)
- [Setup](#setup)
  - [Install our SDK](#1-install-our-sdk)
  - [Create your Private and Public Keys](#2-create-your-private-and-public-keys)
  - [Register your user credentials](#3-register-your-user-credentials)
  - [Setting up the user](#4-setting-up-the-user)
  - [Setting up the error language](#5-setting-up-the-error-language)
- [Resource listing and manual pagination](#resource-listing-and-manual-pagination)
- [Testing in Sandbox](#testing-in-sandbox)
- [Usage](#usage)
  - [Issuing](#issuing)
    - [Products](#query-issuingproducts): View available sub-issuer card products (a.k.a. card number ranges or BINs)
    - [Holders](#create-issuingholders): Manage card holders
    - [Cards](#create-issuingcards): Create virtual and/or physical cards
    - [Purchases](#process-purchase-authorizations): Authorize and view your past purchases
    - [Invoices](#create-issuinginvoices): Add money to your issuing balance
    - [Withdrawals](#create-issuingwithdrawals): Send money back to your Workspace from your issuing balance
    - [Balance](#get-your-issuingbalance): View your issuing balance
    - [Transactions](#query-issuingtransactions): View the transactions that have affected your issuing balance
    - [Enums](#issuing-enums): Query enums related to the issuing purchases, such as merchant categories, countries and card purchase methods
  - [Pix](#pix)
    - [PixRequests](#create-pixrequests): Create Pix transactions
    - [PixReversals](#create-pixreversals): Reverse Pix transactions
    - [PixBalance](#get-your-pixbalance): View your account balance
    - [PixStatement](#create-a-pixstatement): Request your account statement
    - [PixKey](#create-a-pixkey): Create a Pix Key
    - [PixClaim](#create-a-pixclaim): Claim a Pix Key
    - [PixDirector](#create-a-pixdirector): Create a Pix Director
    - [PixInfraction](#create-pixinfractions): Create Pix Infraction reports
    - [PixChargeback](#create-pixchargebacks): Create Pix Chargeback requests
    - [PixDomain](#query-pixdomains): View registered SPI participants certificates
    - [StaticBrcode](#create-staticbrcodes): Create static Pix BR Codes
    - [DynamicBrcode](#create-dynamicbrcodes): Create dynamic Pix BR Codes
    - [BrcodePreview](#create-brcodepreviews): Read data from BR Codes before paying them
  - [Credit Note](#credit-note)
    - [CreditNote](#create-creditnotes): Create credit notes
  - [Credit Preview](#credit-preview)
    - [CreditNotePreview](#create-creditnotepreviews): Create credit note previews
  - [Identity](#identity)
    - [IndividualIdentity](#create-individualidentities): Create individual identities
    - [IndividualDocument](#create-individualdocuments): Create individual documents
  - [Webhook](#webhook):
    - [Webhook](#create-a-webhook-subscription): Configure your webhook endpoints and subscriptions
    - [WebhookEvents](#process-webhook-events): Manage Webhook events
    - [WebhookEventAttempts](#query-failed-webhook-event-delivery-attempts-information): Query failed webhook event deliveries
- [Handling errors](#handling-errors)
- [Help and Feedback](#help-and-feedback)

### Supported Ruby Versions

This library supports the following Ruby versions:

* Ruby 2.3+

### Stark Infra API documentation

Feel free to take a look at our [API docs](https://starkinfra.com/docs/api).

### Versioning

This project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.

# Setup

### 1. Install our SDK

1.1 To install the package with gem, run:

```sh
gem install starkinfra
```

1.2 Or just add this to your Gemfile:

```sh
gem('starkinfra', '~> 0.2.0')
```

### 2. Create your Private and Public Keys

We use ECDSA. That means you need to generate a secp256k1 private
key to sign your requests to our API, and register your public key
with us, so we can validate those requests.

You can use one of the following methods:

2.1. Check out the options in our [tutorial](https://starkbank.com/faq/how-to-create-ecdsa-keys). 

2.2. Use our SDK:

```ruby
require('starkinfra')

privateKey, publicKey = StarkInfra::Key.create

# or, to also save .pem files in a specific path
# private_key, public_key = StarkInfra::Key.create('file/keys/')
```

**NOTE**: When you are creating new credentials, it is recommended that you create the
keys inside the infrastructure that will use it, in order to avoid risky internet
transmissions of your **private-key**. Then you can export the **public-key** alone to the
computer where it will be used in the new Project creation.

### 3. Register your user credentials

You can interact directly with our API using two types of users: Projects and Organizations.

- **Projects** are workspace-specific users, that is, they are bound to the workspaces they are created in.
One workspace can have multiple Projects.
- **Organizations** are general users that control your entire organization.
They can control all your Workspaces and even create new ones. The Organization is bound to your company's tax ID only.
Since this user is unique in your entire organization, only one credential can be linked to it.

3.1. To create a Project in Sandbox:

3.1.1. Log into [StarkInfra Sandbox](https://web.sandbox.starkinfra.com)

3.1.2. Go to Menu > Integrations

3.1.3. Click on the "New Project" button

3.1.4. Create a Project: Give it a name and upload the public key you created in section 2

3.1.5. After creating the Project, get its Project ID

3.1.6. Use the Project ID and private key to create the object below:

```ruby
require('starkinfra')

# Get your private key from an environment variable or an encrypted database.
# This is only an example of a private key content. You should use your own key.
private_key_content = '
-----BEGIN EC PARAMETERS-----
BgUrgQQACg==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIMCwW74H6egQkTiz87WDvLNm7fK/cA+ctA2vg/bbHx3woAcGBSuBBAAK
oUQDQgAE0iaeEHEgr3oTbCfh8U2L+r7zoaeOX964xaAnND5jATGpD/tHec6Oe9U1
IF16ZoTVt1FzZ8WkYQ3XomRD4HS13A==
-----END EC PRIVATE KEY-----
'

project = StarkInfra::Project.new(
  environment: 'sandbox',
  id: '5656565656565656',
  private_key: private_key_content
)
```

3.2. To create Organization credentials in Sandbox:

3.2.1. Log into [Starkinfra Sandbox](https://web.sandbox.starkinfra.com)

3.2.2. Go to Menu > Integrations

3.2.3. Click on the "Organization public key" button

3.2.4. Upload the public key you created in section 2 (only a legal representative of the organization can upload the public key)

3.2.5. Click on your profile picture and then on the "Organization" menu to get the Organization ID

3.2.6. Use the Organization ID and private key to create the object below:

```ruby
require('starkinfra')

# Get your private key from an environment variable or an encrypted database.
# This is only an example of a private key content. You should use your own key.
private_key_content = '
-----BEGIN EC PARAMETERS-----
BgUrgQQACg==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIMCwW74H6egQkTiz87WDvLNm7fK/cA+ctA2vg/bbHx3woAcGBSuBBAAK
oUQDQgAE0iaeEHEgr3oTbCfh8U2L+r7zoaeOX964xaAnND5jATGpD/tHec6Oe9U1
IF16ZoTVt1FzZ8WkYQ3XomRD4HS13A==
-----END EC PRIVATE KEY-----
'

organization = StarkInfra::Organization.new(
  environment: 'sandbox',
  id: '5656565656565656',
  private_key: private_key_content,
  workspace_id: nil,  # You only need to set the workspace_id when you are operating a specific workspace_id
)

```

NOTE 1: Never hard-code your private key. Get it from an environment variable or an encrypted database.

NOTE 2: We support `'sandbox'` and `'production'` as environments.

NOTE 3: The credentials you registered in `sandbox` do not exist in `production` and vice versa.


### 4. Setting up the user

There are three kinds of users that can access our API: **Organization**, **Project**, and **Member**.

- `Project` and `Organization` are designed for integrations and are the ones meant for our SDKs.
- `Member` is the one you use when you log into our webpage with your e-mail.

There are two ways to inform the user to the SDK:

4.1 Passing the user as an argument in all functions:

```ruby
require('starkinfra')

balance = StarkInfra::PixBalance.get(user: project)  # or organization
```

4.2 Set it as a default user in the SDK:

```ruby
require('starkinfra')

StarkInfra::user = project  # or organization

balance = StarkInfra::PixBalance.get
```

Just select the way of passing the user that is more convenient to you.
On all following examples, we will assume a default user has been set.

### 5. Setting up the error language

The error language can also be set in the same way as the default user:

```ruby
require('starkinfra')

StarkInfra::language = 'en-US'
```

Language options are 'en-US' for English and 'pt-BR' for Brazilian Portuguese. English is the default.

# Resource listing and manual pagination

Almost all SDK resources provide a `query` and a `page` function.

- The `query` function provides a straightforward way to efficiently iterate through all results that match the filters you inform,
seamlessly retrieving the next batch of elements from the API only when you reach the end of the current batch.
If you are not worried about data volume or processing time, this is the way to go.

```ruby
require('starkinfra')

requests = StarkInfra::PixRequest.query(limit=200)

requests.each do |request|
  puts request
end
```

- The `page` function gives you full control over the API pagination. With each function call, you receive up to
100 results and the cursor to retrieve the next batch of elements. This allows you to stop your queries and
pick up from where you left off whenever it is convenient. When there are no more elements to be retrieved, the returned cursor will be `nil`.

```ruby
require('starkinfra')

cursor = nil
while true
  requests, cursor = StarkInfra::PixRequest.page(limit: 50, cursor: cursor)
  requests.each do |request|
    puts request
  end
  if cursor.nil?
    break
  end
end
```

To simplify the following SDK examples, we will only use the `query` function, but feel free to use `page` instead.

# Testing in Sandbox

Your initial balance is zero. For many operations in Stark Infra, you'll need funds
in your account, which can be added to your balance by creating a StarkBank::Invoice.

In the Sandbox environment, most of the created Invoices will be automatically paid,
so there's nothing else you need to do to add funds to your account. Just create
a few StarkBank::Invoices and wait around a bit.

In Production, you (or one of your clients) will need to actually pay this StarkBank::Invoice 
for the value to be credited to your account.

# Usage

Here are a few examples on how to use the SDK. If you have any doubts, check out the function or class docstring to get more info or go straight to our [API docs](https://starkinfra.com/docs/api).

## Issuing

### Query IssuingProducts

To take a look at the sub-issuer card products available to you, just run the following:

```ruby
require('starkinfra')

products = StarkInfra::IssuingProduct.query()

products.each do |product|
  puts product
end
```

This will tell which card products and card number prefixes you have at your disposal.

### Create IssuingHolders

You can create card holders to which your cards will be bound.
They support spending rules that will apply to all underlying cards.

```ruby
require('starkinfra')

holders = StarkInfra::IssuingHolder.create([
  StarkInfra::IssuingHolder.new(
    name: "Iron Bank S.A.",
    external_id: '1234',
    tax_id: '0000',
    tags: ['012.345.678-90'],
    rules: [StarkInfra::IssuingRule.new(
      name: "General USD",
      interval: "day",
      amount: 100000,
      currency_code: "USD"
    )]
  )
])

holders.each do |holder|
    puts holder
end
```

**Note**: Instead of using IssuingHolder objects, you can also pass each IssuingHolder element in hash format

### Query IssuingHolders

You can query multiple holders according to filters.

```ruby
require('starkinfra')

holders = StarkInfra::IssuingHolder.query()

holders.each do |holder|
  puts holder
end
```

### Cancel an IssuingHolder

To cancel a single Issuing Holder by its id, run:

```ruby
require('starkinfra')

holder = StarkInfra::IssuingHolder.cancel('5155165527080960')

puts holder
```

### Get an IssuingHolder

To get a single Issuing Holder by its id, run:

```ruby
require('starkinfra')

holder = StarkInfra::IssuingHolder.get('5155165527080960')

puts holder
```

### Query IssuingHolder logs

You can query holder logs to better understand holder life cycles.

```ruby
require('starkinfra')

logs = StarkInfra::IssuingHolder::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get an IssuingHolder log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::IssuingHolder::Log.get('5155165527080960')

puts log
```

### Create IssuingCards

You can issue cards with specific spending rules.

```ruby
require('starkinfra')

cards = StarkInfra::IssuingCard.create([
  StarkInfra::IssuingCard.new(
    holder_name: "Developers",
    holder_tax_id: "012.345.678-90",
    holder_external_id: "1234",
    rules: [
      StarkInfra::IssuingRule.new(
        name: "General USD",
        interval: "day",
        amount: 100000,
        currency_code: "USD"
      )
    ]
  )
])

cards.each do |card|
    puts card
end
```

### Query IssuingCards

You can get a list of created cards given some filters.

```ruby
require('starkinfra')

cards = StarkInfra::IssuingCard.query(
  limit: 10,
  after: '2022-01-01',
  before: '2022-01-20',
)

cards.each do |card|
  puts card
end
```

### Get an IssuingCard

After its creation, information on a card may be retrieved by its id.

```ruby
require('starkinfra')

card = StarkInfra::IssuingCard.get('5155165527080960')

puts card
```

### Update an IssuingCard

You can update a specific card by its id.

```ruby
require('starkinfra')

card = StarkInfra::IssuingCard.update(
  '5155165527080960',
  status: 'blocked'
)

puts card
```

### Cancel an IssuingCard

You can also cancel a card by its id.

```ruby
require('starkinfra')

card = StarkInfra::IssuingCard.cancel('5155165527080960')

puts card
```

### Query IssuingCard logs

Logs are pretty important to understand the life cycle of a card.

```ruby
require('starkinfra')

logs = StarkInfra::IssuingCard::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get an IssuingCard log

You can get a single log by its id.

```ruby
require('starkinfra')

log = StarkInfra::IssuingCard::Log.get('5155165527080960')

puts log
```

### Process Purchase authorizations

It's easy to process purchase authorizations delivered to your endpoint.
Remember to pass the signature header so the SDK can make sure it's StarkInfra that sent you the event.
If you do not approve or decline the authorization within 2 seconds, the authorization will be denied.

```ruby
require('starkinfra')

authorization = listen_authorizations()  # this is your handler to listen for purchase authorization

authorization = StarkInfra::IssuingPurchase.parse(
  content: authorization.body.read, 
  signature: authorization.headers['Digital-Signature']
)

send_response(  # you should also implement this method
  StarkInfra::IssuingPurchase.response(  # this optional method just helps you build the response JSON
    status: 'accepted',
    amount: authorization.amount,
    tags: ['my-purchase-id/123']
  )
)

# or

send_response(
  StarkInfra::IssuingPurchase.response(
    status: 'denied',
    reason: 'other',
    tags: ['my-other-id/456']
  )
)
```

### Query IssuingPurchases

You can get a list of created purchases given some filters.

```ruby
require('starkinfra')

purchases = StarkInfra::IssuingPurchase.query(
  limit: 10,
  after: '2022-01-01',
  before: '2022-01-20',
)

purchases.each do |purchase|
  puts purchase
end
```

### Get an IssuingPurchase

After its creation, information on a purchase may be retrieved by its id. 

```ruby
require('starkinfra')

purchase = StarkInfra::IssuingPurchase.get('5155165527080960')

puts purchase
```

### Query IssuingPurchase logs

Logs are pretty important to understand the life cycle of a purchase.

```ruby
require('starkinfra')

logs = StarkInfra::IssuingPurchase::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get an IssuingPurchase log

You can get a single log by its id.

```ruby
require('starkinfra')

log = StarkInfra::IssuingPurchase::Log.get('5155165527080960')

puts log
```

### Create IssuingInvoices

You can create Pix invoices to transfer money from accounts you have in any bank to your Issuing balance,
allowing you to run your issuing operation.

```ruby
require('starkinfra')

invoice = StarkInfra::IssuingInvoice.create(
  StarkInfra::IssuingInvoice.new(
    amount: 1_000
  )
)

puts invoice
```

**Note**: Instead of using IssuingInvoice objects, you can also pass each invoice element in hash format

### Get an IssuingInvoice

After its creation, information on an invoice may be retrieved by its id. 
Its status indicates whether it's been paid.

```ruby
require('starkinfra')

invoice = StarkInfra::IssuingInvoice.get('5155165527080960')

puts invoice
```

### Query IssuingInvoices

You can get a list of created invoices given some filters.

```ruby
require('starkinfra')

invoices = StarkInfra::IssuingInvoice.query(
  limit: 10,
  after: '2022-01-01',
  before: '2022-01-20',
)

invoices.each do |invoice|
  puts invoice
end
```

### Query IssuingInvoice logs

Logs are pretty important to understand the life cycle of an invoice.

```ruby
require('starkinfra')

logs = StarkInfra::IssuingInvoice::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get an IssuingInvoice log

You can get a single log by its id.

```ruby
require('starkinfra')

log = StarkInfra::IssuingInvoice::Log.get('5155165527080960')

puts log
```

### Create IssuingWithdrawals

You can create withdrawals to send cash back from your Issuing balance to your Banking balance
by using the Withdrawal resource.

```ruby
require('starkinfra')

withdrawal = StarkInfra::IssuingWithdrawal.create(
  StarkInfra::IssuingWithdrawal.new(
    amount: 10_000,
    external_id: '123',
    description: 'Sending back'
  )
)

puts withdrawal
```

**Note**: Instead of using Withdrawal objects, you can also pass each withdrawal element in dictionary format

### Get an IssuingWithdrawal

After its creation, information on a withdrawal may be retrieved by its id.

```ruby
require('starkinfra')

withdrawal = StarkInfra::IssuingWithdrawal.get('5155165527080960')

puts withdrawal
```

### Query IssuingWithdrawals

You can get a list of created withdrawals given some filters.

```ruby
require('starkinfra')

withdrawals = StarkInfra::IssuingWithdrawal.query(
  limit: 10,
  after: '2022-01-01',
  before: '2022-01-20',
)

withdrawals.each do |withdrawal|
  puts withdrawal
end
```

### Get your IssuingBalance

To know how much money you have available to run authorizations, run:

```ruby
require('starkinfra')

balance = StarkInfra::IssuingBalance.get()

puts balance
```

### Query IssuingTransactions

To understand your balance changes (issuing statement), you can query
transactions. Note that our system creates transactions for you when
you make purchases, withdrawals, receive issuing invoice payments, for example.

```ruby
require('starkinfra')

transactions = StarkInfra::IssuingTransaction.query(
  limit: 10,
  after: '2022-01-01',
  before: '2022-01-20',
)

transactions.each do |transaction|
  puts transaction
end
```

### Get an IssuingTransaction

You can get a specific transaction by its id:

```ruby
require('starkinfra')

transaction = StarkInfra::IssuingTransaction.get('5155165527080960')

puts transaction
```

### Issuing Enums

#### Query MerchantCategories

You can query any merchant categories using this resource.
You may also use MerchantCategories to define specific category filters in IssuingRules.
Either codes (which represents specific MCCs) or types (code groups) will be accepted as filters.

```ruby
require('starkinfra')

categories = StarkInfra::MerchantCategory.query(
  search: 'food'
)

categories.each do |category|
  puts category
end
```

#### Query MerchantCountries

You can query any merchant countries using this resource.
You may also use MerchantCountries to define specific country filters in IssuingRules.

```ruby
require('starkinfra')

countries = StarkInfra::MerchantCountry.query(
  search: 'brazil'
)

countries.each do |country|
  puts country
end
```

#### Query CardMethods

You can query available card methods using this resource.
You may also use CardMethods to define specific purchase method filters in IssuingRules.

```ruby
require('starkinfra')

methods = StarkInfra::CardMethod.query(
  search: 'token',
)

methods.each do |method|
  puts method
end
```

## Pix

### Create PixRequests
You can create a Pix request to charge a user:

```ruby
require('starkinfra')

requests = StarkInfra::PixRequest.create(
  [
    StarkInfra::PixRequest.new(
      amount: 100,  # (R$ 1.00)
      external_id: '141234121',  # so we can block anything you send twice by mistake
      sender_branch_code: '0000',
      sender_account_number: '00000-0',
      sender_account_type: 'checking',
      sender_name: 'Tyrion Lannister',
      sender_tax_id: '012.345.678-90',
      receiver_bank_code: '00000001',
      receiver_branch_code: '0001',
      receiver_account_number: '00000-1',
      receiver_account_type: 'checking',
      receiver_name: 'Jamie Lannister',
      receiver_tax_id: '45.987.245/0001-92',
      end_to_end_id: 'E20018183202201201450u34sDGd19lz',
      description: 'For saving my life',
    ),
    StarkInfra::PixRequest.new(
      amount: 200,  # (R$ 2.00)
      external_id: '2135613462',  # so we can block anything you send twice by mistake
      sender_account_number: '00000-0',
      sender_branch_code: '0000',
      sender_account_type: 'checking',
      sender_name: 'Arya Stark',
      sender_tax_id: '012.345.678-90',
      receiver_bank_code: '00000001',
      receiver_account_number: '00000-1',
      receiver_branch_code: '0001',
      receiver_account_type: 'checking',
      receiver_name: 'John Snow',
      receiver_tax_id: '012.345.678-90',
      end_to_end_id: 'E20018183202201201450u34sDGd19lz',
      tags: ['Needle', 'sword'],
    )
  ]
)

requests.each do |request|
  puts request
end
```

**Note**: Instead of using Pix request objects, you can also pass each transaction element in hash format

### Query PixRequests

You can query multiple Pix requests according to filters.

```ruby
require('starkinfra')

requests = StarkInfra::PixRequest.query(
  after: '2022-01-01',
  before: '2022-01-10'
)

requests.each do |request|
  puts request
end
```

### Get a PixRequest

After its creation, information on a Pix request may be retrieved by its id. Its status indicates whether it has been paid.

```ruby
require('starkinfra')

request = StarkInfra::PixRequest.get('5155165527080960')

puts request
```

### Process PixRequest authorization requests

It's easy to process authorization requests that arrived in your handler. Remember to pass the
signature header so the SDK can make sure it's StarkInfra that sent you the event.

```ruby
require('starkinfra')

request = listen_requests()  # this is your handler to listen for authorization requests

pix_request = StarkInfra::PixRequest.parse(
  content: request.body.read, 
  signature: request.headers['Digital-Signature']
)

puts pix_request
```

### Query PixRequest logs

You can query Pix request logs to better understand Pix request life cycles. 

```ruby
require('starkinfra')

logs = StarkInfra::PixRequest::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get a PixRequest log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::PixRequest::Log.get('5155165527080960')

puts log
```

### Create PixReversals

You can reverse a PixRequest either partially or totally using a PixReversal.

```ruby
require('starkinfra')

reversal = StarkInfra::PixReversal.create([
  StarkInfra::PixReversal.new(
    amount: 100,
    end_to_end_id: StarkInfra::EndToEndId.create(bank_code),
    external_id: 'my_external_id',
    reason: 'bankError',
  )
])

puts reversal
```

### Query PixReversals 

You can query multiple Pix reversals according to filters. 

```ruby
require('starkinfra')

reversals = StarkInfra::PixReversal.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

reversals.each do |reversal|
  puts reversal
end
```

### Get a PixReversal

After its creation, information on a Pix reversal may be retrieved by its id.
Its status indicates whether it has been successfully processed.

```ruby
require('starkinfra')

reversal = StarkInfra::PixReversal.get('5155165527080960')

puts reversal
```

### Process PixReversal authorization requests

It's easy to process authorization requests that arrived at your endpoint.
Remember to pass the signature header so the SDK can make sure it's StarkInfra that sent you the event.
If you do not approve or decline the authorization within 1 second, the authorization will be denied.

```ruby
require('starkinfra')

reversal = listen_reversals()  # this is your handler to listen for authorization reversals

pix_reversal = StarkInfra::PixReversal.parse(
  content: reversal.body.read, 
  signature: reversal.headers['Digital-Signature']
)

puts pix_reversal
```


### Query PixReversal logs

You can query Pix reversal logs to better understand Pix reversal life cycles. 

```ruby
require('starkinfra')

logs = StarkInfra::PixReversal::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get a PixReversal log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::PixReversal::Log.get('5155165527080960')

puts log
```

### Get your PixBalance

To know how much money you have in your workspace, run:

```ruby
require('starkinfra')

balance = StarkInfra::PixBalance.get()

puts balance
```

### Create a PixStatement

Statements are generated directly by the Central Bank and are only available for direct participants.
To create a statement of all the transactions that happened on your account during a specific day, run:

```ruby
require('starkinfra')

statement = StarkInfra::PixStatement.create([
  StarkInfra::PixStatement.new(
    after: '2022-01-01', # This is the date that you want to create a statement.
    before: '2022-01-01', # After and before must be the same date.
    type: 'transaction' # Options are 'interchange', 'interchangeTotal', 'transaction'.
  )
])

puts statement
```

### Query PixStatements

You can query multiple Pix statements according to filters. 

```ruby
require('starkinfra')

statements = StarkInfra::PixStatement.query(
  limit: 50,
)

statements.each do |statement|
  puts statement
end
```

### Get a PixStatement

Statements are only available for direct participants. To get a Pix statement by its id:

```ruby
require('starkinfra')

statement = StarkInfra::PixStatement.get('5155165527080960')

puts statement
```

### Get a PixStatement .csv file

To get the .csv file corresponding to a Pix statement using its id, run:

```ruby
require('starkinfra')

csv = StarkInfra::PixStatement.csv('5155165527080960')

File.binwrite('statement.zip', csv)
```

#### Create a PixKey

You can create a Pix Key to link a bank account information to a key id:

```ruby
require('starkinfra')

key = StarkInfra::PixKey.create(
  StarkInfra::PixKey.new(
    account_created: '2022-02-01T00:00:00.00',
    account_number: '00000',
    account_type: 'savings',
    branch_code: '0000',
    name: 'Jamie Lannister',
    tax_id: '012.345.678-90',
    id: '+5511989898989',
  )
)

puts key
```

#### Query PixKeys

You can query multiple Pix keys you own according to filters.

```ruby
require('starkinfra')

keys = StarkInfra::PixKey.query(
  limit: 1,
  after: '2022-01-01',
  before: '2022-01-12',
  status: 'registered',
  tags: ['iron', 'bank'],
  ids: ['+5511989898989'],
  type: 'phone'
)

keys.each do |key|
  puts key
end
```

#### Get a PixKey

Information on a Pix key may be retrieved by its id and the tax ID of the consulting agent.
An endToEndId must be informed so you can link any resulting purchases to this query,
avoiding sweep blocks by the Central Bank.

```ruby
require('starkinfra')

key = StarkInfra::PixKey.get(
  '5155165527080960',
  payer_id: '012.345.678-90',
  end_to_end_id: StarkInfra::EndToEndId.create('20018183'),
)

puts key
```

#### Patch a PixKey

Update the account information linked to a Pix Key.

```ruby
require('starkinfra')

key = StarkInfra::PixKey.update(
  '+5511989898989',
  reason: 'branchTransfer',
  name: 'Jamie Lannister'
)

puts key
```

#### Cancel a PixKey

Cancel a specific Pix Key using its id.

```ruby
require('starkinfra')

key = StarkInfra::PixKey.cancel('5155165527080960')

puts key
```

#### Query PixKey logs

You can query Pix key logs to better understand a Pix key life cycle.

```ruby
require('starkinfra')

logs = StarkInfra::PixKey::Log.query(
  limit: 50, 
  ids: ['5729405850615808'],
  after: '2022-01-01',
  before: '2022-01-20',
  types: ['created'],
  key_ids: ['+5511989898989']
)

logs.each do |log|
  puts log
end
```

#### Get a PixKey log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::PixKey::Log.get('5155165527080960')

puts log
```

#### Create a PixClaim

You can create a Pix claim to request the transfer of a Pix key from another bank to one of your accounts:

```ruby
require('starkinfra')

claim = StarkInfra::PixClaim.create(
  StarkInfra::PixClaim.new(
    account_created: '2022-02-01T00:00:00.00',
    account_number: '5692908409716736',
    account_type: 'checking',
    branch_code: '0000',
    name: 'testKey',
    tax_id: '012.345.678-90',
    key_id: '+5511989898989'
  )
)

puts claim
```

#### Query PixClaims

You can query multiple Pix claims according to filters.

```ruby
require('starkinfra')

claims = StarkInfra::PixClaim.query(
  limit: 1,
  after: '2022-01-01',
  before: '2022-01-12',
  status: 'registered',
  ids: ['5729405850615808'],
  type: 'ownership',
  agent: 'claimed',
  key_type: 'phone',
  key_id: '+5511989898989'
)

claims.each do |claim|
  puts claim
end
```

#### Get a PixClaim

After its creation, information on a Pix claim may be retrieved by its id.

```ruby
require('starkinfra')

claim = StarkInfra::PixClaim.get('5155165527080960')

puts claim
```

#### Patch a PixClaim

A Pix claim can be confirmed or canceled by patching its status.
A received Pix claim must be confirmed by the donor to be completed.
Ownership Pix claims can only be canceled by the donor if the reason is "fraud".
A sent Pix claim can also be canceled.

```ruby
require('starkinfra')

claim = StarkInfra::PixClaim.update(
  '5155165527080960',
  status: 'confirmed'
)

puts claim
```

#### Query PixClaim logs

You can query Pix claim logs to better understand Pix claim life cycles.

```ruby
require('starkinfra')

logs = StarkInfra::PixClaim::Log.query(
  limit: 50, 
  ids: ['5729405850615808'],
  after: '2022-01-01',
  before: '2022-01-20',
  types: ['registered'],
  claim_ids: ['5719405850615809']
)

logs.each do |log|
  puts log
end
```

#### Get a PixClaim log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::PixClaim::Log.get('5155165527080960')

puts log
```

#### Create a PixDirector

To register the Pix director contact information at the Central Bank, run the following:

```ruby
require('starkinfra')

director = StarkInfra::PixDirector.create(
  StarkInfra::PixDirector.new(
    name: 'Edward Stark',
    tax_id: '03.300.300/0001-00',
    phone: '+5511999999999',
    email: 'ned.stark@company.com',
    password: '12345678',
    team_email: 'pix.team@company.com',
    team_phones: ['+5511988889999', '+5511988889998']
  )
)

puts director
```

#### Create PixInfractions

Pix Infraction reports are used to report transactions that raise fraud suspicion, to request a refund or to
reverse a refund. Infraction reports can be created by either participant of a transaction.

```ruby
require('starkinfra')

infractions = StarkInfra::PixInfraction.create([
  StarkInfra::PixInfraction.new(
    reference_id: 'E20018183202201201450u34sDGd19lz',
    type: 'fraud',
  )
])

infractions.each do |infraction|
  puts infraction
end
```

#### Query PixInfractions

You can query multiple infraction reports according to filters.

```ruby
require('starkinfra')

infractions = StarkInfra::PixInfraction.query(
  limit: 1,
  after: '2022-01-01',
  before: '2022-01-12',
  status: 'delivered',
  ids: ['5155165527080960']
)

infractions.each do |infraction|
  puts infraction
end
```

#### Get a PixInfraction

After its creation, information on a Pix infraction may be retrieved by its id.

```ruby
require('starkinfra')

infraction = StarkInfra::PixInfraction.get('5155165527080960')

puts infraction
```

#### Patch a PixInfraction

A received Pix infraction can be confirmed or declined by patching its status.
After a Pix infraction is patched, its status changes to closed.

```ruby
require('starkinfra')

infraction = StarkInfra::PixInfraction.update(
  id: '5155165527080960',
  result: 'agreed'
)

puts infraction
```

#### Cancel a PixInfraction

Cancel a specific Pix Infraction using its id.

```ruby
require('starkinfra')

infraction = StarkInfra::PixInfraction.cancel('5155165527080960')

puts infraction
```

#### Query PixInfraction logs

You can query infraction report logs to better understand their life cycles.

```ruby
require('starkinfra')

logs = StarkInfra::PixInfraction::Log.query(
  limit: 50, 
  ids: ['5729405850615808'],
  after: '2022-01-01',
  before: '2022-01-20',
  types: ['created'],
  infraction_ids: ['5155165527080960']
)

logs.each do |log|
  puts log
end
```

#### Get a PixInfraction log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::PixInfraction::Log.get('5155165527080960')

puts log 
```

#### Create PixChargebacks

A Pix chargeback can be created when fraud is detected on a transaction or a system malfunction
results in an erroneous transaction.

```ruby
require('starkinfra')

chargebacks = StarkInfra::PixChargeback.create([
  StarkInfra::PixChargeback.new(
    amount: 100,
    reference_id: 'E20018183202201201450u34sDGd19lz',
    reason: 'fraud',
  )
])

chargebacks.each do |chargeback|
  puts chargeback
end
```

#### Query PixChargebacks

You can query multiple Pix chargebacks according to filters.

```ruby
require('starkinfra')

chargebacks = StarkInfra::PixChargeback.query(
  limit: 1,
  after: '2022-01-01',
  before: '2022-01-12',
  status: 'registered',
  ids: ['5155165527080960']
)

chargebacks.each do |chargeback|
  puts chargeback
end
```

#### Get a PixChargeback

After its creation, information on a Pix Chargeback may be retrieved by its.

```ruby
require('starkinfra')

chargeback = StarkInfra::PixChargeback.get('5155165527080960')

puts chargeback
```

#### Update a PixChargeback

A received Pix Chargeback can be accepted or rejected by patching its status.
After a Pix Chargeback is patched, its status changes to closed.

```ruby
require('starkinfra')

chargeback = StarkInfra::PixChargeback.update(
  '5155165527080960',
  result: 'accepted',
  reversal_reference_id: StarkInfra::ReturnId.create('20018183'),
)

puts chargeback
```

#### Cancel a PixChargeback

Cancel a specific Pix Chargeback using its id.

```ruby
require('starkinfra')

chargeback = StarkInfra::PixChargeback.cancel('5155165527080960')

puts chargeback
```

#### Query PixChargeback logs

You can query Pix chargeback logs to better understand Pix chargeback life cycles.

```ruby
require('starkinfra')

logs = StarkInfra::PixChargeback::Log.query(
  limit: 50, 
  ids: ['5729405850615808'],
  after: '2022-01-01',
  before: '2022-01-20',
  types: ['created'],
  chargeback_ids: ['5155165527080960']
)

logs.each do |log|
  puts log
end
```

#### Get a PixChargeback log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::PixChargeback::Log.get('5155165527080960')

puts log
```

#### Query PixDomains

Here you can list all Pix Domains registered at the Brazilian Central Bank. The Pix Domain object displays the domain
name and the QR Code domain certificates of registered Pix participants able to issue dynamic QR Codes.

```ruby
require('starkinfra')

domains = StarkInfra::PixDomain.query

domains.each do |domain|
  puts domain
end
```

### Create StaticBrcodes

StaticBrcodes store account information via a BR Code or an image (QR code)
that represents a PixKey and a few extra fixed parameters, such as an amount
and a reconciliation ID. They can easily be used to receive Pix transactions.

```ruby
require('starkinfra')

brcodes = StarkInfra::StaticBrcode.create(
  StarkInfra::StaticBrcode.new(
    name: "Jamie Lannister",
    key_id: "+5511988887777",
    amount: 0,
    reconciliation_id: "123",
    city: "São Paulo"
  )
)

brcodes.each do |brcode|
  puts brcode
end
```

### Query StaticBrcodes

You can query multiple StaticBrcodes according to filters.

```ruby
require('starkinfra')

brcodes = StarkInfra::StaticBrcode.query(
  limit: 4,
  after: '2022-01-01',
  before: '2022-01-20',
)

brcodes.each do |brcode|
  puts brcode
end
```

### Get a StaticBrcodes

After its creation, information on a StaticBrcode may be retrieved by its UUID.

```ruby
require('starkinfra')

brcode = StarkInfra::StaticBrcode.get("5ddde28043a245c2848b08cf315effa2")

puts brcode
```

### Create DynamicBrcodes

BR Codes store information represented by Pix QR Codes, which are used to send
or receive Pix transactions in a convenient way.
DynamicBrcodes represent charges with information that can change at any time,
since all data needed for the payment is requested dynamically to an URL stored
in the BR Code. Stark Infra will receive the GET request and forward it to your
registered endpoint with a GET request containing the UUID of the BR Code for
identification.

```ruby
require('starkinfra')

brcodes = StarkInfra::DynamicBrcode.create([
  StarkInfra::DynamicBrcode.new(
    name: "Jamie Lannister",
    city: "Rio de Janeiro",
    external_id: "my-external-id/1234",
    type: "instant"
  )
])

brcodes.each do |brcode|
  puts brcode
end
```

### Query DynamicBrcodes

You can query multiple DynamicBrcodes according to filters.

```ruby
require('starkinfra')

brcodes = StarkInfra::DynamicBrcode.query(
  limit: 4,
  after: '2022-01-01',
  before: '2022-02-01',
  uuids: %w[68a6af231c594a40bd11a80cb980c400 ba989316ffeb4500a60c3636eca90d7e],
)

brcodes.each do |brcode|
  puts brcode
end
```

### Get a DynamicBrcode

After its creation, information on a DynamicBrcode may be retrieved by its UUID.

```ruby
require('starkinfra')

brcode = StarkInfra::DynamicBrcode.get("ac7caa14e601461dbd6b12bf7e4cc48e")

puts brcode
```

### Verify a DynamicBrcode read

When a DynamicBrcode is read by your user, a GET request will be made to the your regitered URL to
retrieve additional information needed to complete the transaction.
Use this method to verify the authenticity of a GET request received at your registered endpoint.
If the provided digital signature does not check out with the StarkInfra public key, 
a stark.exception.InvalidSignatureException will be raised.

```ruby
require('starkinfra')

request = listen()  # this is the method you made to get the read requests posted to your registered endpoint

uuid = StarkInfra::Dynamicbrcode.verify(
    signature=request.headers["Digital-Signature"],
    uuid=get_uuid(request.url) # you should implement this method to extract the UUID from the request's URL
)

puts uuid
```

### Answer to a Due DynamicBrcode read

When a Due DynamicBrcode is read by your user, a GET request containing
the BR Code UUID will be made to your registered URL to retrieve additional
information needed to complete the transaction.

The GET request must be answered in the following format within 5 seconds
and with an HTTP status code 200.

```ruby
require('starkinfra')

request = listen()  # this is the method you made to get the read requests posted to your registered endpoint

uuid = StarkInfra::DynamicBrcode.verify(
  signature: request.headers["Digital-Signature"], 
  content: get_uuid(request.url) # you should implement this method to extract the UUID from the request's URL
)

invoice = get_my_invoice(uuid) # you should implement this method to get the information of the BR Code from its uuid

send_response(  # you should also implement this method to respond the read request
  StarkInfra::DynamicBrcode.response_due(
    version: invoice.version,
    created: invoice.created,
    due: invoice.due,
    key_id: invoice.key_id,
    status: invoice.status,
    reconciliation_id: invoice.reconciliation_id,
    nominal_amount: invoice.nominal_amount,
    sender_name: invoice.sender_name,
    receiver_name: invoice.receiver_name,
    receiver_street_line: invoice.receiver_street_line,
    receiver_city: invoice.receiver_city,
    receiver_state_code: invoice.receiver_state_code,
    receiver_zip_code: invoice.receiver_zip_code,
  )
)
```

### Answer to an Instant DynamicBrcode read

When an Instant DynamicBrcode is read by your user, a GET request
containing the BR Code UUID will be made to your registered URL to retrieve
additional information needed to complete the transaction.
The get request must be answered in the following format
within 5 seconds and with an HTTP status code 200.

```ruby
require('starkinfra')

request = listen()  # this is the method you made to get the read requests posted to your registered endpoint

uuid = StarkInfra::DynamicBrcode.verify(
  signature: request.headers["Digital-Signature"], 
  content: get_uuid(request.url) # you should implement this method to extract the UUID from the request's URL
)

invoice = get_my_invoice(uuid) # you should implement this method to get the information of the BR Code from its uuid

send_response(  # you should also implement this method to respond the read request
  StarkInfra::DynamicBrcode.response_instant(
    version: invoice.version,
    created: invoice.created,
    key_id: invoice.key_id,
    status: invoice.status,
    reconciliation_id: invoice.reconciliation_id,
    amount: invoice.amount,
    cashier_type: invoice.cashier_type,
    cashier_bank_code: invoice.cashier_bank_code,
    cash_amount: invoice.cash_amount,
  )
)
```

## Create BrcodePreviews
You can create BrcodePreviews to preview BR Codes before paying them.

```ruby
require('starkinfra')

previews = StarkInfra::BrcodePreview.create([
  StarkInfra::BrcodePreview.new(
    id: "00020126420014br.gov.bcb.pix0120nedstark@hotmail.com52040000530398654075000.005802BR5909Ned Stark6014Rio de Janeiro621605126674869738606304FF71"
  )
])

previews.each do |preview|
  puts preview
end
```

## Credit Note

### Create CreditNotes
You can create a CreditNote to generate a CCB contract:

```ruby
require('starkinfra')

notes = StarkInfra::CreditNote.create([
  StarkInfra::CreditNote.new(
    template_id: '0123456789101112',
    name: 'Jamie Lannister',
    tax_id: '012.345.678-90',
    nominal_amount: 100000,
    scheduled: '2022-04-28',
    invoices: [
      StarkInfra::CreditNote::Invoice.new(
        due: '2023-06-25',
        amount: 120000,
        fine: 10,
        interest: 2,
        tax_id: '012.345.678-90',
        name: 'Jamie Lannister'
      )
    ],
    payment: StarkInfra::CreditNote::Transfer.new(
      bank_code: '00000000',
      branch_code: '1234',
      account_number: '129340-1',
      name: 'Jamie Lannister',
      tax_id: '012.345.678-90',
      amount: 100000,
    ),
    payment_type: 'transfer',
    signers: [
      StarkInfra::CreditNote::Signer.new(
        name: 'Jamie Lannister',
        contact: 'jamie.lannister@gmail.com',
        method: 'link'
      )
    ],
    external_id: '1234',
    street_line_1: 'Rua ABC',
    street_line_2: 'Ap 123',
    district: 'Jardim Paulista',
    city: 'São Paulo',
    state_code: 'SP',
    zip_code: '01234-567'
  )
])

notes.each do |note|
  puts note
end
```

**Note**: Instead of using CreditNote objects, you can also pass each element in hash format

### Query CreditNotes

You can query multiple credit notes according to filters.

```ruby
require('starkinfra')

notes = StarkInfra::CreditNote.query(
  limit: 10,
  after: DateTime.new(2020, 1, 1),
  before: DateTime.new(2020, 4, 1),
  status: 'success',
  tags: %w[iron, suit]
)

notes.each do |note|
  puts note
end
```

### Get a CreditNote

After its creation, information on a credit note may be retrieved by its id.

```ruby
require('starkinfra')

note = StarkInfra::CreditNote.get('5155165527080960')

puts note
```

### Cancel a CreditNote

You can cancel a credit note if it has not been signed yet.

```ruby
require('starkinfra')

note = StarkInfra::CreditNote.cancel('5155165527080960')

puts note
```

### Query CreditNote logs

You can query credit note logs to better understand credit note life cycles.

```ruby
require('starkinfra')

logs = StarkInfra::CreditNote::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20'
)

logs.each do |log|
  puts log
end
```

### Get a CreditNote log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::CreditNote::Log.get('5155165527080960')

puts log
```

## Credit Preview
You can preview different types of credits before creating them (Currently we only have credit note previews):

### Create CreditNotePreviews
You can preview Credit Notes before the creation CCB contracts:

```ruby
require('starkinfra')

previews = StarkInfra::CreditPreview.create([
   StarkInfra::CreditPreview.new(
     credit: StarkInfra::CreditNotePreview.new(
       type: "price",
       nominal_amount: 100000,
       scheduled: '2022-07-10',
       tax_id: "20.018.183/0001-80",
       initial_due: '2022-07-10',
       nominal_interest: 15,
       count: 15,
       interval: "year",
       rebate_amount: 900,
     ),
     type: "credit-note"
   ),
  StarkInfra::CreditPreview.new(
     credit: StarkInfra::CreditNotePreview.new(
       type: "bullet",
       nominal_amount: 100000,
       scheduled: '2022-07-10',
       tax_id: "20.018.183/0001-80",
       initial_due: '2022-07-10',
       nominal_interest: 15,
       rebate_amount: 0,
     ),
     type: "credit-note",
  ),
  StarkInfra::CreditPreview.new(
     credit: StarkInfra::CreditNotePreview.new(
       type: "price",
       nominal_amount: 100000,
       scheduled: '2022-07-10',
       tax_id: "20.018.183/0001-80",
       initial_due: '2022-07-10',
       nominal_interest: 15,
       count: 15,
       interval: "year",
       rebate_amount: 900,
     ),
     type: "credit-note",
  ),
  StarkInfra::CreditPreview.new(
     credit: StarkInfra::CreditNotePreview.new(
      type: "american",
      nominal_amount: 100000,
      scheduled: '2022-07-10',
      tax_id: "20.018.183/0001-80",
      initial_due: '2022-07-10',
      nominal_interest: 15,
      count: 5,
      interval: "month",
      rebate_amount: 900,
      )
  )]
)

previews.each do |preview|
  puts preview
end
```

**Note**: Instead of using CreditPreview objects, you can also pass each element in dictionary format

## Identity

Several operations, especially credit ones, require that the identity
of a person or business is validated beforehand.

Identities are validated according to the following sequence:

1. The Identity resource is created for a specific Tax ID
2. Documents are attached to the Identity resource
3. The Identity resource is updated to indicate that all documents have been attached
4. The Identity is sent for validation and returns a webhook notification to reflect
the success or failure of the operation

### Create IndividualIdentities

You can create an IndividualIdentity to validate a document of a natural person

```ruby
require('starkinfra')

identities = StarkInfra::IndividualIdentity.create([
  StarkInfra::IndividualIdentity.new(
    name: 'Walter White',
    tax_id: '012.345.678-90',
    tags: ['breaking', 'bad']
  )
])

identities.each do |identity|
  puts identity
end
```

**Note**: Instead of using IndividualIdentity objects, you can also pass each element in dictionary format

### Query IndividualIdentity

You can query multiple individual identities according to filters.

```ruby
require('starkinfra')

identities = StarkInfra::IndividualIdentity.query(
  limit: 10,
  after: '2020-01-01',
  before: '2020-04-01',
  status: 'success',
  tags: ['breaking', 'bad'],
)

identities.each do |identity|
  puts identity
end
```

### Get an IndividualIdentity

After its creation, information on an individual identity may be retrieved by its id.

```ruby
require('starkinfra')

identity = StarkInfra::IndividualIdentity.get('5155165527080960')

puts identity
```

### Update an IndividualIdentity

You can update a specific identity status to "processing" for send it to validation.

```ruby
require('starkinfra')

identity = StarkInfra::IndividualIdentity.update('5155165527080960', status: 'processing')

puts identity
```

**Note**: Before sending your individual identity to validation by patching its status, you must send all the required documents using the create method of the CreditDocument resource. Note that you must reference the individual identity in the create method of the CreditDocument resource by its id.

### Cancel an IndividualIdentity

You can cancel an individual identity before updating its status to processing.

```ruby
require('starkinfra')

identity = StarkInfra::IndividualIdentity.cancel('5155165527080960')

puts identity
```

### Query IndividualIdentity logs

You can query individual identity logs to better understand individual identity life cycles. 

```ruby
require('starkinfra')

logs = StarkInfra::IndividualIdentity::Log.query(
  limit: 50, 
  after: '2022-01-01',
  before: '2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get an IndividualIdentity log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::IndividualIdentity::Log.get('5155165527080960')

print(log)
```

### Create IndividualDocuments

You can create an individual document to attach images of documents to a specific individual Identity.
You must reference the desired individual identity by its id.

```ruby
require('starkinfra')

documents = StarkInfra::IndividualDocument.create([
  StarkInfra::IndividualDocument.new(
    type: 'identity-front',
    content: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD...',
    identity_id: '5155165527080960',
    tags: ['breaking', 'bad']
  ),
  StarkInfra::IndividualDocument.new(
    type: 'identity-back',
    content: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD...',
    identity_id: '5155165527080960',
    tags: ['breaking', 'bad']
  ),
  StarkInfra::IndividualDocument.new(
    type: 'selfie',
    content: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD...',
    identity_id: '5155165527080960',
    tags: ['breaking', 'bad']
  )
])

documents.each do |document|
  puts document
end
```

**Note**: Instead of using IndividualDocument objects, you can also pass each element in dictionary format

### Query IndividualDocument

You can query multiple individual documents according to filters.

```ruby
require('starkinfra')

documents = StarkInfra::IndividualIdentity.query(
  limit: 10,
  after: '2020-01-01',
  before: '2020-04-01',
  status: 'success',
  tags: ['breaking', 'bad'],
)

documents.each do |document|
  puts document
end
```

### Get an IndividualDocument

After its creation, information on an individual document may be retrieved by its id.

```ruby
require('starkinfra')

document = StarkInfra::IndividualDocument.get('5155165527080960')

puts document
```
  
### Query IndividualDocument logs

You can query individual document logs to better understand individual document life cycles. 

```ruby
require('starkinfra')

logs = StarkInfra::IndividualDocument::Log.query(
  limit=50, 
  after='2022-01-01',
  before='2022-01-20',
)

logs.each do |log|
  puts log
end
```

### Get an IndividualDocument log

You can also get a specific log by its id.

```ruby
require('starkinfra')

log = StarkInfra::IndividualDocument::Log.get('5155165527080960')

puts log
```

### Webhook

#### Create a webhook subscription

To create a webhook subscription and be notified whenever an event occurs, run:

```ruby
require('starkinfra')

webhook = StarkInfra::Webhook.create(
  StarkInfra::Webhook.new(
  url: 'https://webhook.site/dd784f26-1d6a-4ca6-81cb-fda0267761ec',
  subscriptions: %w[pix-infraction pix-chargeback]
  )
)

puts webhook
```

### Query webhooks

To search for registered webhooks, run:

```ruby
require('starkinfra')

webhooks = StarkInfra::Webhook.query()

webhooks.each do |webhook|
  puts webhook
end
```

### Get a webhook

You can get a specific webhook by its id.

```ruby
require('starkinfra')

webhook = StarkInfra::Webhook.get('1082736198236817')

puts webhook
```

### Delete a webhook

You can also delete a specific webhook by its id.

```ruby
require('starkinfra')

webhook = StarkInfra::Webhook.delete('1082736198236817')

puts webhook
```

## Webhook Events

### Process webhook events

It's easy to process events that arrived in your webhook. Remember to pass the
signature header so the SDK can make sure it's StarkInfra that sent you
the event.

```ruby
require('starkinfra')

response = listen()  # this is the method you made to get the events posted to your webhook endpoint

event = StarkInfra::Event.parse(
  content: response.data.decode('utf-8'),
  signature: response.headers['Digital-Signature'],
)

if event.subscription.include? 'pix-request'
  puts event.log.request
elsif event.subscription.include? 'pix-reversal'
  puts event.log.reversal
elsif event.subscription == 'pix-key' 
  puts event.log.key
elsif event.subscription == 'pix-claim' 
  puts event.log.claim
elsif event.subscription == 'pix-infraction' 
  puts event.log.infraction
elsif event.subscription == 'pix-chargeback' 
  puts event.log.chargeback
elsif event.subscription == 'credit-note'
  puts event.log.note
elsif event.subscription == 'issuing-card'
  puts event.log.card
elsif event.subscription == 'issuing-invoice'
  puts event.log.invoice
elsif event.subscription == 'issuing-purchase'
  puts event.log.purchase
end
```

## Query webhook events

To search for webhook events, run:

```ruby
require('starkinfra')

events = StarkInfra::Event.query(after: '2020-03-20', is_delivered: false)

events.each do |event|
  puts event
end
```

## Get a webhook event

You can get a specific webhook event by its id.

```ruby
require('starkinfra')

event = StarkInfra::Event.get('4828869076975616')

puts event
```

## Delete a webhook event

You can also delete a specific webhook event by its id.

```ruby
require('starkinfra')

event = StarkInfra::Event.delete('4828869076975616')

puts event
```

## Set webhook events as delivered

This can be used in case you've lost events.
With this function, you can manually set events retrieved from the API as
"delivered" to help future event queries with `is_delivered: false`.

```ruby
require('starkinfra')

event = StarkInfra::Event.update('5892075044208640', is_delivered: true)

puts event
```

## Query failed webhook event delivery attempts information

You can also get information on failed webhook event delivery attempts.

```ruby
require('starkinfra')

attempts = StarkInfra::Event::Attempt.query(after: '2020-03-20');

attempts.each do |attempt|
  puts attempt
end
```

## Get a failed webhook event delivery attempt information

To retrieve information on a single attempt, use the following function:

```ruby
require('starkinfra')

attempt = StarkInfra::Event::Attempt.get('1616161616161616')

puts attempt
```

# Handling errors

The SDK may raise one of four types of errors: __InputErrors__, __InternalServerError__, __UnknownError__, __InvalidSignatureError__

__InputErrors__ will be raised whenever the API detects an error in your request (status code 400).
If you catch such an error, you can get its elements to verify each of the
individual errors that were detected in your request by the API.
For example:

```ruby
require('starkinfra')

begin
  reversal = StarkInfra::PixReversal.create(
  [
    StarkInfra::PixReversal.new(
      amount: 100,
      end_to_end_id: 'E00000000202201060100rzsJzG9PzMg',
      external_id: 'my_external_id',
      reason: 'bankError',
    )
  ])
rescue StarkInfra::Error::InputErrors => e
  e.errors.each do |error|
    puts error.code
    puts error.message
  end
end
```

__InternalServerError__ will be raised if the API runs into an internal error.
If you ever stumble upon this one, rest assured that the development team
is already rushing in to fix the mistake and get you back up to speed.

__UnknownError__ will be raised if a request encounters an error that is
neither __InputErrors__ nor an __InternalServerError__, such as connectivity problems.

__InvalidSignatureError__ will be raised specifically by StarkInfra::Event.parse()
when the provided content and signature do not check out with the Stark Infra public
key.

# Help and Feedback

If you have any questions about our SDK, just send us an email.
We will respond you quickly, pinky promise. We are here to help you integrate with us ASAP.
We also love feedback, so don't be shy about sharing your thoughts with us.

Email: help@starkbank.com

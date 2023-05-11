# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.


## [Unreleased]

## [0.3.0] - 2023-05-11
### Added
- IndividualDocument resource
- IndividualIdentity resource
- CreditHolmes resource
- IssuingDesign resource
- IssuingEmbossingRequest resource
- IssuingRestock resource
- IssuingStock resource
- pin attribute to update method in IssuingCard resource
- product_id attribute to IssuingPurchase resource
- payer_id and end_to_end_id parameter to BrcodePreview resource
- cashier_bank_code and description parameter to StaticBrcode resource
### Changed
- change nominal_amount and amount parameter to conditionally required to CreditNote resource

## [0.2.0] - 2022-10-04
### Added
- StaticBrcode resource
- BrcodePreview resource
- DynamicBrcode resource
- CardMethod sub-resource
- CreditPreview sub-resource
- MerchantCountry sub-resource
- MerchantCategory sub-resource
- CreditNotePreview sub-resource
- flow attribute to PixChargeback resource
- tags parameter to PixClaim, PixInfraction, Pix Chargeback resources
- tags parameter to query and page methods in PixChargeback, PixClaim and PixInfraction resources
- agent parameter to query and page methods in PixInfraction and PixChargeback resources
- expand parameter to create, get, query and page methods in IssuingHolder resource
- tax_amount and nominal_interest attributes to return only in CreditNote resource
- code attribute to IssuingProduct resource
- zip_code, purpose, is_partial_allowed, card_tags and holder_tags attributes to IssuingPurchase resource
- brcode, link and due attributes to IssuingInvoice resource
### Changed
- IssuingBin resource to IssuingProduct
- fine and interest attributes to return only in CreditNote::Invoice sub-resource
- expiration from returned-only attribute to optional parameter in the CreditNote resource
- settlement parameter to funding_type and client parameter to holder_type in Issuing Product resource
- bank_code parameter to claimer_bank_code in PixClaim resource
- agent parameter to flow in PixClaim and PixInfraction resources
- agent parameter to flow on query and page methods in PixClaim resource
- Creditnote.Signer sub-resource to CreditSigner resource
### Removed
- IssuingAuthorization resource
- category parameter from IssuingProduct resource
- bank_code attribute from PixReversal resource
- agent parameter from PixClaim::Log resource
- bacen_id parameter from PixChargeback and PixInfraction resources

## [0.1.0] - 2022-06-03
### Added
- credit receiver's billing address on CreditNote

## [0.0.3] - 2022-05-31
### Added
- Webhook subscriptions
- Webhook Events
- PixClaim resource for Indirect and Direct Participants
- PixKey resource for Indirect and Direct Participants
- PixInfraction resource for Indirect and Direct Participants
- PixChargeback resource for Indirect and Direct Participants
- PixDomain resource for Indirect and Direct Participants
- CreditNote resource for money lending with Stark Infra's endorsement
- IssuingAuthorization resource for Sub Issuers
- IssuingBalance resource for Sub Issuers
- IssuingBin resource for Sub Issuers
- IssuingCard resource for Sub Issuers
- IssuingHolder resource for Sub Issuers
- IssuingInvoice resource for Sub Issuers
- IssuingPurchase resource for Sub Issuers
- IssuingTransaction resource for Sub Issuers
- IssuingWithdrawal resource for Sub Issuers

## [0.0.2] - 2022-02-24
### Fixed:
- Fix workspace import error

## [0.0.1] - 2022-02-24
### Added
- PixRequest resource for Indirect and Direct Participants
- PixReversal resource for Indirect and Direct Participants
- PixDirector resource for Direct Participants
- PixBalance resource for Indirect and Direct Participants
- PixStatement resource for Direct Participants
- Event resource for webhook receptions

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Status'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP
@Consumption.ranked: true
define view entity ZCDS_STATUS_VH_ODA
  as select from zdt_status_oda
{
  key status_code        as StatusCode,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8
      status_description as StatusDescription
}

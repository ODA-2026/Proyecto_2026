@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Priority'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.dataCategory: #VALUE_HELP
@Consumption.ranked: true
define view entity ZCDS_PRIORITY_VH_ODA
  as select from zdt_priority_oda
{
  key priority_code        as PriorityCode,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8
      priority_description as PriorityDescription
}

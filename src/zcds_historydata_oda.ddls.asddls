@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Child - Data History'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS_HISTORYDATA_ODA as select from zdt_inct_h_oda
association to parent Z_R_INCIDENT_ODA as Incident on Incident.IncUuid = $projection.IncUuid
{
   key his_uuid as HisUuid,
   inc_uuid as IncUuid,
   his_id as HisId,
   previous_status as PreviousStatus,
   new_status as NewStatus,
   text as Text,
   local_created_by as LocalCreatedBy,
   local_created_at as LocalCreatedAt,
   local_last_changed_by as LocalLastChangedBy,
   local_last_changed_at as LocalLastChangedAt,
   last_changed_at as LastChangedAt,
   Incident
}

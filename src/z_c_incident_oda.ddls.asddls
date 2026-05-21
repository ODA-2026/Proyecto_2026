@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Proyección Incidencia'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_C_INCIDENT_ODA 
provider contract transactional_query
as projection on Z_R_INCIDENT_ODA
{
    key IncUuid,
    IncidentId,
    Title,
    Description,
    Status,
    Priority,
    CreatedDate,
    ChangedDate,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _HistoryData: redirected to composition child ZCDS_C_HISTORYDATA_ODA,
    _Status,
    _Priority
}

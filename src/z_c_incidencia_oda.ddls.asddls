@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Proyección Incidencia'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_C_INCIDENCIA_ODA 
provider contract transactional_query
as projection on Z_R_INCIDENCIA_ODA
{
    key IncUuid,
    IncidentId,
    Title,
    Description,
    Status,
    Priority,
    CreationDate,
    ChangedDate,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _HistoryData: redirected to composition child ZCDS_C_HISTORYDATA_ODA
}

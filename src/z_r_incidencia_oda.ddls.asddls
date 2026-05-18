@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Root - Incidencia'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_R_INCIDENCIA_ODA as select from zdt_inct_oda as Incidencia
composition[0..*] of ZCDS_HISTORYDATA_ODA as _HistoryData
{
    key Incidencia.inc_uuid as IncUuid,
    Incidencia.incident_id as IncidentId,
    Incidencia.title as Title,
    Incidencia.description as Description,
    Incidencia.status as Status,
    Incidencia.priority as Priority,
    Incidencia.creation_date as CreationDate,
    Incidencia.changed_date as ChangedDate,
    Incidencia.local_created_by as LocalCreatedBy,
    Incidencia.local_created_at as LocalCreatedAt,
    Incidencia.local_last_changed_by as LocalLastChangedBy,
    Incidencia.local_last_changed_at as LocalLastChangedAt,
    Incidencia.last_changed_at as LastChangedAt,
    _HistoryData // Make association public
}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Root - Incidencia'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_R_INCIDENT_ODA as select from zdt_inct_oda as Incident
composition[0..*] of ZCDS_HISTORYDATA_ODA as _HistoryData
association[1] to zdt_status_oda as _Status on _Status.status_code = $projection.Status
association[1] to zdt_priority_oda as _Priority on _Priority.priority_code = $projection.Priority
{
    key Incident.inc_uuid as IncUuid,
    @EndUserText.label: 'Incident ID'
    Incident.incident_id as IncidentId,
    @EndUserText.label: 'Title'
    Incident.title as Title,
    @EndUserText.label: 'Description'
    Incident.description as Description,
    @EndUserText.label: 'Status'
    Incident.status as Status,
    @EndUserText.label: 'Priority'
    Incident.priority as Priority,
    @EndUserText.label: 'Created Date'
    Incident.creation_date as CreatedDate,
    @EndUserText.label: 'Changed Date'
    Incident.changed_date as ChangedDate,
    Incident.local_created_by as LocalCreatedBy,
    Incident.local_created_at as LocalCreatedAt,
    Incident.local_last_changed_by as LocalLastChangedBy,
    Incident.local_last_changed_at as LocalLastChangedAt,
    Incident.last_changed_at as LastChangedAt,
    _HistoryData, // Make association public
    _Status,
    _Priority
}

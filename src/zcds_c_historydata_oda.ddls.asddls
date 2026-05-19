@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Projection Historial Data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS_C_HISTORYDATA_ODA as projection on ZCDS_HISTORYDATA_ODA
{
    key HisUuid,
    IncUuid,
    PreviousStatus,
    NewStatus,
    Text,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    Incident: redirected to parent Z_C_INCIDENT_ODA
}

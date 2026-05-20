@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Projection Historial Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCDS_C_HISTORYDATA_ODA as projection on ZCDS_HISTORYDATA_ODA
{
    key HisUuid,
    IncUuid,
    HisId,
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

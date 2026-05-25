CLASS lhc_Z_R_INCIDENT_ODA DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Incident RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS ChangeStatus FOR MODIFY
      IMPORTING keys FOR ACTION Incident~ChangeStatus RESULT result.

    METHODS FillFieldsCreationInc FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Incident~FillFieldsCreationInc.

    METHODS NewRecorHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~NewRecorHistory.

    METHODS CheckCreatedDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckCreatedDate.

    METHODS CheckDatesRange FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckDatesRange.

ENDCLASS.

CLASS lhc_Z_R_INCIDENT_ODA IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ChangeStatus.

    DATA: incidents_for_upd TYPE TABLE FOR UPDATE z_r_incident_oda.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<incident>).
      APPEND VALUE #( %tky = <incident>-%tky
                      Status = keys[ KEY id %tky = <incident>-%tky ]-%param-status ) TO incidents_for_upd.
    ENDLOOP.

    MODIFY ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    UPDATE
    FIELDS ( Status )
    WITH incidents_for_upd.

    read entities of z_r_incident_oda in local mode
    entity Incident
    all fields
    with corresponding #( keys )
    result data(incidents_updated_status).

    result = value #( for incident in incidents_updated_status ( %tky = incident-%tky
                                                                 %param = incident )  ).

  ENDMETHOD.

  METHOD FillFieldsCreationInc.
  ENDMETHOD.

  METHOD NewRecorHistory.
  ENDMETHOD.

  METHOD CheckCreatedDate.
  ENDMETHOD.

  METHOD CheckDatesRange.
  ENDMETHOD.

ENDCLASS.

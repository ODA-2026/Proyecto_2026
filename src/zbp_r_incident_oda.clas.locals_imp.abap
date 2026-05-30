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

    METHODS CheckCreatedDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckCreatedDate.

    METHODS CheckDatesRange FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckDatesRange.
    METHODS NewRecorHistory FOR MODIFY
      IMPORTING keys FOR ACTION Incident~NewRecorHistory.

    METHODS NewStatusToHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~NewStatusToHistory.

    METHODS CheckDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckDescription.

    METHODS CheckPriority FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckPriority.

    METHODS CheckTitle FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckTitle.

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

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(incidents_updated_status).

    result = VALUE #( FOR incident IN incidents_updated_status ( %tky = incident-%tky
                                                                 %param = incident )  ).

  ENDMETHOD.

  METHOD FillFieldsCreationInc.
  ENDMETHOD.

  METHOD CheckCreatedDate.

  READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( CreatedDate ChangedDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidencias).

    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).

      IF <Incidencia>-CreatedDate is initial.
        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD CheckDatesRange.

  READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( CreatedDate ChangedDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidencias).

    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).

      IF <Incidencia>-CreatedDate gt <Incidencia>-ChangedDate.
        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD NewRecorHistory.
  ENDMETHOD.

  METHOD NewStatusToHistory.
  ENDMETHOD.

  METHOD CheckDescription.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidencias).

    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).

      IF <Incidencia>-Description IS INITIAL.
        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD CheckPriority.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Priority )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidencias).

    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).

      IF <Incidencia>-Priority IS INITIAL.
        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD CheckTitle.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Title )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidencias).

    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).

      IF <Incidencia>-Title IS INITIAL.
        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

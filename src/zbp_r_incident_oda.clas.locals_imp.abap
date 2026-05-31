CLASS lhc_Z_R_INCIDENT_ODA DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    CONSTANTS:
      BEGIN OF c_status,
        c_status_open        TYPE zed_status_code_oda VALUE 'OP',
        c_status_in_progress TYPE zed_status_code_oda VALUE 'IP',
        c_status_pending     TYPE zed_status_code_oda VALUE 'PE',
        c_status_completed   TYPE zed_status_code_oda VALUE 'CO',
        c_status_closed      TYPE zed_status_code_oda VALUE 'CL',
        c_status_canceled    TYPE zed_status_code_oda VALUE 'CN',
      END OF c_status,

      BEGIN OF c_priority,
        c_priority_low    TYPE zed_priority_code_oda VALUE 'L',
        c_priority_medium TYPE zed_priority_code_oda VALUE 'M',
        c_priority_high   TYPE zed_priority_code_oda VALUE 'H',
      END OF c_priority.


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

    METHODS NewRecordHistory FOR MODIFY
      IMPORTING keys FOR ACTION Incident~NewRecordHistory.

    METHODS NewStatusToHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~NewStatusToHistory.

    METHODS CheckDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckDescription.

    METHODS CheckPriority FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckPriority.

    METHODS CheckTitle FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckTitle.

    METHODS CheckStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~CheckStatus.

    METHODS Get_History_Index EXPORTING ev_incuuid      TYPE sysuuid_x16
                              RETURNING VALUE(rv_index) TYPE vbeln.
ENDCLASS.

CLASS lhc_Z_R_INCIDENT_ODA IMPLEMENTATION.

  METHOD get_instance_features.

    DATA: lv_history_index TYPE n LENGTH 8.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
       ENTITY Incident
         FIELDS ( Status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(incidents)
       FAILED failed.

*--- Deshabilitación del botón ChangeStatus cuando se trata de una 'Creación de Incidencia'
    IF lines( incidents ) EQ 1.
      lv_history_index = get_history_index( IMPORTING ev_incuuid = incidents[ 1 ]-IncUUID ).
    ELSE.
      lv_history_index = 1.
    ENDIF.

    result = VALUE #( FOR incident IN incidents
                          ( %tky                   = incident-%tky
                            %action-ChangeStatus   = COND #( WHEN incident-Status = c_status-c_status_completed OR
                                                                  incident-Status = c_status-c_status_closed    OR
                                                                  incident-Status = c_status-c_status_canceled  OR
                                                                  lv_history_index = 0
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled )

                            %assoc-_HistoryData     = COND #( WHEN incident-Status = c_status-c_status_completed OR
                                                                 incident-Status = c_status-c_status_closed    OR
                                                                 incident-Status = c_status-c_status_canceled  OR
                                                                 lv_history_index = 0
                                                            THEN if_abap_behv=>fc-o-disabled
                                                            ELSE if_abap_behv=>fc-o-enabled )
                          ) ).

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

    DATA: incidents_update TYPE TABLE FOR UPDATE z_r_incident_oda.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
      ENTITY Incident
      FIELDS ( IncidentId Status ChangedDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(Incidents).

*--- Get Máx. Incident ID
    SELECT MAX( Incident_ID ) FROM zdt_inct_oda
    INTO @DATA(lv_max_IncidentID).

    IF sy-subrc NE 0.
      lv_max_IncidentID = '000000'.
    ENDIF.

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<Incident>).
      APPEND VALUE #( %tky = <Incident>-%tky
                      IncidentId = ( lv_max_incidentid + sy-index )
                      Status = c_status-c_status_open
                      ChangedDate = cl_abap_context_info=>get_system_date(  ) ) TO incidents_update.
    ENDLOOP.

    MODIFY ENTITIES OF z_r_incident_oda IN LOCAL MODE
   ENTITY Incident
   UPDATE
   FIELDS ( IncidentId Status ChangedDate )
   WITH incidents_update.

  ENDMETHOD.

  METHOD CheckCreatedDate.

*    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
*      ENTITY Incident
*      FIELDS ( CreatedDate ChangedDate )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(Incidencias).
*
*    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).
*
*      IF <Incidencia>-CreatedDate IS INITIAL.
*        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD CheckDatesRange.

*    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
*      ENTITY Incident
*      FIELDS ( CreatedDate ChangedDate )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(Incidencias).
*
*    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).
*
*      IF <Incidencia>-CreatedDate GT <Incidencia>-ChangedDate.
*        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD NewRecordHistory.

    DATA: history_for_create TYPE TABLE FOR CREATE z_r_incident_oda\_HistoryData.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( IncUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<incident>).
      APPEND VALUE #( %tky = <incident>-%tky
                      %target = VALUE #( ( NewStatus = ''
                                           Text = 'First Incident Device' ) )
                       ) TO history_for_create.
    ENDLOOP.

    MODIFY ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    CREATE BY \_HistoryData
    FIELDS ( HisUuid IncUuid HisId PreviousStatus NewStatus Text )
*   AUTO FILL CID
    WITH history_for_create.

  ENDMETHOD.

  METHOD NewStatusToHistory.

*--- Se ejecuta la internal action 'NewRecordHistory'
    MODIFY ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    EXECUTE NewRecordHistory
       FROM CORRESPONDING #( keys ).

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
        APPEND VALUE #( %tky = <Incidencia>-%tky
                        %state_area = 'DESCRIPTION'
                        %msg = NEW zcl_messages_manag_proj_oda( textid = zcl_messages_manag_proj_oda=>description_required
                                                                severity = if_abap_behv_message=>severity-error ) ) TO reported-incident.
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
        APPEND VALUE #( %tky = <Incidencia>-%tky
                        %state_area = 'PRIORITY'
                        %msg = NEW zcl_messages_manag_proj_oda( textid = zcl_messages_manag_proj_oda=>priority_required
                                                                severity = if_abap_behv_message=>severity-error ) ) TO reported-incident.
      ELSE.
        IF <Incidencia>-Priority NE c_priority-c_priority_low AND
           <Incidencia>-Priority NE c_priority-c_priority_medium AND
           <Incidencia>-Priority NE c_priority-c_priority_high.
          APPEND VALUE #( %tky = <Incidencia>-%tky
                          %state_area = 'PRIORITY'
                          %msg = NEW zcl_messages_manag_proj_oda( textid = zcl_messages_manag_proj_oda=>priority_unknown
                                                                  priority = <Incidencia>-Priority
                                                                  severity = if_abap_behv_message=>severity-error ) ) TO reported-incident.
        ENDIF.
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
        APPEND VALUE #( %tky = <Incidencia>-%tky
                        %state_area = 'TITLE'
                        %msg = NEW zcl_messages_manag_proj_oda( textid = zcl_messages_manag_proj_oda=>title_required
                                                                severity = if_abap_behv_message=>severity-error ) ) TO reported-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD CheckStatus.

*    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
*      ENTITY Incident
*      FIELDS ( Status )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(Incidencias).
*
*    LOOP AT Incidencias ASSIGNING FIELD-SYMBOL(<Incidencia>).
*
*      IF <Incidencia>-Status IS INITIAL.
*        APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
*        APPEND VALUE #( %tky = <Incidencia>-%tky
*                        %state_area = 'STATUS'
*                        %msg = NEW zcl_messages_manag_proj_oda( textid = zcl_messages_manag_proj_oda=>status_required
*                                                                severity = if_abap_behv_message=>severity-error ) ) TO reported-incident.
*      ELSE.
*        IF <Incidencia>-Status NE c_status-c_status_open AND
*           <Incidencia>-Status NE c_status-c_status_in_progress AND
*           <Incidencia>-Status NE c_status-c_status_pending AND
*           <Incidencia>-Status NE c_status-c_status_completed AND
*           <Incidencia>-Status NE c_status-c_status_close AND
*           <Incidencia>-Status NE c_status-c_status_canceled.
*          APPEND VALUE #( %tky = <Incidencia>-%tky ) TO failed-incident.
*          APPEND VALUE #( %tky = <Incidencia>-%tky
*                        %state_area = 'STATUS'
*                        %msg = NEW zcl_messages_manag_proj_oda( textid = zcl_messages_manag_proj_oda=>status_unknown
*                                                                status = <Incidencia>-Status
*                                                                severity = if_abap_behv_message=>severity-error ) ) TO reported-incident.
*        ENDIF.
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD get_history_index.

    SELECT FROM zdt_inct_h_oda
      FIELDS MAX( his_id ) AS max_his_id
      WHERE inc_uuid EQ @ev_incuuid AND
            his_uuid IS NOT NULL
      INTO @rv_index.

  ENDMETHOD.

ENDCLASS.

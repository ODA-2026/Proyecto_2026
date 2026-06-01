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

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
      ENTITY Incident
      FIELDS ( CreatedDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<Incident>).

      IF <Incident>-CreatedDate IS INITIAL.
        APPEND VALUE #( %tky = <Incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <Incident>-%tky
                        %state_area = 'Registered Dates Info'
                        %msg = new_message( id = 'ZMESSCLASS_PROJ_ODA'
                                            number = '007'
                                            severity = if_abap_behv_message=>severity-error )
                        %element-CreatedDate = if_abap_behv=>mk-on )
        TO reported-incident.
      ENDIF.

    ENDLOOP.

    free Incidents.

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

    DATA: history_for_create  TYPE TABLE FOR CREATE z_r_incident_oda\_HistoryData,
          ls_incident_history TYPE zdt_inct_h_oda,
          lv_text_exception   TYPE string.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( IncUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<incident>).

      CLEAR: ls_incident_history,
             lv_text_exception.

*--- Se crea nuevo UUID para la nueva línea de Historial
      TRY.
          ls_incident_history-inc_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error INTO DATA(lo_error).
          lv_text_exception = lo_error->get_text(  ).
      ENDTRY.

*--- Se detecta la línea de historial actual
      DATA(lv_max_his_id) = get_history_index( IMPORTING ev_incuuid = <incident>-IncUUID ).

      IF lv_max_his_id IS INITIAL.
        ls_incident_history-his_id = 1.
      ELSE.
        ls_incident_history-his_id = lv_max_his_id + 1.
      ENDIF.

      APPEND VALUE #( %tky = <incident>-%tky
                      %target = VALUE #( ( HisUuid = ls_incident_history-inc_uuid
                                           IncUuid = <incident>-IncUuid
                                           HisId = ls_incident_history-his_id
                                           NewStatus = c_status-c_status_open
                                           Text = 'First Incident Device' ) )
                       ) TO history_for_create.
    ENDLOOP.

    MODIFY ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    CREATE BY \_HistoryData
    FIELDS ( HisUuid IncUuid HisId PreviousStatus NewStatus Text )
    AUTO FILL CID
    WITH history_for_create.

    FREE Incidents.

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
    RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<Incident>).

      IF <Incident>-Description IS INITIAL.

        APPEND VALUE #( %tky = <Incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <Incident>-%tky
                        %state_area = 'Basic Data'
                        %msg = new_message( id = 'ZMESSCLASS_PROJ_ODA'
                                            number = '005'
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on )
        TO reported-incident.

      ENDIF.

    ENDLOOP.

    FREE Incidents.

  ENDMETHOD.

  METHOD CheckPriority.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Priority )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<Incident>).

      IF <Incident>-Priority IS INITIAL.
        APPEND VALUE #( %tky = <Incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <Incident>-%tky
                        %state_area = 'Priority'
                        %msg = new_message( id = 'ZMESSCLASS_PROJ_ODA'
                                            number = '003'
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Priority = if_abap_behv=>mk-on )
        TO reported-incident.
      ELSE.
        IF <Incident>-Priority NE c_priority-c_priority_low AND
           <Incident>-Priority NE c_priority-c_priority_medium AND
           <Incident>-Priority NE c_priority-c_priority_high.
          APPEND VALUE #( %tky = <Incident>-%tky
                          %state_area = 'Priority'
                          %msg = new_message( id = 'ZMESSCLASS_PROJ_ODA'
                                            number = '004'
                                            v1 = <Incident>-Priority
                                            severity = if_abap_behv_message=>severity-error )
                          %element-Priority = if_abap_behv=>mk-on )
          TO reported-incident.
        ENDIF.
      ENDIF.

    ENDLOOP.

    FREE Incidents.

  ENDMETHOD.

  METHOD CheckTitle.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Title )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<Incident>).

      IF <Incident>-Title IS INITIAL.
        APPEND VALUE #( %tky = <Incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <Incident>-%tky
                        %state_area = 'Basic Data'
                        %msg = new_message( id = 'ZMESSCLASS_PROJ_ODA'
                                            number = '006'
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Title = if_abap_behv=>mk-on )
         TO reported-incident.
      ENDIF.

    ENDLOOP.

    FREE Incidents.

  ENDMETHOD.

  METHOD CheckStatus.

    READ ENTITIES OF z_r_incident_oda IN LOCAL MODE
      ENTITY Incident
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(Incidents).

    LOOP AT Incidents ASSIGNING FIELD-SYMBOL(<Incident>).

      IF <Incident>-Status IS INITIAL.
        APPEND VALUE #( %tky = <Incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <Incident>-%tky
                        %state_area = 'Status'
                        %msg = new_message( id = 'ZMESSCLASS_PROJ_ODA'
                                            number = '001'
                                            v1 = <Incident>-Status
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Status = if_abap_behv=>mk-on )
        TO reported-incident.
      ELSE.
        IF <Incident>-Status NE c_status-c_status_open AND
           <Incident>-Status NE c_status-c_status_in_progress AND
           <Incident>-Status NE c_status-c_status_pending AND
           <Incident>-Status NE c_status-c_status_completed AND
           <Incident>-Status NE c_status-c_status_closed AND
           <Incident>-Status NE c_status-c_status_canceled.
          APPEND VALUE #( %tky = <Incident>-%tky ) TO failed-incident.
          APPEND VALUE #( %tky = <Incident>-%tky
                        %state_area = 'Status'
                        %msg = new_message( id = 'ZMESSCLASS_PROJ_ODA'
                                            number = '002'
                                            v1 = <Incident>-Status
                                            severity = if_abap_behv_message=>severity-error )
                        %element-Status = if_abap_behv=>mk-on )
          TO reported-incident.
        ENDIF.
      ENDIF.

    ENDLOOP.

 free Incidents.

  ENDMETHOD.

  METHOD get_history_index.

    SELECT FROM zdt_inct_h_oda
      FIELDS MAX( his_id ) AS max_his_id
      WHERE inc_uuid EQ @ev_incuuid AND
            his_uuid IS NOT NULL
      INTO @rv_index.

  ENDMETHOD.

ENDCLASS.

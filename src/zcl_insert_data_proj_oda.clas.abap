CLASS zcl_insert_data_proj_oda DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_insert_data_proj_oda IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*--- Status Values
    DELETE FROM zdt_status_oda.

    INSERT zdt_status_oda FROM TABLE @(  VALUE #(
                                       ( status_code = 'OP' status_description = 'Open' )
                                       ( status_code = 'IP' status_description = 'In progress' )
                                       ( status_code = 'PE' status_description = 'Pending' )
                                       ( status_code = 'CO' status_description = 'Completed' )
                                       ( status_code = 'CL' status_description = 'Closed' )
                                       ( status_code = 'CN' status_description = 'Canceled' )
                                       ) ).

    IF sy-subrc eq 0.
      out->write( |New entries for table Status: { sy-dbcnt }| ).
    ENDIF.

*--- Priority Values
    DELETE FROM zdt_priority_oda.

    INSERT zdt_priority_oda FROM TABLE @(  VALUE #(
                                       ( priority_code = 'H' priority_description = 'High' )
                                       ( priority_code = 'M' priority_description = 'Medium' )
                                       ( priority_code = 'L' priority_description = 'Low' )
                                       ) ).

    IF sy-subrc eq 0.
      out->write( |New entries for table Priority: { sy-dbcnt }| ).
    ENDIF.

*--- Incidents Data
    DELETE FROM zdt_inct_oda.

    TRY.

        MODIFY zdt_inct_oda FROM TABLE @( VALUE #(
                                                 ( inc_uuid = cl_system_uuid=>create_uuid_x16_static( ) incident_id = '00000001' title = 'Laptop'
                                                 description = 'CPU damaged' status = 'OP' priority = 'M' creation_date = '20260512' changed_date = '20260512' )
                                                 ( inc_uuid = cl_system_uuid=>create_uuid_x16_static( ) incident_id = '00000002' title = 'Tablet'
                                                 description = 'Extend memory'  status = 'OP' priority = 'L' creation_date = '20260514' changed_date = '20260514' )
                                                 ( inc_uuid = cl_system_uuid=>create_uuid_x16_static( ) incident_id = '00000003' title = 'Mobil'
                                                 description = 'Screen crashed' status = 'CN' priority = 'H' creation_date = '20260514' changed_date = '20260514' )
                                        ) ).

      CATCH cx_uuid_error INTO DATA(lc_exception).
        out->write( lc_exception->get_text(  ) ).

    ENDTRY.

    IF sy-subrc EQ 0.
      out->write( |New entries for table Incident: { sy-dbcnt }| ).
    ENDIF.

*--- Historical Data
    DELETE FROM zdt_inct_h_oda.

*--- Incident Number 0000001
    SELECT SINGLE inc_uuid FROM zdt_inct_oda
    WHERE incident_id = '00000001'
    INTO @DATA(lv_inc_uuid).

    IF sy-subrc EQ 0.

      TRY.

          MODIFY zdt_inct_h_oda FROM TABLE @( VALUE #(
                                                     ( his_uuid = cl_system_uuid=>create_uuid_x16_static( ) inc_uuid = lv_inc_uuid his_id = '000000023' previous_status = ''   new_status = 'OP' text = 'Require new CPU' )
                                                     ( his_uuid = cl_system_uuid=>create_uuid_x16_static( ) inc_uuid = lv_inc_uuid his_id = '000000035' previous_status = 'OP' new_status = 'IP' text = 'Waiting new CPU component' )

                                             ) ).
        CATCH cx_uuid_error INTO lc_exception.
          out->write( lc_exception->get_text(  ) ).

      ENDTRY.

    ENDIF.

    IF sy-subrc EQ 0.
      out->write( |New entries for table Historical Incident Num. 1:  { sy-dbcnt }| ).
    ENDIF.

*--- Incident Number 0000002
    SELECT SINGLE inc_uuid FROM zdt_inct_oda
    WHERE incident_id = '00000002'
    INTO @lv_inc_uuid.

    IF sy-subrc EQ 0.

      TRY.

          MODIFY zdt_inct_h_oda FROM TABLE @( VALUE #(
                                                     ( his_uuid = cl_system_uuid=>create_uuid_x16_static( ) inc_uuid = lv_inc_uuid his_id = '000000042' previous_status = ''   new_status = 'OP' text = 'Needed new Memory slot' )
                                                     ( his_uuid = cl_system_uuid=>create_uuid_x16_static( ) inc_uuid = lv_inc_uuid his_id = '000000055' previous_status = 'OP' new_status = 'IP' text = 'Waiting new memory component' )
                                                     ( his_uuid = cl_system_uuid=>create_uuid_x16_static( ) inc_uuid = lv_inc_uuid his_id = '000000066' previous_status = 'IP' new_status = 'CL' text = 'Tablet repaired' )

                                             ) ).
        CATCH cx_uuid_error INTO lc_exception.
          out->write( lc_exception->get_text(  ) ).

      ENDTRY.

    ENDIF.

    IF sy-subrc EQ 0.
      out->write( |New entries for table Historical Incident Num. 2:  { sy-dbcnt }| ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

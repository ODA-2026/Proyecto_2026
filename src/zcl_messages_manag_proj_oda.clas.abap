CLASS zcl_messages_manag_proj_oda DEFINITION PUBLIC INHERITING FROM cx_static_check FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    CONSTANTS: c_msgid TYPE symsgid VALUE 'ZMESSCLASS_PROJ_ODA'.

    CONSTANTS:

    BEGIN OF status_required,
        msgid TYPE symsgid VALUE 'ZMESSCLASS_PROJ_ODA',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_required,

      BEGIN OF status_unknown,
        msgid TYPE symsgid VALUE 'ZMESSCLASS_PROJ_ODA',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'STATUS',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_unknown,

      BEGIN OF priority_required,
        msgid TYPE symsgid VALUE 'ZMESSCLASS_PROJ_ODA',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF priority_required,

      BEGIN OF priority_unknown,
        msgid TYPE symsgid VALUE 'ZMESSCLASS_PROJ_ODA',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'PRIORITY',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF priority_unknown,

      BEGIN OF description_required,
        msgid TYPE symsgid VALUE 'ZMESSCLASS_PROJ_ODA',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF description_required,

      BEGIN OF title_required,
        msgid TYPE symsgid VALUE 'ZMESSCLASS_PROJ_ODA',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF title_required.

    INTERFACES: if_t100_dyn_msg,
                if_t100_message,
                if_abap_behv_message.

    METHODS constructor
      IMPORTING
        textid                LIKE if_t100_message=>t100key OPTIONAL
        attr1                 TYPE string OPTIONAL
        attr2                 TYPE string OPTIONAL
        attr3                 TYPE string OPTIONAL
        attr4                 TYPE string OPTIONAL
        previous              LIKE previous OPTIONAL
        status                TYPE zed_status_code_oda OPTIONAL
        priority              TYPE zed_priority_code_oda OPTIONAL
*       begin_date            TYPE /dmo/begin_date OPTIONAL
*       end_date              TYPE /dmo/end_date OPTIONAL
        severity              TYPE if_abap_behv_message=>t_severity OPTIONAL
        uname                 TYPE syuname OPTIONAL.

    DATA:
      attr1                 TYPE string,
      attr2                 TYPE string,
      attr3                 TYPE string,
      attr4                 TYPE string,
*     begin_date            TYPE /dmo/begin_date,
*     end_date              TYPE /dmo/end_date,
      status                TYPE zed_status_code_oda,
      priority              TYPE zed_priority_code_oda,
      uname                 TYPE syuname,
      severity              TYPE if_abap_behv_message=>t_severity.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_messages_manag_proj_oda IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).

    me->status             = status.
    me->priority           = priority.
    me->uname              = uname.

    me->severity = severity.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*& Report ZP2P_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZP2P_REPORT.

TABLES: zp2p_results.

TYPE-POOLS: slis.

DATA: it_results  TYPE TABLE OF zp2p_results,
      it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv,
      wa_layout   TYPE slis_layout_alv.

DATA: v_repid TYPE sy-repid.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_ebeln FOR zp2p_results-ebeln.
  PARAMETERS:     p_anomy TYPE c AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  v_repid  = sy-repid.

START-OF-SELECTION.

  SELECT * FROM zp2p_results
    INTO TABLE it_results
    WHERE ebeln IN s_ebeln.

  IF it_results IS INITIAL.
    WRITE: / 'No data found.',
           / 'Run ZP2P_FETCH and ZP2P_MATCH first.'.
    STOP.
  ENDIF.

* if checkbox is ticked show only anomaly rows
  IF p_anomy = 'X'.
    DELETE it_results WHERE anomaly <> 'X'.
  ENDIF.

  IF it_results IS INITIAL.
    WRITE: / 'No anomalies found in the data.'.
    STOP.
  ENDIF.

  PERFORM fill_fieldcat.
  PERFORM set_layout.
  PERFORM show_alv.

*&-------------------------------------------------------------*
FORM fill_fieldcat.

* each block below adds one column to the ALV

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 1.
  wa_fieldcat-fieldname = 'EBELN'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'PO Number'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 2.
  wa_fieldcat-fieldname = 'EBELP'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Item'.
  wa_fieldcat-outputlen = 5.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 3.
  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Vendor'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 4.
  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Material'.
  wa_fieldcat-outputlen = 18.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 5.
  wa_fieldcat-fieldname = 'BELNR'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Invoice No'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 6.
  wa_fieldcat-fieldname = 'PO_MENGE'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'PO Qty'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 7.
  wa_fieldcat-fieldname = 'INV_MENGE'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Inv Qty'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 8.
  wa_fieldcat-fieldname = 'PO_NETPR'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'PO Price'.
  wa_fieldcat-outputlen = 12.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 9.
  wa_fieldcat-fieldname = 'INV_WRBTR'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Inv Amount'.
  wa_fieldcat-outputlen = 12.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 10.
  wa_fieldcat-fieldname = 'VARIANCE'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Variance %'.
  wa_fieldcat-outputlen = 10.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 11.
  wa_fieldcat-fieldname = 'STATUS'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Status'.
  wa_fieldcat-outputlen = 15.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos   = 12.
  wa_fieldcat-fieldname = 'REASON'.
  wa_fieldcat-tabname   = 'IT_RESULTS'.
  wa_fieldcat-seltext_m = 'Reason'.
  wa_fieldcat-outputlen = 45.
  APPEND wa_fieldcat TO it_fieldcat.

ENDFORM.

*&-------------------------------------------------------------*
FORM set_layout.
  wa_layout-zebra             = 'X'.
  wa_layout-colwidth_optimize = 'X'.
  wa_layout-info_fieldname    = 'ROWCOLOR'.
ENDFORM.

*&-------------------------------------------------------------*
FORM show_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = v_repid
      i_grid_title       = 'P2P Anomaly Detection - Results'
      it_fieldcat        = it_fieldcat
      is_layout          = wa_layout
    TABLES
      t_outtab           = it_results
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
ENDFORM.

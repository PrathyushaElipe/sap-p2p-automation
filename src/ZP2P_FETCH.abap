*----------------------------------------------------------------*
* Program  : ZP2P_FETCH
* Author   : Prathyusha Elipe
* Purpose  : Reads PO and invoice data and stores in custom table
*----------------------------------------------------------------*
REPORT zp2p_fetch.

TABLES: ekko, ekpo, rseg.

* types for holding PO header data
TYPES: BEGIN OF ty_ekko,
         ebeln TYPE ekko-ebeln,
         lifnr TYPE ekko-lifnr,
         bedat TYPE ekko-bedat,
       END OF ty_ekko.

* types for PO line items
TYPES: BEGIN OF ty_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         matnr TYPE ekpo-matnr,
         menge TYPE ekpo-menge,
         netpr TYPE ekpo-netpr,
       END OF ty_ekpo.

* types for invoice items
TYPES: BEGIN OF ty_rseg,
         belnr TYPE rseg-belnr,
         gjahr TYPE rseg-gjahr,
         ebeln TYPE rseg-ebeln,
         ebelp TYPE rseg-ebelp,
         menge TYPE rseg-menge,
         wrbtr TYPE rseg-wrbtr,
       END OF ty_rseg.

* internal tables
DATA: it_ekko  TYPE TABLE OF ty_ekko,
      it_ekpo  TYPE TABLE OF ty_ekpo,
      it_rseg  TYPE TABLE OF ty_rseg,
      it_save  TYPE TABLE OF zp2p_results.

* work areas
DATA: wa_ekko   TYPE ty_ekko,
      wa_ekpo   TYPE ty_ekpo,
      wa_rseg   TYPE ty_rseg,
      wa_result TYPE zp2p_results.

DATA: v_count TYPE i.

*--- selection screen ---
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_ebeln FOR ekko-ebeln,
                  s_bedat FOR ekko-bedat.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.


START-OF-SELECTION.

* clear old data for selected POs first
  DELETE FROM zp2p_results WHERE ebeln IN s_ebeln.

* get PO headers from EKKO
  SELECT ebeln lifnr bedat
    FROM ekko
    INTO TABLE it_ekko
    WHERE ebeln IN s_ebeln
      AND bedat IN s_bedat
      AND bstyp = 'F'.

  IF it_ekko IS INITIAL.
    MESSAGE 'No purchase orders found. Check your selection.' TYPE 'I'.
    STOP.
  ENDIF.

* get PO items from EKPO using the headers we got
  SELECT ebeln ebelp matnr menge netpr
    FROM ekpo
    INTO TABLE it_ekpo
    FOR ALL ENTRIES IN it_ekko
    WHERE ebeln = it_ekko-ebeln
      AND loekz = space.

  IF it_ekpo IS INITIAL.
    MESSAGE 'No PO line items found.' TYPE 'I'.
    STOP.
  ENDIF.

* get invoice items from RSEG that are linked to our POs
  SELECT belnr gjahr ebeln ebelp menge wrbtr
    FROM rseg
    INTO TABLE it_rseg
    FOR ALL ENTRIES IN it_ekpo
    WHERE ebeln = it_ekpo-ebeln
      AND ebelp = it_ekpo-ebelp.

* now combine everything into result rows
  LOOP AT it_ekpo INTO wa_ekpo.

    CLEAR wa_result.

    wa_result-ebeln    = wa_ekpo-ebeln.
    wa_result-ebelp    = wa_ekpo-ebelp.
    wa_result-matnr    = wa_ekpo-matnr.
    wa_result-po_menge = wa_ekpo-menge.
    wa_result-po_netpr = wa_ekpo-netpr.

*   get vendor number from header table
    READ TABLE it_ekko INTO wa_ekko
      WITH KEY ebeln = wa_ekpo-ebeln.
    IF sy-subrc = 0.
      wa_result-lifnr = wa_ekko-lifnr.
    ENDIF.

*   check if invoice exists for this PO item
    READ TABLE it_rseg INTO wa_rseg
      WITH KEY ebeln = wa_ekpo-ebeln
               ebelp = wa_ekpo-ebelp.
    IF sy-subrc = 0.
      wa_result-belnr     = wa_rseg-belnr.
      wa_result-gjahr     = wa_rseg-gjahr.
      wa_result-inv_menge = wa_rseg-menge.
      wa_result-inv_wrbtr = wa_rseg-wrbtr.
    ENDIF.

    wa_result-status = 'FETCHED'.

    APPEND wa_result TO it_save.

  ENDLOOP.

* save to database
  INSERT zp2p_results FROM TABLE it_save.

  v_count = lines( it_save ).

  WRITE: / '---------------------------------------',
         / ' ZP2P_FETCH completed.',
         / ' Records saved :', v_count,
         / ' Run ZP2P_MATCH next.',
         / '---------------------------------------'.

*&---------------------------------------------------------------------*
*& Report ZP2P_MATCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZP2P_MATCH.


DATA: it_results TYPE TABLE OF zp2p_results,
      wa_result  TYPE zp2p_results.

DATA: v_expected TYPE p DECIMALS 2,
      v_variance TYPE p DECIMALS 2,
      v_total    TYPE i,
      v_bad      TYPE i.

* 5 percent is our threshold - anything above this is flagged
DATA: v_threshold TYPE p DECIMALS 2 VALUE '5.00'.

START-OF-SELECTION.

* read all rows that were saved by fetch program
  SELECT * FROM zp2p_results
    INTO TABLE it_results
    WHERE status = 'FETCHED'.

  IF it_results IS INITIAL.
    WRITE: / 'Nothing to process.',
           / 'Please run ZP2P_FETCH first.'.
    STOP.
  ENDIF.

  LOOP AT it_results INTO wa_result.

    CLEAR: v_expected, v_variance.

*   case 1 - no invoice at all for this PO line
    IF wa_result-belnr IS INITIAL.
      wa_result-status   = 'NOT INVOICED'.
      wa_result-anomaly  = 'X'.
      wa_result-reason   = 'No invoice found for this PO item'.
      wa_result-rowcolor = 'C310'.

    ELSE.

*     calculate expected amount based on PO price and quantity
      v_expected = wa_result-po_menge * wa_result-po_netpr.

*     calculate how much the invoice differs in percentage
      IF v_expected > 0.
        v_variance = ( wa_result-inv_wrbtr - v_expected )
                     / v_expected * 100.
      ENDIF.

      wa_result-variance = v_variance.
      wa_result-status   = 'MATCHED'.
      wa_result-rowcolor = 'C510'.

*     case 2 - price is too different from PO
      IF ABS( v_variance ) > v_threshold.
        wa_result-status   = 'ANOMALY'.
        wa_result-anomaly  = 'X'.
        wa_result-reason   = 'Invoice amount differs from PO by more than 5 percent'.
        wa_result-rowcolor = 'C610'.
      ENDIF.

*     case 3 - more quantity invoiced than what was ordered
      IF wa_result-inv_menge > wa_result-po_menge.
        wa_result-status   = 'ANOMALY'.
        wa_result-anomaly  = 'X'.
        wa_result-reason   = 'Invoice quantity is higher than PO quantity'.
        wa_result-rowcolor = 'C610'.
      ENDIF.

*     case 4 - invoice posted with zero amount
      IF wa_result-inv_wrbtr = 0.
        wa_result-status   = 'ANOMALY'.
        wa_result-anomaly  = 'X'.
        wa_result-reason   = 'Invoice amount is zero'.
        wa_result-rowcolor = 'C610'.
      ENDIF.

    ENDIF.

*   update this row in the database table
    UPDATE zp2p_results FROM wa_result.

    v_total = v_total + 1.
    IF wa_result-anomaly = 'X'.
      v_bad = v_bad + 1.
    ENDIF.

  ENDLOOP.

  WRITE: / '---------------------------------------',
         / ' ZP2P_MATCH completed.',
         / ' Total records checked :', v_total,
         / ' Anomalies flagged     :', v_bad,
         / ' Run ZP2P_REPORT next.',
         / '---------------------------------------'.

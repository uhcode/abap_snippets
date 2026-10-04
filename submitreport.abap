*----------------------------------------------------------------------*
* Snippet: Call a report with a dynamically built selection table
*----------------------------------------------------------------------*
* Purpose : Checks for the given purchase order items whether the
*           "delivery completed" (ELIKZ) or "final invoice" (EGLKZ)
*           indicator is set and calls a report that resets them.
*
* Shows how to fill parameters and select-options of the called
* report via SUBMIT ... WITH SELECTION-TABLE.
*
* Assumes the following objects from the surrounding method:
*   it_positionen - items; BLNRA = purchase order, BPOSA = item
*   p_test        - test run flag, passed on to the called report
*----------------------------------------------------------------------*
DATA lt_seltab      TYPE STANDARD TABLE OF rsparams WITH EMPTY KEY.
DATA lt_ebelp_range TYPE ebelp_range_tty.
DATA lv_ebeln       TYPE ebeln.
DATA lv_reset_elikz TYPE abap_bool.
DATA lv_reset_eglkz TYPE abap_bool.

IF it_positionen IS INITIAL.
  RETURN.
ENDIF.

" All items belong to the same purchase order
LOOP AT it_positionen ASSIGNING FIELD-SYMBOL(<ls_position>).
  lv_ebeln = <ls_position>-blnra.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = <ls_position>-bposa ) TO lt_ebelp_range.
ENDLOOP.

SELECT ebelp, elikz, eglkz
  FROM ekpo
  WHERE ebeln =  @lv_ebeln
    AND ebelp IN @lt_ebelp_range
  INTO TABLE @DATA(lt_item_flags).

" Only items with at least one indicator set are passed to the report
LOOP AT lt_item_flags ASSIGNING FIELD-SYMBOL(<ls_item_flags>)
     WHERE elikz IS NOT INITIAL OR eglkz IS NOT INITIAL.

  IF <ls_item_flags>-elikz IS NOT INITIAL.
    lv_reset_elikz = abap_true.
  ENDIF.
  IF <ls_item_flags>-eglkz IS NOT INITIAL.
    lv_reset_eglkz = abap_true.
  ENDIF.

  " Select-option (KIND = 'S'): one line per value
  APPEND VALUE #( selname = 'S_EBELP' kind = 'S' sign = 'I' option = 'EQ'
                  low     = <ls_item_flags>-ebelp ) TO lt_seltab.
ENDLOOP.

IF lt_seltab IS INITIAL.
  RETURN.
ENDIF.

" Parameters (KIND = 'P'): new indicator value and "update" flag
IF lv_reset_elikz = abap_true.
  APPEND VALUE #( selname = 'P_ELIKZ'  kind = 'P' sign = 'I' option = 'EQ' low = space )     TO lt_seltab.
  APPEND VALUE #( selname = 'P_ELI_UP' kind = 'P' sign = 'I' option = 'EQ' low = abap_true ) TO lt_seltab.
ENDIF.
IF lv_reset_eglkz = abap_true.
  APPEND VALUE #( selname = 'P_EALKZ'  kind = 'P' sign = 'I' option = 'EQ' low = space )     TO lt_seltab.
  APPEND VALUE #( selname = 'P_EAK_UP' kind = 'P' sign = 'I' option = 'EQ' low = abap_true ) TO lt_seltab.
ENDIF.

APPEND VALUE #( selname = 'S_EBELN' kind = 'S' sign = 'I' option = 'EQ' low = lv_ebeln ) TO lt_seltab.
APPEND VALUE #( selname = 'P_TEST'  kind = 'P' sign = 'I' option = 'EQ' low = p_test )   TO lt_seltab.

" AND RETURN: continue here after the called report has finished
SUBMIT z_some_report WITH SELECTION-TABLE lt_seltab AND RETURN.

*----------------------------------------------------------------------*
* Snippet: Call transactions without display (smoke test)
*----------------------------------------------------------------------*
* Purpose : Starts all transactions of an application component in
*           the background and lists those that terminate with an
*           abort message on their initial screen.
*
* Shows how to
*   - find the transactions of an application component
*     (DF14L -> TDEVC -> TADIR)
*   - call a transaction invisibly with CALL TRANSACTION ... MODE 'N'
*     and evaluate the collected messages
*
* Note: the transactions are started WITHOUT AUTHORITY-CHECK - use
* this report in development and test systems only.
*----------------------------------------------------------------------*
REPORT z_call_ta.

TABLES: df14l, tstc.

SELECT-OPTIONS:
  s_comp  FOR df14l-ps_posid,   " application component, e.g. LE*
  s_trans FOR tstc-tcode.       " restrict the transaction codes

PARAMETERS p_max TYPE i DEFAULT 100 OBLIGATORY.  " max. number of calls

DATA lt_bdc      TYPE STANDARD TABLE OF bdcdata.    " stays empty: initial screen only
DATA lt_messages TYPE STANDARD TABLE OF bdcmsgcoll.
DATA lv_msg_text TYPE string.

INITIALIZATION.
  " Default: all components below LE (Logistics Execution)
  s_comp-sign   = 'I'.
  s_comp-option = 'CP'.
  s_comp-low    = 'LE*'.
  APPEND s_comp.

START-OF-SELECTION.

  " Packages that are assigned to the selected application components
  SELECT a~devclass
    FROM tdevc AS a
    INNER JOIN df14l AS b ON a~component = b~fctr_id
    WHERE b~ps_posid IN @s_comp
    INTO TABLE @DATA(lt_devclass).
  IF lt_devclass IS INITIAL.
    RETURN.
  ENDIF.

  " Transactions that belong to these packages
  SELECT obj_name
    FROM tadir
    FOR ALL ENTRIES IN @lt_devclass
    WHERE pgmid    = 'R3TR'
      AND object   = 'TRAN'
      AND devclass = @lt_devclass-devclass
    INTO TABLE @DATA(lt_transactions).

  DELETE lt_transactions WHERE obj_name NOT IN s_trans.

  LOOP AT lt_transactions ASSIGNING FIELD-SYMBOL(<ls_transaction>) TO p_max.

    " MODE 'N' processes the transaction without displaying screens.
    " As no BDC data is passed, processing ends on the first screen.
    CLEAR lt_messages.
    CALL TRANSACTION <ls_transaction>-obj_name WITHOUT AUTHORITY-CHECK
         USING lt_bdc MODE 'N' MESSAGES INTO lt_messages.

    " Report abort messages together with the transaction code
    READ TABLE lt_messages ASSIGNING FIELD-SYMBOL(<ls_message>) WITH KEY msgtyp = 'A'.
    IF sy-subrc = 0.
      MESSAGE ID <ls_message>-msgid TYPE <ls_message>-msgtyp NUMBER <ls_message>-msgnr
              WITH <ls_message>-msgv1 <ls_message>-msgv2 <ls_message>-msgv3 <ls_message>-msgv4
              INTO lv_msg_text.
      WRITE: / <ls_transaction>-obj_name, lv_msg_text.
    ELSE.
      WRITE / <ls_transaction>-obj_name.
    ENDIF.

  ENDLOOP.

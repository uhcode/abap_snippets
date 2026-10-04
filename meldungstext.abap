*----------------------------------------------------------------------*
* Snippet: Get the text of a T100 message into a variable
*----------------------------------------------------------------------*
* Two ways to build the complete message text (short text with the
* placeholders replaced) without displaying the message.
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* 1) MESSAGE ... INTO - also fills SY-MSGID, SY-MSGNO, SY-MSGV1..4
*    and keeps the where-used list of the message intact
*----------------------------------------------------------------------*
DATA lv_text TYPE string.

MESSAGE i014(esh_co_common)
        WITH 'Interface mismatch: Cannot perform action'
        INTO lv_text.

*----------------------------------------------------------------------*
* 2) Function module MESSAGE_PREPARE - useful when message class and
*    number are only known at runtime (e.g. read from a log)
*----------------------------------------------------------------------*
DATA lv_msg_text TYPE c LENGTH 255.
DATA lv_msg_id   TYPE t100-arbgb VALUE 'ESH_CO_COMMON'.
DATA lv_msg_no   TYPE t100-msgnr VALUE '014'.
DATA lv_msg_v1   TYPE balm-msgv1 VALUE 'Interface mismatch: Cannot perform action'.
DATA lv_msg_v2   TYPE balm-msgv1.
DATA lv_msg_v3   TYPE balm-msgv1.
DATA lv_msg_v4   TYPE balm-msgv1.

CALL FUNCTION 'MESSAGE_PREPARE'
  EXPORTING
    msg_id                 = lv_msg_id
    msg_no                 = lv_msg_no
    msg_var1               = lv_msg_v1
    msg_var2               = lv_msg_v2
    msg_var3               = lv_msg_v3
    msg_var4               = lv_msg_v4
  IMPORTING
    msg_text               = lv_msg_text
  EXCEPTIONS
    function_not_completed = 1
    message_not_found      = 2
    OTHERS                 = 3.
IF sy-subrc <> 0.
  CLEAR lv_msg_text.
ENDIF.

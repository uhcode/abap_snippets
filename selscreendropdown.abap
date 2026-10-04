*----------------------------------------------------------------------*
* Snippet: Dropdown list box on a selection screen
*----------------------------------------------------------------------*
* Purpose : Shows a parameter as dropdown and fills its value list at
*           runtime with VRM_SET_VALUES.
*
* Text symbol 001 = frame title of the selection screen block
*----------------------------------------------------------------------*
REPORT ztest_uhpsl.

SELECTION-SCREEN BEGIN OF BLOCK bk1 WITH FRAME TITLE TEXT-001.
" AS LISTBOX turns the parameter into a dropdown; the parameter holds
" the key of the selected entry
PARAMETERS p_period TYPE c LENGTH 2 AS LISTBOX VISIBLE LENGTH 20.
SELECTION-SCREEN END OF BLOCK bk1.

INITIALIZATION.

  " Key = value stored in the parameter, text = entry shown to the user
  DATA(lt_values) = VALUE vrm_values(
    ( key = '01' text = 'One month' )
    ( key = '02' text = 'Two months' )
    ( key = '03' text = 'Three months' ) ).

  " The ID is the name of the parameter in upper case
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = CONV vrm_id( 'P_PERIOD' )
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.

*----------------------------------------------------------------------*
* Snippet: Confirmation popup "save changes?" on exit
*----------------------------------------------------------------------*
* Purpose : Asks the user whether unsaved changes should be saved and
*           maps the answer of POPUP_TO_CONFIRM to an own code.
*
* Result in EV_ANT:
*   'S'   - save and leave        (button "Yes")
*   'E'   - leave without saving  (button "No")
*   space - stay on the screen    (button "Cancel")
*----------------------------------------------------------------------*
DATA lv_answer TYPE c LENGTH 1.

CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    titlebar        = 'Wirklich beenden'(021)
    diagnose_object = '//'
    text_question   = 'Wollen Sie die Änderungen sichern?'(022)
  IMPORTING
    answer          = lv_answer
  EXCEPTIONS
    OTHERS          = 2.

" POPUP_TO_CONFIRM returns '1' (first button), '2' (second button)
" or 'A' (cancel)
CASE lv_answer.
  WHEN '1'.
    ev_ant = 'S'.
  WHEN 'A'.
    ev_ant = space.
  WHEN OTHERS.
    ev_ant = 'E'.
ENDCASE.

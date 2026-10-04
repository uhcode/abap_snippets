*----------------------------------------------------------------------*
* Snippet: Turn a class-based exception into a message
*----------------------------------------------------------------------*
* Two common ways to hand the text of a caught exception to the
* caller or the user. YCX_SOMETHING stands for your own exception
* class.
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* 1) Exception -> BAPIRET2 table (e.g. in a BAPI or RFC module)
*----------------------------------------------------------------------*
TRY.
    " ... business logic that raises ycx_something ...

  CATCH ycx_something INTO DATA(lo_exc).
    " Appends the exception text as error line to the return table
    CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2'
      EXPORTING
        i_r_exception = lo_exc
      CHANGING
        c_t_bapiret2  = et_return.
    RETURN.
ENDTRY.

*----------------------------------------------------------------------*
* 2) Exception -> message in the status bar (e.g. in a report)
*----------------------------------------------------------------------*
TRY.
    " ... business logic that raises ycx_something ...

  CATCH ycx_something INTO DATA(lo_exc_dialog).
    " Type 'S' does not interrupt the program flow, DISPLAY LIKE 'E'
    " still shows the message as an error
    DATA(lv_msg) = lo_exc_dialog->get_text( ).
    MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
ENDTRY.

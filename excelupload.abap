*----------------------------------------------------------------------*
* Snippet: Upload an Excel file from the frontend (SAP GUI)
*----------------------------------------------------------------------*
* Purpose : Lets the user pick an Excel file, reads it into an
*           internal table and lists all e-mail addresses that occur
*           more than once.
*
* Expected layout: header in row 1, data from row 2, columns
*   A = SMTP address, B = name, C = data 1, D = data 2
*
* ALSM_EXCEL_TO_INTERNAL_TABLE uses OLE, so it only works in dialog
* with SAP GUI for Windows and an installed Excel.
*----------------------------------------------------------------------*
TYPES: BEGIN OF ts_excel,
         smtp  TYPE string,
         name  TYPE string,
         data1 TYPE string,
         data2 TYPE string,
       END OF ts_excel.

DATA lt_files      TYPE filetable.
DATA lv_rc         TYPE i.
DATA lv_action     TYPE i.
DATA lt_cells      TYPE STANDARD TABLE OF alsmex_tabline.
DATA ls_excel      TYPE ts_excel.
DATA lt_excel      TYPE STANDARD TABLE OF ts_excel.
DATA lt_duplicates TYPE string_table.

*----------------------------------------------------------------------*
* File selection
*----------------------------------------------------------------------*
cl_gui_frontend_services=>file_open_dialog(
  EXPORTING
    window_title     = 'Select File'
    default_filename = '*.xls'
  CHANGING
    file_table       = lt_files
    rc               = lv_rc
    user_action      = lv_action
  EXCEPTIONS
    OTHERS           = 1 ).
IF sy-subrc <> 0
OR lv_action = cl_gui_frontend_services=>action_cancel
OR lt_files IS INITIAL.
  RETURN.
ENDIF.

*----------------------------------------------------------------------*
* Read the sheet - the result has one line per cell (row, col, value)
*----------------------------------------------------------------------*
CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
  EXPORTING
    filename                = CONV localfile( lt_files[ 1 ]-filename )
    i_begin_col             = 1
    i_begin_row             = 2      " skip the header row
    i_end_col               = 4
    i_end_row               = 65535
  TABLES
    intern                  = lt_cells
  EXCEPTIONS
    inconsistent_parameters = 1
    upload_ole              = 2
    OTHERS                  = 3.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  RETURN.
ENDIF.

*----------------------------------------------------------------------*
* Convert the cell list into one structured line per Excel row
*----------------------------------------------------------------------*
LOOP AT lt_cells INTO DATA(ls_cell).

  " The column number of the cell is the component index of the target
  ASSIGN COMPONENT ls_cell-col OF STRUCTURE ls_excel TO FIELD-SYMBOL(<lv_comp>).
  IF sy-subrc = 0.
    <lv_comp> = ls_cell-value.
  ENDIF.

  AT END OF row.
    " Address already read in an earlier row -> remember it as duplicate
    IF line_exists( lt_excel[ smtp = ls_excel-smtp ] ).
      APPEND ls_excel-smtp TO lt_duplicates.
    ENDIF.
    APPEND ls_excel TO lt_excel.
    CLEAR ls_excel.
  ENDAT.

ENDLOOP.

*----------------------------------------------------------------------*
* Output of the duplicate addresses
*----------------------------------------------------------------------*
LOOP AT lt_duplicates INTO DATA(lv_duplicate).
  WRITE / lv_duplicate.
ENDLOOP.

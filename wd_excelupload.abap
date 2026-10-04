*----------------------------------------------------------------------*
* Snippet: Excel upload in Web Dynpro ABAP
*----------------------------------------------------------------------*
* Context : Action handler of a view. The context node REL_OBJECTS has
*           an attribute DATA (XSTRING) that is bound to a FileUpload
*           UI element.
* Purpose : Parses the uploaded .xlsx file on the server - without OLE
*           and without frontend access - and converts every row of
*           the first worksheet into one string, cells separated by
*           '||'.
*----------------------------------------------------------------------*
METHOD onactiondo_upload.

  CONSTANTS lc_separator TYPE string VALUE `||`.

  DATA ls_rel_objects TYPE wd_this->element_rel_objects.
  DATA lv_content     LIKE ls_rel_objects-data.
  DATA lv_file_name   TYPE string.
  DATA lo_excel       TYPE REF TO cl_fdt_xl_spreadsheet.
  DATA lt_contents    TYPE string_table.
  DATA lv_line        TYPE string.

  FIELD-SYMBOLS <lt_sheet> TYPE STANDARD TABLE.

  " Read the uploaded file content from the context (lead selection)
  DATA(lo_nd_rel_objects) = wd_context->get_child_node( name = wd_this->wdctx_rel_objects ).
  lo_nd_rel_objects->get_element( )->get_attribute(
    EXPORTING name  = `DATA`
    IMPORTING value = lv_content ).

  " Parse the workbook; fails if the content is not a valid .xlsx file
  TRY.
      lo_excel = NEW #( document_name = lv_file_name
                        xdocument     = lv_content ).
    CATCH cx_fdt_excel_core INTO DATA(lx_excel_core).
      DATA(lo_controller) = CAST if_wd_controller( wd_this->wd_get_api( ) ).
      lo_controller->get_message_manager( )->report_error_message(
        message_text = lx_excel_core->get_text( ) ).
      RETURN.
  ENDTRY.

  " Take the first worksheet of the workbook
  lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING worksheet_names = DATA(lt_worksheets) ).
  IF lt_worksheets IS INITIAL.
    RETURN.
  ENDIF.

  " The sheet is returned as a generically typed table: one line per
  " row, one component per column
  DATA(lr_sheet) = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lt_worksheets[ 1 ] ).
  ASSIGN lr_sheet->* TO <lt_sheet>.
  IF <lt_sheet> IS NOT ASSIGNED.
    RETURN.
  ENDIF.

  LOOP AT <lt_sheet> ASSIGNING FIELD-SYMBOL(<ls_row>).

    " Walk over all cells of the row until no further component exists
    CLEAR lv_line.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_row> TO FIELD-SYMBOL(<lv_cell>).
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      IF sy-index = 1.
        lv_line = <lv_cell>.
      ELSE.
        lv_line = lv_line && lc_separator && <lv_cell>.
      ENDIF.
    ENDDO.

    APPEND lv_line TO lt_contents.

  ENDLOOP.

  " lt_contents now holds one string per Excel row - process it here

ENDMETHOD.

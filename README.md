# abap_snippets

A collection of small ABAP code snippets for recurring tasks.

| File | Topic |
|------|-------|
| [create_idoc.abap](create_idoc.abap) | Build and post an inbound IDoc (message type `DESADV`, basic type `DELVRY03`) |
| [excelupload.abap](excelupload.abap) | Upload an Excel file from the frontend with `ALSM_EXCEL_TO_INTERNAL_TABLE` |
| [wd_excelupload.abap](wd_excelupload.abap) | Excel upload in Web Dynpro ABAP with `CL_FDT_XL_SPREADSHEET` |
| [excp2bapiret.abap](excp2bapiret.abap) | Convert a class-based exception into a `BAPIRET2` line or a message |
| [meldungstext.abap](meldungstext.abap) | Get the text of a T100 message into a variable |
| [popup2conf.abap](popup2conf.abap) | Confirmation popup with `POPUP_TO_CONFIRM` |
| [selscreendropdown.abap](selscreendropdown.abap) | Dropdown list box on a selection screen (`VRM_SET_VALUES`) |
| [submitreport.abap](submitreport.abap) | `SUBMIT` a report with a dynamically built selection table |
| [ta_nodisplay.abap](ta_nodisplay.abap) | Call transactions without display (`CALL TRANSACTION ... MODE 'N'`) |

Further files:

- `dynpro.JPG` - screenshot of the structure of a module pool with dynpros
- `RO_test01.xlsx`, `RO_test02.xlsx` - sample workbooks for the Excel upload snippets

For an editable ALV grid see the SAP demo report `BCALV_EDIT_03`.

Most snippets are excerpts and are not meant to be activated as they are -
adapt names and types to your own objects.

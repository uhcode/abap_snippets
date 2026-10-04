*----------------------------------------------------------------------*
* Snippet: Create an inbound IDoc (message type DESADV)
*----------------------------------------------------------------------*
* Purpose : Builds the control record and the data records of a
*           shipping notification (basic type DELVRY03) and hands them
*           to the IDoc inbound processing.
*
* Segment hierarchy built below:
*   E1EDL20          delivery header
*   +-- E1ADRM1      address (partner: vendor)
*   |   +-- E1ADRE1  address, additional data
*   +-- E1TXTH8      text header
*   |   +-- E1TXTP8  text line
*   +-- E1EDL24      delivery item
*       +-- E1EDL41  reference data of the ordering party
*
* Every data record points to its parent via PSGNUM and carries its
* hierarchy level in HLEVEL. All partner, port and document values
* are examples - replace them with the values of your own system.
*----------------------------------------------------------------------*
CONSTANTS:
  lc_seg_delivery_header TYPE edilsegtyp VALUE 'E1EDL20',
  lc_seg_address         TYPE edilsegtyp VALUE 'E1ADRM1',
  lc_seg_address_add     TYPE edilsegtyp VALUE 'E1ADRE1',
  lc_seg_text_header     TYPE edilsegtyp VALUE 'E1TXTH8',
  lc_seg_text_line       TYPE edilsegtyp VALUE 'E1TXTP8',
  lc_seg_delivery_item   TYPE edilsegtyp VALUE 'E1EDL24',
  lc_seg_order_reference TYPE edilsegtyp VALUE 'E1EDL41',
  lc_partner_vendor      TYPE char3      VALUE 'LF',
  lc_docnum              TYPE edi_dc40-docnum VALUE '9000000000000001'.

DATA lt_edi_dc40      TYPE edi_dc40_tt.
DATA lt_edi_dd40      TYPE edi_dd40_tt.
DATA lv_segnum        TYPE edi4segnuc.
DATA lv_segnum_header TYPE edi4psgnuc.
DATA lv_segnum_addr   TYPE edi4psgnuc.
DATA lv_segnum_text   TYPE edi4psgnuc.
DATA lv_segnum_item   TYPE edi4psgnuc.

*----------------------------------------------------------------------*
* Control record
*----------------------------------------------------------------------*
APPEND VALUE #(
  tabnam  = 'EDI_DC40'
  mandt   = sy-mandt
  docnum  = lc_docnum
  docrel  = sy-saprl
  status  = '03'
  idoctyp = 'DELVRY03'
  mestyp  = 'DESADV'
  direct  = '1'
  outmod  = '2'
  " Receiver: own logical system
  rcvpor  = 'SAPZE1'
  rcvprt  = 'LS'
  rcvprn  = 'ZE1CLNT501'
  " Sender: EDI converter
  sndpor  = 'SAPZE1'
  sndprt  = 'LS'
  sndprn  = 'SEEBURGER'
  credat  = sy-datum
  cretim  = sy-uzeit
) TO lt_edi_dc40.

*----------------------------------------------------------------------*
* Data records
*----------------------------------------------------------------------*
" Delivery header (root segment, no parent)
lv_segnum = lv_segnum + 1.
APPEND VALUE #(
  docnum = lc_docnum
  mandt  = sy-mandt
  segnam = lc_seg_delivery_header
  segnum = lv_segnum
  hlevel = '001'
  sdata  = VALUE e1edl20( vbeln = 'EDI' )  " external delivery note number
) TO lt_edi_dd40.
lv_segnum_header = lv_segnum.

" Address of the vendor
lv_segnum = lv_segnum + 1.
APPEND VALUE #(
  docnum = lc_docnum
  mandt  = sy-mandt
  segnam = lc_seg_address
  segnum = lv_segnum
  psgnum = lv_segnum_header
  hlevel = '002'
  sdata  = VALUE e1adrm1( partner_q = lc_partner_vendor )
) TO lt_edi_dd40.
lv_segnum_addr = lv_segnum.

" Additional address data
lv_segnum = lv_segnum + 1.
APPEND VALUE #(
  docnum = lc_docnum
  mandt  = sy-mandt
  segnam = lc_seg_address_add
  segnum = lv_segnum
  psgnum = lv_segnum_addr
  hlevel = '003'
  sdata  = VALUE e1adre1( extend_d = '11111111' )
) TO lt_edi_dd40.

" Text header
lv_segnum = lv_segnum + 1.
APPEND VALUE #(
  docnum = lc_docnum
  mandt  = sy-mandt
  segnam = lc_seg_text_header
  segnum = lv_segnum
  psgnum = lv_segnum_header
  hlevel = '002'
  sdata  = VALUE e1txth8( tdid = 'XX01' )
) TO lt_edi_dd40.
lv_segnum_text = lv_segnum.

" Text line
lv_segnum = lv_segnum + 1.
APPEND VALUE #(
  docnum = lc_docnum
  mandt  = sy-mandt
  segnam = lc_seg_text_line
  segnum = lv_segnum
  psgnum = lv_segnum_text
  hlevel = '003'
  sdata  = VALUE e1txtp8( tdline = '979797' )
) TO lt_edi_dd40.

" Delivery item
lv_segnum = lv_segnum + 1.
APPEND VALUE #(
  docnum = lc_docnum
  mandt  = sy-mandt
  segnam = lc_seg_delivery_item
  segnum = lv_segnum
  psgnum = lv_segnum_header
  hlevel = '002'
  sdata  = VALUE e1edl24( posnr = '000001'
                          lfimg = '20'
                          vrkme = 'PAK'
                          ean11 = 'EAN111111'
                          usr01 = 'PAK' )
) TO lt_edi_dd40.
lv_segnum_item = lv_segnum.

" Reference to the purchase order of the ordering party
lv_segnum = lv_segnum + 1.
APPEND VALUE #(
  docnum = lc_docnum
  mandt  = sy-mandt
  segnam = lc_seg_order_reference
  segnum = lv_segnum
  psgnum = lv_segnum_item
  hlevel = '003'
  sdata  = VALUE e1edl41( bstnr = '3333333'
                          posex = '555555' )
) TO lt_edi_dd40.

*----------------------------------------------------------------------*
* Pass the IDoc to the inbound processing
*----------------------------------------------------------------------*
CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS'
  TABLES
    idoc_control_rec_40 = lt_edi_dc40
    idoc_data_rec_40    = lt_edi_dd40.

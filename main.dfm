object Form_Posrednik: TForm_Posrednik
  Left = 261
  Top = 627
  BorderStyle = bsDialog
  Caption = #1055#1086#1089#1088#1077#1076#1085#1080#1082' '#1060#1088#1086#1085#1090#1086#1083'<>Shutttle'
  ClientHeight = 322
  ClientWidth = 448
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 448
    Height = 322
    ActivePage = TbSht_Log
    Align = alClient
    TabOrder = 0
    object TbSht_Log: TTabSheet
      Caption = #1046#1091#1088#1085#1072#1083
      DesignSize = (
        440
        294)
      object memo_log: TMemo
        Left = 0
        Top = 32
        Width = 440
        Height = 262
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
      end
      object chk_Minimize: TCheckBox
        Left = 0
        Top = 8
        Width = 200
        Height = 17
        Caption = #1057#1074#1086#1088#1072#1095#1080#1074#1072#1090#1100' '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077
        TabOrder = 1
      end
    end
    object TbSht_DB: TTabSheet
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1041#1044
      ImageIndex = 1
      DesignSize = (
        440
        294)
      object Label1: TLabel
        Left = 8
        Top = 16
        Width = 116
        Height = 13
        Caption = #1050#1072#1090#1072#1083#1086#1075' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093':'
      end
      object db_Status: TShape
        Left = 8
        Top = 0
        Width = 17
        Height = 17
        Hint = #1053#1077#1090' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
        Brush.Color = clRed
        ParentShowHint = False
        Shape = stCircle
        ShowHint = True
      end
      object db_Param_Path: TEdit
        Left = 8
        Top = 32
        Width = 390
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = 'db_Param_Path'
      end
      object Button1: TButton
        Left = 406
        Top = 31
        Width = 25
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 1
      end
      object db_Param_Test: TButton
        Left = 8
        Top = 192
        Width = 100
        Height = 25
        Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100
        TabOrder = 2
        OnClick = db_Param_TestClick
      end
      object db_Param_Default: TButton
        Left = 120
        Top = 192
        Width = 100
        Height = 25
        Caption = #1055#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
        TabOrder = 3
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 64
        Width = 425
        Height = 121
        Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
        TabOrder = 4
        DesignSize = (
          425
          121)
        object Label2: TLabel
          Left = 8
          Top = 24
          Width = 69
          Height = 13
          Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093':'
        end
        object Label3: TLabel
          Left = 8
          Top = 64
          Width = 44
          Height = 13
          Caption = #1046#1091#1088#1085#1072#1083':'
        end
        object Label4: TLabel
          Left = 200
          Top = 64
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
        end
        object Label5: TLabel
          Left = 200
          Top = 24
          Width = 76
          Height = 13
          Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100':'
        end
        object db_Param_DB: TEdit
          Left = 8
          Top = 40
          Width = 169
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = 'db_Param_Path'
        end
        object db_Param_Log: TEdit
          Left = 8
          Top = 80
          Width = 169
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          Text = 'db_Param_Path'
        end
        object db_Param_Password: TEdit
          Left = 200
          Top = 80
          Width = 169
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          PasswordChar = '*'
          TabOrder = 2
          Text = 'db_Param_Path'
        end
        object db_Param_User: TEdit
          Left = 200
          Top = 40
          Width = 169
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 3
          Text = 'db_Param_Path'
        end
      end
    end
    object TbSht_NET: TTabSheet
      Caption = #1057#1077#1090#1100
      ImageIndex = 2
      DesignSize = (
        440
        294)
      object Label6: TLabel
        Left = 8
        Top = 16
        Width = 29
        Height = 13
        Caption = #1055#1086#1088#1090':'
      end
      object NET_Status: TShape
        Left = 8
        Top = 0
        Width = 17
        Height = 17
        Hint = #1053#1077#1090' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
        Brush.Color = clRed
        ParentShowHint = False
        Shape = stCircle
        ShowHint = True
      end
      object NET_Param_Port: TEdit
        Left = 8
        Top = 32
        Width = 169
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = 'NET_Param_Port'
      end
    end
    object TabSheet1: TTabSheet
      Caption = #1064#1072#1073#1083#1086#1085
      ImageIndex = 3
      DesignSize = (
        440
        294)
      object Label7: TLabel
        Left = 8
        Top = 48
        Width = 52
        Height = 13
        Caption = #1054#1073#1099#1095#1085#1099#1081':'
      end
      object Label8: TLabel
        Left = 8
        Top = 112
        Width = 45
        Height = 13
        Caption = #1042#1077#1089#1086#1074#1086#1081':'
      end
      object btn_Help: TBitBtn
        Left = 384
        Top = 16
        Width = 51
        Height = 33
        TabOrder = 0
        OnClick = btn_HelpClick
        Kind = bkHelp
      end
      object Edt_Regular: TEdit
        Left = 8
        Top = 64
        Width = 425
        Height = 49
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        TabOrder = 1
        Text = 'Edt_Regular'
      end
      object Edt_Weight: TEdit
        Left = 8
        Top = 128
        Width = 425
        Height = 49
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        TabOrder = 2
        Text = 'Edit1'
      end
    end
  end
  object ImageList1: TImageList
    Left = 288
  end
  object fp_db: TpFIBDatabase
    DBParams.Strings = (
      '')
    DefaultTransaction = fp_transaction
    DefaultUpdateTransaction = fp_transaction
    SQLDialect = 3
    Timeout = 0
    BeforeDisconnect = fp_dbBeforeDisconnect
    DesignDBOptions = [ddoIsDefaultDatabase, ddoStoreConnected]
    WaitForRestoreConnect = 0
    AfterConnect = fp_dbAfterConnect
    Left = 320
  end
  object fp_transaction: TpFIBTransaction
    DefaultDatabase = fp_db
    TimeoutAction = TARollback
    Left = 352
  end
  object fp_qry_FindWareByBC: TpFIBQuery
    Transaction = fp_transaction
    Database = fp_db
    SQL.Strings = (
      'select '
      '    barcode.barcode,'
      '    barcode.wareid,'
      '    sprt.code,'
      '    sprt.name,'
      '    sprt.price'
      'from sprt'
      '   inner join barcode on (sprt.id = barcode.wareid)'
      'where '
      '   ('
      '      case when :code=0 and (barcode.barcode = :barcode) then 1'
      '           when :code>0 and (sprt.code = :code) then 1'
      '           else 0'
      '      end = 1'
      '   )')
    Left = 384
    qoAutoCommit = True
    qoStartTransaction = True
  end
  object fp_qry_GetIntBC: TpFIBQuery
    Transaction = fp_transaction
    Database = fp_db
    SQL.Strings = (
      
        'SELECT "NAME",  "DATA" FROM INTBARCS WHERE INTBARCS.PREFIXBEG>=S' +
        'UBSTRING(:BARCODE FROM 1 FOR 2) AND INTBARCS.PREFIXEND<=SUBSTRIN' +
        'G(:BARCODE FROM 1 FOR 2) AND LEN(CAST(:BARCODE AS VARCHAR(40)))=' +
        '"LENGTH"')
    Left = 348
    Top = 40
    qoStartTransaction = True
  end
  object idtcpsrvr1: TIdTCPServer
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 30576
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    OnExecute = idtcpsrvr1Execute
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    Left = 416
  end
  object IdEncoder: TIdEncoderMIME
    FillChar = '-'
    Left = 276
    Top = 144
  end
  object IdDecoder: TIdDecoderMIME
    FillChar = '-'
    Left = 340
    Top = 144
  end
end

unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Sockets, StdCtrls, IdTCPServer, IdBaseComponent, IniFiles,
  IdComponent, DB, FIBDatabase, pFIBDatabase, FIBQuery, pFIBQuery,
  ComCtrls, ExtCtrls, ImgList, Math;

type
  TForm_Posrednik = class(TForm)
    idtcpsrvr1: TIdTCPServer;
    fp_db: TpFIBDatabase;
    fp_qry_FindWareByBC: TpFIBQuery;
    fp_transaction: TpFIBTransaction;
    PageControl1: TPageControl;
    TbSht_Log: TTabSheet;
    TbSht_DB: TTabSheet;
    Label1: TLabel;
    db_Param_Path: TEdit;
    memo_log: TMemo;
    Button1: TButton;
    db_Param_Test: TButton;
    db_Param_Default: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    db_Param_DB: TEdit;
    Label3: TLabel;
    db_Param_Log: TEdit;
    db_Param_Password: TEdit;
    Label4: TLabel;
    db_Param_User: TEdit;
    Label5: TLabel;
    ImageList1: TImageList;
    db_Status: TShape;
    TbSht_NET: TTabSheet;
    Label6: TLabel;
    NET_Param_Port: TEdit;
    TabSheet1: TTabSheet;
    Memo_template: TMemo;
    NET_Status: TShape;
    fp_qry_GetIntBC: TpFIBQuery;
    procedure idtcpsrvr1Execute(AThread: TIdPeerThread);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure fp_dbAfterConnect(Sender: TObject);
    procedure db_Param_TestClick(Sender: TObject);
    procedure LoadParamsFromFile();
    procedure SaveParamsToFile();
    procedure ConnectDB();
    procedure fp_dbBeforeDisconnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_Posrednik: TForm_Posrednik;

implementation

uses pFIBProps, StrUtils;

{$R *.dfm}
const
  ESC = #27;
  CR = #13;

procedure StrSplit(Str: string; Delimiter: Char; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter     := Delimiter;
   ListOfStrings.DelimitedText := Str;
end;

function StrSplitW(Str, Delimiter: string; Width, Count:integer):string;
var
  ResultStr:string;
  PosD:integer;
begin
  PosD:=1;
  if count=0 then count:=1000;
  while (count>0) and (PosD<Length(str)) do begin
    ResultStr := MidStr(Str, PosD, Width) + Delimiter;
    inc(PosD, Width);
    dec(Count);
  end;
  StrSplitW := ResultStr;
end;

function NumFormat(num:Extended; Precision, Digits:integer):string;
  StrSplit(CmdStr, ':', ParamS);
  ParamI_1 := 0; ParamI_2 := 0;
  if ParamS.Count>1 then ParamI_1 := StrToIntDef(ParamS[1], 4);
  if ParamS.Count>2 then ParamI_2 := StrToIntDef(ParamS[2], 2);

  ResultStr := ResultStr + FloatToStrF(price, ffFixed, )
end;

function  ParseFormat(FormatStr, name: string; price, total:Currency; qnt:Extended):string;
var
  ResultStr:string;
  CmdStr:string;
  EscPos, EscPosEnd:integer;
  ParamI_1, ParamI_2, ParamI_3:integer;
  Param, ParamS_1, ParamS_2, ParamS_3:string;
  ParamS: TStrings;

begin
  ResultStr := '';
  ParamS := TStrings.Create;
  EscPos := PosEx(FormatStr, '#', 1);
  if EscPos=0 Then
    ResultStr := FormatStr
  else
    While EscPos>0 do begin
      ResultStr := ResultStr +  LeftStr(FormatStr, EscPos);
      Inc(EscPos);
      EscPosEnd := PosEx(FormatStr, '#', EscPos);
      Assert(EscPosEnd=0, 'Не закрыта команда #');

      CmdStr := MidStr(FormatStr, EscPos, EscPosEnd-EscPos);

      if PosEx(FormatStr, 'name', EscPos)=EscPos Then begin
        StrSplit(CmdStr, ':', ParamS);
        ParamI_1 := 0; ParamI_2 := 0;
        if ParamS.Count>1 then ParamI_1 := StrToIntDef(ParamS[1], 0);
        if ParamS.Count>2 then ParamI_2 := StrToIntDef(ParamS[2], 0);

        if ParamI_1>0 then
          ResultStr := ResultStr + StrSplitW(name, #13, ParamI_1, ParamI_2)
        else
          ResultStr := ResultStr + name;

      end
      else if PosEx(FormatStr, 'price', EscPos)=EscPos Then begin
        StrSplit(CmdStr, ':', ParamS);
        ParamI_1 := 0; ParamI_2 := 0;
        if ParamS.Count>1 then ParamI_1 := StrToIntDef(ParamS[1], 4);
        if ParamS.Count>2 then ParamI_2 := StrToIntDef(ParamS[2], 2);

        ResultStr := ResultStr + FloatToStrF(price, ffFixed, )
      end
      else if PosEx(FormatStr, 'total', EscPos)=EscPos Then begin
      end
      else if PosEx(FormatStr, 'qnt', EscPos)=EscPos Then begin
      end;

      FormatStr := MidStr(FormatStr, EscPosEnd+1, Length(FormatStr));
      EscPos := Pos(FormatStr, '#');
    end;
end;

procedure TForm_Posrednik.idtcpsrvr1Execute(AThread: TIdPeerThread);
var
  LCmd: string;
  counter:Integer;
  BarCode: string;
  BarCodeTmplName: String;
  BarCodeTmpl: TStrings;
  BarCodeTmplPos: Integer;
  BarCodeTmplLen: Integer;
  BarCodeTmpl2: TStrings;
  tmpl_code,
  tmpl_barcode:string;
  tmpl_price,
  tmpl_summ,
  tmpl_qnt:Extended;
  good_qnt:Extended;
  good_name: String;
  good_price: Currency;
  good_total: Currency;
  Retn_Str: String;
begin

  BarCodeTmpl := TStringList.Create;
  BarCodeTmpl2 := TStringList.Create;

  with AThread.Connection do
    While Connected do begin

//      try
        LCmd := Trim(ReadLn(CR, 500, 50));
//      except
//        Disconnect;
//        Exit;
//      end;

      if Length(LCmd)<>0 then
        begin
          memo_log.Lines.Add('< '+LCmd);

          good_name := 'Товар не найден.';
          good_qnt   := 0;
          good_price := 0;
          good_total := 0;

          if fp_db.Connected then
            begin
              BarCode := copy(LCmd, 2, 50);
              tmpl_code:='';
              tmpl_barcode:=BarCode;
              tmpl_price:=0;
              tmpl_summ:=0;
              tmpl_qnt:=0;
              fp_qry_GetIntBC.Params.ParamByName('BarCode').AsString := BarCode;
              fp_qry_GetIntBC.ExecQuery;
              if fp_qry_GetIntBC.RecordCount>0 then begin
                //Разбор шаблона
                BarCodeTmplName := fp_qry_GetIntBC.FN('NAME').AsString;
                StrSplit(fp_qry_GetIntBC.FN('DATA').AsString, '|', BarCodeTmpl);
                BarCodeTmplPos := 1;
                for counter:=0 to BarCodeTmpl.Count-1 do begin
                  StrSplit(BarCodeTmpl[counter], ';', BarCodeTmpl2);
                  BarCodeTmplLen := StrToIntDef(BarCodeTmpl2[1], 0);
                  case BarCodeTmpl2[0][1] of
                    '0'://код
                        begin
                          tmpl_code := MidStr(BarCode, BarCodeTmplPos, BarCodeTmplLen);
                        end;
                    '2'://штрихкод
                       begin
                         tmpl_barcode := MidStr(BarCode, BarCodeTmplPos, BarCodeTmplLen);
                       end;
                   '3'://цена
                       begin
                         tmpl_price := StrToFloatDef(MidStr(BarCode, BarCodeTmplPos, BarCodeTmplLen), 0) *
                                       StrToFloatDef(BarCodeTmpl2[2], 0);
                       end;
                   '4'://сумма
                       begin
                         tmpl_summ := StrToFloatDef(MidStr(BarCode, BarCodeTmplPos, BarCodeTmplLen), 0) *
                                       StrToFloatDef(BarCodeTmpl2[2], 0);
                       end;
                   '5'://количество
                       begin
                         tmpl_qnt := StrToFloatDef(MidStr(BarCode, BarCodeTmplPos, BarCodeTmplLen), 0) *
                                       StrToFloatDef(BarCodeTmpl2[2], 0);
                       end;
                   '6'://пропустить
                       begin

                       end;
                  end;

                  Inc(BarCodeTmplPos, BarCodeTmplLen);
                end;

              end;

              //ищем по штрихкоду и коду
              fp_qry_FindWareByBC.Params.ParamByName('BarCode').AsString := tmpl_barcode;
              fp_qry_FindWareByBC.Params.ParamByName('Code').AsInteger := StrToIntDef(tmpl_code, 0);
              fp_qry_FindWareByBC.ExecQuery;
              if fp_qry_FindWareByBC.RecordCount>0 then begin
                  good_name := fp_qry_FindWareByBC.FN('Name').AsString;
                  good_price := fp_qry_FindWareByBC.FN('Price').AsCurrency;
                  if tmpl_summ>0 then
                    good_price := tmpl_summ
                  else
                    if tmpl_qnt>0 then
                      begin
                        good_qnt := tmpl_qnt;
                        if tmpl_price>0 then
                          good_total := tmpl_price
                        else
                          good_total := good_price * tmpl_qnt;
                      end;
                good_total := RoundTo(good_total, -2);
              end
            end
          else
            begin
              good_name := 'База не подключена';
          end;
          //good_name := WrapText(good_name, #13, ['.',' ',#9,'-'], 18); //Разбить на строки по 18 символов
          if good_qnt=0 then
            begin
              good_name := MidStr(good_name, 1, 18)+#13+MidStr(good_name, 1+18, 18)+#13+MidStr(good_name, 1+18+18, 18);
              Retn_Str := #27'B0'#27'%' +good_name+
                          #27'B1'#27'.6'+'Сумма'+#3+#27'B1'#27'.8'+ floattostr(good_total)+#3;
            end
          else
            begin
              good_name := MidStr(good_name, 1, 18)+#13+MidStr(good_name, 1+18, 18)+#13+MidStr(good_name, 1+18+18, 18);
              BarCodeTmpl.Clear;
              BarCodeTmpl.Delimiter     := #13;
              BarCodeTmpl.DelimitedText := good_name;
              while BarCodeTmpl.Count<3 do
                BarCodeTmpl.DelimitedText := BarCodeTmpl.DelimitedText + #13;
              BarCodeTmpl[2] := floattostr(good_price) + '*' + floattostr(good_qnt);

              Retn_Str := #27'B0'#27'%' + BarCodeTmpl.DelimitedText +
                          #27'B1'#27'.6'+'Сумма'+#3+#27'B1'#27'.8'+ floattostr(good_total)+#3;
            end;

          memo_log.Lines.add('> '+Retn_Str);
          WriteLn(Retn_Str);

        end;

    end;
end;

procedure TForm_Posrednik.LoadParamsFromFile();
Var
  iniFile:TIniFile;
begin
  iniFile := TIniFile.Create( ChangeFileExt(Application.ExeName, '.ini') );
  db_Param_Path.Text := iniFile.ReadString('DATABASE', 'Path', 'localhost:d:\atol\db\');
  db_Param_DB.Text   := iniFile.ReadString('DATABASE', 'DB', 'main.gdb');
  db_Param_Log.Text  := iniFile.ReadString('DATABASE', 'LOG','log.gdb');
  db_Param_User.Text := iniFile.ReadString('DATABASE', 'User','SYSDBA');
  db_Param_Password.Text := iniFile.ReadString('DATABASE', 'Password','masterkey');

  NET_Param_Port.Text:= iniFile.ReadString('NET', 'Port','30576');
end;

procedure TForm_Posrednik.SaveParamsToFile();
Var
  iniFile:TIniFile;
begin
  iniFile := TIniFile.Create( ChangeFileExt(Application.ExeName, '.ini') );
  iniFile.WriteString('DATABASE', 'Path', db_Param_Path.Text);
  iniFile.WriteString('DATABASE', 'DB', db_Param_DB.Text);
  iniFile.WriteString('DATABASE', 'LOG', db_Param_Log.Text);
  iniFile.WriteString('DATABASE', 'User', db_Param_User.Text);
  iniFile.WriteString('DATABASE', 'Password', db_Param_Password.Text);

  iniFile.WriteString('NET', 'Port', NET_Param_Port.Text);
end;

procedure TForm_Posrednik.ConnectDB();
begin
  fp_db.DatabaseName := db_Param_Path.Text + db_Param_DB.Text;
  With fp_db.ConnectParams do Begin
    UserName := db_Param_User.Text;
    Password := db_Param_Password.Text;
    CharSet  := 'WIN1251';
  end;
  fp_db.Connected := True;
  try
    fp_db.Open;
  except
    db_Status.Brush.Color := clRed;
    db_Status.Hint := 'Нет подключения';
  end;
end;

procedure TForm_Posrednik.FormCreate(Sender: TObject);
begin

  LoadParamsFromFile();
  ConnectDB();

  idtcpsrvr1.DefaultPort := StrToInt(NET_Param_Port.Text);
  idtcpsrvr1.Active := True;

end;

procedure TForm_Posrednik.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  idtcpsrvr1.Active := False;
  fp_db.Close;
  SaveParamsToFile();
end;

procedure TForm_Posrednik.fp_dbAfterConnect(Sender: TObject);
begin
  db_Status.Brush.Color := clGreen;
  db_Status.Hint := 'Подключено';
end;

procedure TForm_Posrednik.db_Param_TestClick(Sender: TObject);
begin
  ConnectDB();
end;

procedure TForm_Posrednik.fp_dbBeforeDisconnect(Sender: TObject);
begin
  db_Status.Brush.Color := clRed;
  db_Status.Hint := 'Нет подключения';
end;

end.

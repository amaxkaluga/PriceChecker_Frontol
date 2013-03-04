unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Sockets, StdCtrls, IdTCPServer, IdBaseComponent, IniFiles,
  IdComponent, DB, FIBDatabase, pFIBDatabase, FIBQuery, pFIBQuery,
  ComCtrls, ExtCtrls, ImgList, Math, EncdDecd, Buttons, IdCoderMIME,
  IdCoder, IdCoder3to4;

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
    NET_Status: TShape;
    fp_qry_GetIntBC: TpFIBQuery;
    btn_Help: TBitBtn;
    IdEncoder: TIdEncoderMIME;
    IdDecoder: TIdDecoderMIME;
    Label7: TLabel;
    Edt_Regular: TEdit;
    Label8: TLabel;
    Edt_Weight: TEdit;
    chk_Minimize: TCheckBox;
    procedure idtcpsrvr1Execute(AThread: TIdPeerThread);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure fp_dbAfterConnect(Sender: TObject);
    procedure db_Param_TestClick(Sender: TObject);
    procedure LoadParamsFromFile();
    procedure SaveParamsToFile();
    procedure ConnectDB();
    procedure fp_dbBeforeDisconnect(Sender: TObject);
    procedure btn_HelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_Posrednik: TForm_Posrednik;

implementation

uses pFIBProps, StrUtils, IdTCPConnection;

{$R *.dfm}
const
  ESC = #27;
  CR = #13;

procedure StrSplit(Str: string; Delimiter: Char; ListOfStrings: TStrings) ;
begin
  Str := StringReplace(Str, #10, '', [rfReplaceAll]);
  Str := StringReplace(Str, #13, '', [rfReplaceAll]);
  ListOfStrings.Clear;
  ListOfStrings.Delimiter     := Delimiter;
  ListOfStrings.DelimitedText := Str;
end;

function StrSplitW(Str, Delimiter: string; Width, Count:integer):string;
var
  PosD:integer;
begin

  PosD:=1;
  Result := '';

  if count=0 then count:=1000;

  while (count>0) and (PosD<Length(str)) do begin
    Result := Result + MidStr(Str, PosD, Width) + Delimiter;
    inc(PosD, Width);
    dec(Count);
  end;

end;

function NumFormat(num:Extended; var ParamS:TStrings):string; overload;
var
  Precision, Digits:integer;
begin
  Precision := 10; Digits := 2;
  if ParamS.Count>1 then Digits := StrToIntDef(ParamS[2], 2);
  if ParamS.Count>2 then Precision := StrToIntDef(ParamS[1], 10);

  result := FloatToStrF(num, ffFixed, Precision, Digits);
end;

function NumFormat(num:Extended; var ParamS:TStrings; Precision, Digits:integer):string; overload;
begin
  if ParamS.Count>1 then Digits := StrToIntDef(ParamS[1], Digits);
  if ParamS.Count>2 then Precision := StrToIntDef(ParamS[2], Precision);

  result := FloatToStrF(num, ffFixed, Precision, Digits);
end;

Function IsNumber(Var Number:integer; S:String):Boolean;//функция проверяет, является ли строка числом
Var
  Err:Integer;
Begin
  Err := 0;
  S := LowerCase(Trim(S));
  try
    Number := StrToInt(S);
  except
    Err := 1;
  end;
  IsNumber :=  Err = 0;
End;

function  ParseFormat(FormatStr, name: string; price, total:Currency; qnt:Extended):string;
var
  Counter, ParamI_1, ParamI_2:integer;
  Param, ParamS_1:string;
  ParamS, ParamS2: TStrings;
  CurrentMode: integer;
begin
  Result := '';
  ParamS := TStringList.Create;
  ParamS2 := TStringList.Create;
  CurrentMode:=0; //0-текст 1-комманда

  StrSplit(FormatStr, '#', ParamS);
  for Counter:=0 to ParamS.Count-1 do begin
    Param := ParamS[Counter];
    if CurrentMode=0 then
      CurrentMode:=1
    else begin
      CurrentMode := 0;
      Param := Trim(LowerCase(Param));
      if Length(Param)=0 then
        Param := '#'
      else
      if IsNumber(ParamI_1, Param) then
        Param := chr(ParamI_1)
      else begin
        StrSplit(Param, ':', ParamS2);
        ParamS_1 := ParamS2[0];
        if ParamS_1='name' then begin
          ParamI_1 := 0; ParamI_2 := 0;
          if ParamS2.Count>1 then ParamI_1 := StrToIntDef(ParamS2[1], 0);
          if ParamS2.Count>2 then ParamI_2 := StrToIntDef(ParamS2[2], 0);

          if ParamI_1>0 then
            Param := StrSplitW(name, #13, ParamI_1, ParamI_2)
          else
            Param := name;
        end
        else
        if ParamS_1='price' then
          Param := NumFormat(price, ParamS2, 15, 2)
        else
        if ParamS_1='total' then
          Param := NumFormat(total, ParamS2, 15, 2)
        else
        if ParamS_1='qnt' then
          Param := NumFormat(qnt, ParamS2, 15, 4)
      end;
    end;
    Result := Result + Param;
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
                    good_total := tmpl_summ
                  else
                    if tmpl_qnt>0 then
                      begin
                        good_qnt := tmpl_qnt;
                        if tmpl_price>0 then good_price := tmpl_price;
                        good_total := good_price * good_qnt;
                      end;
                good_total := RoundTo(good_total, -2);
              end
            end
          else
            begin
              good_name := 'База не подключена';
          end;

          if good_qnt=0 then
            Retn_Str := ParseFormat(Edt_Regular.Text, good_name, good_price, good_total, good_qnt)
          else
            Retn_Str := ParseFormat(Edt_Weight.Text, good_name, good_price, good_total, good_qnt);

          memo_log.Lines.add('> '+Retn_Str);

          Write(Retn_Str); //Возвращаем на терминал
        end;

    end;
end;

procedure TForm_Posrednik.LoadParamsFromFile();
Var
  iniFile:TIniFile;
  S:String;
begin
  iniFile := TIniFile.Create( ChangeFileExt(Application.ExeName, '.ini') );
  db_Param_Path.Text := iniFile.ReadString('DATABASE', 'Path', 'localhost:d:\atol\db\');
  db_Param_DB.Text   := iniFile.ReadString('DATABASE', 'DB', 'main.gdb');
  db_Param_Log.Text  := iniFile.ReadString('DATABASE', 'LOG','log.gdb');
  db_Param_User.Text := iniFile.ReadString('DATABASE', 'User','SYSDBA');
  db_Param_Password.Text := iniFile.ReadString('DATABASE', 'Password','masterkey');

  NET_Param_Port.Text:= iniFile.ReadString('NET', 'Port','30576');
  S := iniFile.ReadString('TEMPLATE', 'Regular', '');
  if Length(S)=0 then S := '#27#B0#27#%#name:18:3##27#B1#27#.6Сумма#3##27#B1#27#.8#total:2##3#'
                 else S := IdDecoder.DecodeString(S);
  Edt_Regular.Text := S;
  S := iniFile.ReadString('TEMPLATE', 'Weight', '');
  if Length(S)=0 then S := '#27#B0#27#%#name:18:2#Цена:#price:2##27##x2E##x3B#Вес:#qnt:4##3##27#B1#27#.6Сумма#3##27#B1#27#.8#total:2##3#'
                 else S := IdDecoder.DecodeString(S);
  Edt_Weight.Text := S;

  if iniFile.ReadString('GENERIC', 'Minimized','0')='0' then begin
    Form_Posrednik.WindowState := wsNormal;
    chk_Minimize.State := cbUnChecked;
  end else begin
    Form_Posrednik.WindowState := wsMinimized;
    chk_Minimize.State := cbChecked;
  end;

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
  iniFile.WriteString('TEMPLATE', 'Regular', IdEncoder.Encode(Edt_Regular.Text));
  iniFile.WriteString('TEMPLATE', 'Weight', IdEncoder.Encode(Edt_Weight.Text));
  if chk_Minimize.State=cbChecked then
    iniFile.WriteString('GENERIC', 'Minimized', '1')
  else
    iniFile.WriteString('GENERIC', 'Minimized', '0');

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

procedure TForm_Posrednik.btn_HelpClick(Sender: TObject);
{var
  f:Textfile;}
begin
{  AssignFile(f, 'c:\1.txt');
  Rewrite(f);
  Write(f, ParseFormat(Memo_tmpl_regular.Text, 'qwe wer we w werwerwer  wer wer wer we rwerwer', 1.23, 12.34, 0.1234));
  closeFile(f);}
  //Application.MessageBox(PChar(IntToStr(strtoIntDef(Memo_tmpl_regular.Lines[0], 0))), 'xxx');
end;

end.

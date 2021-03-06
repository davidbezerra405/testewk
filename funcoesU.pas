unit funcoesU;

interface
uses System.SysUtils, Vcl.StdCtrls, IniFiles, Vcl.Forms;

function ConfConexaoBanco(): boolean;
function iif(condicao: Boolean; value1, value2 : variant) : variant;
function LocalizarSQL(sTabela, sCodigo: String): boolean;
function StrParaFloat(sValor: String): double;
function LimpaFloat(sValor: String): String;
Procedure FormatarComoMoeda(Componente: TObject; var Key: Char; iDec: integer = 2);

implementation
uses DMU;

function LocalizarSQL(sTabela, sCodigo: String): boolean;
var iCodigo: integer;
begin
   if ((Length(Trim(sCodigo)) = 0) or
       (StrToInt(sCodigo) = 0)) then begin
      Result := False;
      exit;
   end;
   iCodigo := StrToInt(sCodigo);
   DM.pedidodb.Connected := True;
   try
   with DM.SQLLocalizar do begin
        Close;
        SQL.Clear;
        SQL.Add('select * from '+sTabela);
        SQL.Add(' where id = :vid ');
        ParamByName('vid').Value := iCodigo;
        Open;
        if (RecordCount > 0) then begin
            Result := True;
            exit;
        end;
        Result := False;
   end;
   except
     Result := False;
   end;
end;

function StrParaFloat(sValor: String): double;
begin
   result := StrToFloat(LimpaFloat(sValor));
end;

function LimpaFloat(sValor: String): String;
var t, i: integer;
    cOldNum, cNovoNum: String;
begin
   cOldNum := Trim(sValor);
   t := Length(cOldNum);
   cNovoNum := '';
   for i := 1 to t do begin
       if ((CharInSet(cOldNum[i],['0'..'9'])) or (cOldNum[i] = ',')
           or (cOldNum[i] = '-')) then
          cNovoNum := cNovoNum + cOldNum[i];
   end;
   Result := cNovoNum;
end;

function iif(condicao: Boolean; value1, value2 : variant) : variant;
begin
  if (condicao) then result := value1
  else result := value2
end;

Procedure FormatarComoMoeda(Componente: TObject; var Key: Char; iDec: integer = 2);
var str_valor, cDec, cFormat: String;
    dbl_valor, fDiv: double;
    i: integer;
begin
   if Componente is TEdit then begin
      if ( CharInSet(Key,['0'..'9', #8, #9]) ) then begin
         cDec := '';
         for i := 1 to iDec do
             cDec := cDec + '0';
         cDec := Trim(cDec);
         TEdit( Componente ).SelText := '';
         str_valor := TEdit( Componente ).Text;
         if str_valor = EmptyStr then str_valor := '0,'+cDec;
         if CharInSet(Key,['0'..'9']) then str_valor := Concat(str_valor, Key);
         str_valor := Trim( StringReplace( str_valor, '.', '', [rfReplaceAll, rfIgnoreCase] ) );
         str_valor := Trim( StringReplace( str_valor, ',', '', [rfReplaceAll, rfIgnoreCase] ) );
         dbl_valor := StrToFloat( str_valor );
         fDiv := StrToFloat('1'+cDec);
         cFormat := '###,##0.'+cDec;
         dbl_valor := ( dbl_valor / fDiv );
         TEdit( Componente ).SelStart := Length( TEdit( Componente ).Text );
         TEdit( Componente ).Text := FormatFloat( cFormat, dbl_valor );
      end;
      if not( CharInSet(Key,[#8, #9]) ) then key := #0;
   end;
end;

function ConfConexaoBanco(): boolean;
var cresult: boolean;
    iConf: TIniFile;
    cPasta, cArq: string;
    cHostname, cDatabase, cPassword, cUser, cProtocolo: string;
    cPort: integer;
begin
    cresult := false;
    cPasta := ExtractFilePath(Application.ExeName);
    cArq := 'conexaobd.ini';
    if not FileExists(cPasta+cArq) then begin
       Result := cresult;
       exit;
    end;
    iConf := TIniFile.Create(cPasta+cArq);
    try
        cHostname := iConf.ReadString('conexao', 'Hostname', '');
        cPort := iConf.ReadInteger('conexao', 'Port', 0);
        cDatabase := iConf.ReadString('conexao', 'Database', '');
        cPassword := iConf.ReadString('conexao', 'Password', '');
        cUser := iConf.ReadString('conexao', 'User', '');
        cProtocolo := iConf.ReadString('conexao', 'Protocolo', '');
        with DM.pedidoDB do begin
             Connected := False;
             LoginPrompt := False;
             HostName := cHostname;
             Port := cPort;
             Database := cDatabase;
             Password := cPassword;
             User := cUser;
             Protocol := cProtocolo;
        end;
        cresult := true;
    finally
        iConf.Free;
    end;
    Result := cresult;
end;


end.

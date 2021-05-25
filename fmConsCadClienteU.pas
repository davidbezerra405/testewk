unit fmConsCadClienteU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask, Vcl.StdCtrls, Vcl.Buttons,
  Data.DB, ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Grids,
  Vcl.DBGrids;

type
  TfmConsCadClienteF = class(TForm)
    dbCliente: TDBGrid;
    Cliente: TZQuery;
    ClienteS: TDataSource;
    GroupBox1: TGroupBox;
    lbConsultar: TLabel;
    btnRetornar: TBitBtn;
    btnFechar: TBitBtn;
    edConsultar: TEdit;
    btnProcessar: TBitBtn;
    btnLimparConsulta: TBitBtn;
    procedure ProcessarFiltro;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure dbClienteDblClick(Sender: TObject);
    procedure dbClienteTitleClick(Column: TColumn);
    procedure btnProcessarClick(Sender: TObject);
    procedure btnLimparConsultaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmConsCadClienteF: TfmConsCadClienteF;
  iOrdem: integer;
  iOrdemDesc: boolean;
  iOrdemTitle: String;

implementation
uses DMU, FuncoesU;

{$R *.dfm}

procedure TfmConsCadClienteF.ProcessarFiltro;
var cWhere, sConsultar, cDesc, cOrd: String;
begin
   cWhere := '';
   cOrd := iif(iOrdemDesc,' desc','');
   sConsultar := Trim(edConsultar.Text);
   if (Length(sConsultar) > 0) then cDesc := '%'+sConsultar+'%'
   else cDesc := '';
   Cliente.DisableControls;
   try
      DM.pedidoDB.Connected := True;
      with Cliente do begin
           Close;
           SQL.Clear;
           SQL.Add('select * from cliente ');
           if (Length(cDesc) > 0) then begin
              if (Length(cWhere) > 0) then cWhere := cWhere+' or ';
              cWhere := cWhere + '( nome like :vdesc or cidade like :vdesc or uf like :vdesc ) ';
           end;
           if (Length(cWhere) > 0) then
              SQL.Add(' where '+cWhere);
           if (iOrdem = 0) then SQL.Add('order by id'+cOrd)
           else if (iOrdem = 1) then SQL.Add('Order by nome'+cOrd)
           else if (iOrdem = 2) then SQL.Add('Order by cidade'+cOrd+', nome')
           else if (iOrdem = 1) then SQL.Add('Order by uf'+cOrd+', cidade, nome');
           if (Length(cDesc) > 0) then ParamByName('vdesc').Value := cdesc;
           Open;
      end;
   finally
      Cliente.EnableControls;
      dbCliente.Refresh;
   end;
end;

procedure TfmConsCadClienteF.btnLimparConsultaClick(Sender: TObject);
begin
   edConsultar.Clear;
end;

procedure TfmConsCadClienteF.btnProcessarClick(Sender: TObject);
begin
   ProcessarFiltro;
   dbCliente.SetFocus;
end;

procedure TfmConsCadClienteF.dbClienteDblClick(Sender: TObject);
begin
   ModalResult := mrOk;
end;

procedure TfmConsCadClienteF.dbClienteTitleClick(Column: TColumn);
var nOrdem: integer;
    nOrdemTitle: String;
begin
   nOrdem := Column.ID;
   if (nOrdem <> iOrdem) then begin
      dbCliente.Columns[iOrdem].Title.Caption := iOrdemTitle;
      iOrdemTitle := dbCliente.Columns[nOrdem].Title.Caption;
      dbCliente.Columns[nOrdem].Title.Font.Color := clBlue;
      dbCliente.Columns[nOrdem].Title.Font.Style := [fsBold];
      dbCliente.Columns[iOrdem].Title.Font.Color := clWindowText;
      dbCliente.Columns[iOrdem].Title.Font.Style := [];
      iOrdem := nOrdem;
      iOrdemDesc := False;
      ProcessarFiltro;
   end
   else begin
      iOrdemDesc := not iOrdemDesc;
      if (iOrdemDesc) then begin
         iOrdemTitle := dbCliente.Columns[iOrdem].Title.Caption;
         nOrdemTitle := iOrdemTitle + '(v)';
         dbCliente.Columns[iOrdem].Title.Caption := nOrdemTitle;
      end
      else begin
         dbCliente.Columns[iOrdem].Title.Caption := iOrdemTitle;
      end;
      ProcessarFiltro;
   end;
end;

procedure TfmConsCadClienteF.FormActivate(Sender: TObject);
begin
   DM.Pedidodb.Connected := True;
   Cliente.Active := True;
   dbCliente.SetFocus;
end;

procedure TfmConsCadClienteF.FormCreate(Sender: TObject);
begin
   edConsultar.Clear;
   iOrdem := 1;
   dbCliente.Columns[iOrdem].Title.Font.Color := clBlue;
   dbCliente.Columns[iOrdem].Title.Font.Style := [fsBold];
   iOrdemTitle := dbCliente.Columns[iOrdem].Title.Caption;
   iOrdemDesc := False;
   ProcessarFiltro;
end;

procedure TfmConsCadClienteF.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = VK_RETURN) then begin
      ModalResult := mrOk;
   end;
end;

end.

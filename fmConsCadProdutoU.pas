unit fmConsCadProdutoU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Buttons,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Grids, Vcl.DBGrids;

type
  TfmConsCadProdutoF = class(TForm)
    dbProduto: TDBGrid;
    Produto: TZQuery;
    ProdutoS: TDataSource;
    GroupBox1: TGroupBox;
    lbConsultar: TLabel;
    btnRetornar: TBitBtn;
    btnFechar: TBitBtn;
    edConsultar: TEdit;
    btnProcessar: TBitBtn;
    Produtoid: TIntegerField;
    Produtodescricao: TWideStringField;
    Produtoprecovenda: TFloatField;
    btnLimparConsulta: TBitBtn;
    procedure ProcessarFiltro;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnProcessarClick(Sender: TObject);
    procedure dbProdutoDblClick(Sender: TObject);
    procedure dbProdutoTitleClick(Column: TColumn);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnLimparConsultaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmConsCadProdutoF: TfmConsCadProdutoF;
  iOrdem: integer;
  iOrdemDesc: boolean;
  iOrdemTitle: String;

implementation
uses DMU, FuncoesU;

{$R *.dfm}

procedure TfmConsCadProdutoF.ProcessarFiltro;
var cWhere, sConsultar, cDesc, cOrd: String;
begin
   cWhere := '';
   cOrd := iif(iOrdemDesc,' desc','');
   sConsultar := Trim(edConsultar.Text);
   if (Length(sConsultar) > 0) then cDesc := '%'+sConsultar+'%'
   else cDesc := '';
   Produto.DisableControls;
   try
      DM.pedidoDB.Connected := True;
      with Produto do begin
           Close;
           SQL.Clear;
           SQL.Add('select * from produto ');
           if (Length(cDesc) > 0) then begin
              if (Length(cWhere) > 0) then cWhere := cWhere+' or ';
              cWhere := cWhere + '( descricao like :vdesc ) ';
           end;
           if (Length(cWhere) > 0) then
              SQL.Add(' where '+cWhere);
           if (iOrdem = 0) then SQL.Add('order by id'+cOrd)
           else if (iOrdem = 1) then SQL.Add('Order by descricao'+cOrd)
           else if (iOrdem = 2) then SQL.Add('Order by precovenda'+cOrd);
           if (Length(cDesc) > 0) then ParamByName('vdesc').Value := cdesc;
           Open;
      end;
   finally
      Produto.EnableControls;
      dbProduto.Refresh;
   end;
end;

procedure TfmConsCadProdutoF.btnLimparConsultaClick(Sender: TObject);
begin
   edConsultar.Clear;
end;

procedure TfmConsCadProdutoF.btnProcessarClick(Sender: TObject);
begin
   ProcessarFiltro;
   dbProduto.SetFocus;
end;

procedure TfmConsCadProdutoF.dbProdutoDblClick(Sender: TObject);
begin
   ModalResult := mrOk;
end;

procedure TfmConsCadProdutoF.dbProdutoTitleClick(Column: TColumn);
var nOrdem: integer;
    nOrdemTitle: String;
begin
   nOrdem := Column.ID;
   if (nOrdem <> iOrdem) then begin
      dbProduto.Columns[iOrdem].Title.Caption := iOrdemTitle;
      iOrdemTitle := dbProduto.Columns[nOrdem].Title.Caption;
      dbProduto.Columns[nOrdem].Title.Font.Color := clBlue;
      dbProduto.Columns[nOrdem].Title.Font.Style := [fsBold];
      dbProduto.Columns[iOrdem].Title.Font.Color := clWindowText;
      dbProduto.Columns[iOrdem].Title.Font.Style := [];
      iOrdem := nOrdem;
      iOrdemDesc := False;
      ProcessarFiltro;
   end
   else begin
      iOrdemDesc := not iOrdemDesc;
      if (iOrdemDesc) then begin
         iOrdemTitle := dbProduto.Columns[iOrdem].Title.Caption;
         nOrdemTitle := iOrdemTitle + '(v)';
         dbProduto.Columns[iOrdem].Title.Caption := nOrdemTitle;
      end
      else begin
         dbProduto.Columns[iOrdem].Title.Caption := iOrdemTitle;
      end;
      ProcessarFiltro;
   end;
end;

procedure TfmConsCadProdutoF.FormActivate(Sender: TObject);
begin
   DM.Pedidodb.Connected := True;
   Produto.Active := True;
   dbProduto.SetFocus;
end;

procedure TfmConsCadProdutoF.FormCreate(Sender: TObject);
begin
   edConsultar.Clear;
   iOrdem := 1;
   dbProduto.Columns[iOrdem].Title.Font.Color := clBlue;
   dbProduto.Columns[iOrdem].Title.Font.Style := [fsBold];
   iOrdemTitle := dbProduto.Columns[iOrdem].Title.Caption;
   iOrdemDesc := False;
   ProcessarFiltro;
end;

procedure TfmConsCadProdutoF.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = VK_RETURN) then begin
      ModalResult := mrOk;
   end;
end;

end.

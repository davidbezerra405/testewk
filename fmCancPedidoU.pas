unit fmCancPedidoU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, System.UITypes;

type
  TfmCancPedidoF = class(TForm)
    dbPedido: TDBGrid;
    Pedido: TZQuery;
    PedidoS: TDataSource;
    GroupBox1: TGroupBox;
    btnFechar: TBitBtn;
    Pedidoid: TIntegerField;
    Pedidodataemissao: TDateTimeField;
    Pedidoid_cliente: TIntegerField;
    Pedidovalortotal: TFloatField;
    Pedidonomecliente: TWideStringField;
    Pedidocidadecliente: TWideStringField;
    Pedidoufcliente: TWideStringField;
    lbConsultar: TLabel;
    edConsultar: TEdit;
    btnLimparConsulta: TBitBtn;
    bxEmissao: TGroupBox;
    lbDataEmisInicial: TLabel;
    lbDataEmisFinal: TLabel;
    edDataEmissaoInicial: TDateTimePicker;
    edDataEmissaoFinal: TDateTimePicker;
    btnFiltrar: TBitBtn;
    GroupBox2: TGroupBox;
    lbNumPedido: TLabel;
    edNumPedido: TEdit;
    lbDataEmissao: TLabel;
    edDataEmissao: TEdit;
    lbCodCliente: TLabel;
    edNomeCliente: TEdit;
    lbValorTotal: TLabel;
    edValorTotal: TEdit;
    btnExcluirPedido: TBitBtn;
    btnCarregarPedido: TBitBtn;
    procedure ProcessarFiltro;
    procedure LimparCampos;
    procedure edNumPedidoExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dbPedidoDblClick(Sender: TObject);
    procedure dbPedidoTitleClick(Column: TColumn);
    procedure btnLimparConsultaClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnExcluirPedidoClick(Sender: TObject);
    procedure dbPedidoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnCarregarPedidoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmCancPedidoF: TfmCancPedidoF;
  iOrdem: integer;
  iOrdemDesc: boolean;
  iOrdemTitle: String;

implementation
uses DMU, FuncoesU;

{$R *.dfm}

procedure TfmCancPedidoF.LimparCampos;
begin
   edNumPedido.Clear;
   edDataEmissao.Clear;
   edNomeCliente.Clear;
   edValorTotal.Text := '0,00';
   btnExcluirPedido.Enabled := False;
   btnCarregarPedido.Enabled := False;
end;

procedure TfmCancPedidoF.ProcessarFiltro;
var cWhere, sConsultar, cDesc, cOrd: String;
begin
   cWhere := '';
   cOrd := iif(iOrdemDesc,' desc','');
   sConsultar := Trim(edConsultar.Text);
   if (Length(sConsultar) > 0) then cDesc := '%'+sConsultar+'%'
   else cDesc := '';
   if (edDataEmissaoInicial.Date > edDataEmissaoFinal.Date) then begin
      ShowMessage('A data de Emiss?o Inicial deve ser menor/igual a Final.');
      exit;
   end;
   DM.pedidoDB.Connected := True;
   Pedido.DisableControls;
   try
      with Pedido do begin
           Close;
           SQL.Clear;
           SQL.Add('select p.*, ');
           SQL.Add('c.nome as nomecliente, ');
           SQL.Add('c.cidade as cidadecliente, ');
           SQL.Add('c.uf as ufcliente ');
           SQL.Add('from pedido as p ');
           SQL.Add('left join cliente as c on c.id = p.id_cliente ');
           if (Length(cDesc) > 0) then begin
              if (Length(cWhere) > 0) then cWhere := cWhere+' or ';
              cWhere := cWhere + '( c.nome like :vdesc or ' +
                        'c.cidade like :vdesc or c.uf like :vdesc ) ';
           end;
           if (Length(cWhere) > 0) then cWhere := cWhere+' and ';
           cWhere := cWhere + '( date(p.dataemissao) >= :vdataemiini and '+
                     'date(p.dataemissao) <= :vdataemifin ) ';
           if (Length(cWhere) > 0) then
              SQL.Add(' where '+cWhere);
           if (iOrdem = 0) then SQL.Add('order by p.id'+cOrd)
           else if (iOrdem = 1) then SQL.Add('Order by p.dataemissao'+cOrd+', c.nome')
           else if (iOrdem = 2) then SQL.Add('Order by p.valortotal'+cOrd+', c.nome')
           else if (iOrdem = 3) then SQL.Add('Order by p.id_cliente'+cOrd+', p.dataemissao')
           else if (iOrdem = 4) then SQL.Add('Order by c.nome'+cOrd+', p.dataemissao')
           else if (iOrdem = 5) then SQL.Add('Order by c.cidade'+cOrd+', c.nome, p.dataemissao')
           else if (iOrdem = 6) then SQL.Add('Order by c.uf'+cOrd+', c.cidade, c.nome, p.dataemissao');
           if (Length(cDesc) > 0) then ParamByName('vdesc').Value := cdesc;
           ParamByName('vdataemiini').Value := FormatDateTime('yyyy/mm/dd',edDataEmissaoInicial.Date);
           ParamByName('vdataemifin').Value := FormatDateTime('yyyy/mm/dd',edDataEmissaoFinal.Date);
           Open;
      end;
   finally
      Pedido.EnableControls;
      dbPedido.Refresh;
   end;
end;

procedure TfmCancPedidoF.btnCarregarPedidoClick(Sender: TObject);
begin
   if LocalizarSQL('pedido',edNumPedido.Text) then
      ModalResult := mrOk
   else ShowMessage('N?mero do Pedido inv?lido.');
end;

procedure TfmCancPedidoF.btnExcluirPedidoClick(Sender: TObject);
var cMensagem: WideString;
    iIDPedido: integer;
begin
   cMensagem := 'Pedido N?mero: '+edNumPEdido.Text+#13+#10+
                'Data de Emiss?o: '+edDataEmissao.Text+#13+#10+
                'Valor Total R$: '+edValorTotal.Text+#13+#10+
                'Cliente: '+edNomeCliente.Text+#13+#10+#13+#10+
                'Deseja Cancelar este Pedido?';
   if MessageDlg(cMensagem,mtConfirmation,[mbyes,mbno],0)=mryes then begin
      iIDPedido := StrToInt(edNumPEdido.Text);
      try
         with DM.SQLExcluir do begin
              SQL.Clear;
              SQL.Add('start transaction;');
              ExecSQL;
              SQL.Clear;
              SQL.Add('delete pedidoproduto, pedido  from pedidoproduto ');
              SQL.Add('left join pedido on pedidoproduto.id_pedido = pedido.id ');
              SQL.Add('where pedidoproduto.id_pedido = :vid; ');
              ParamByName('vid').Value := iIDPedido;
              ExecSQL;
              SQL.Clear;
              SQL.Add('commit;');
              ExecSQL;
         end;
         LimparCampos;
         Pedido.Refresh;
         dbPEdido.Refresh;
      except
         ShowMessage('Erro no Cancelamento do Pedido.');
      end;
   end;
end;

procedure TfmCancPedidoF.btnFiltrarClick(Sender: TObject);
begin
   ProcessarFiltro;
   dbPedido.SetFocus;
end;

procedure TfmCancPedidoF.btnLimparConsultaClick(Sender: TObject);
begin
   edConsultar.Clear;
end;

procedure TfmCancPedidoF.dbPedidoDblClick(Sender: TObject);
begin
   edNumPedido.Text := Pedido.FindField('id').AsString;
   edNumPedidoExit(nil);
end;

procedure TfmCancPedidoF.dbPedidoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = VK_RETURN) then dbPedidoDblClick(nil);
end;

procedure TfmCancPedidoF.dbPedidoTitleClick(Column: TColumn);
var nOrdem: integer;
    nOrdemTitle: String;
begin
   nOrdem := Column.ID;
   if (nOrdem <> iOrdem) then begin
      dbPedido.Columns[iOrdem].Title.Caption := iOrdemTitle;
      iOrdemTitle := dbPedido.Columns[nOrdem].Title.Caption;
      dbPedido.Columns[nOrdem].Title.Font.Color := clBlue;
      dbPedido.Columns[nOrdem].Title.Font.Style := [fsBold];
      dbPedido.Columns[iOrdem].Title.Font.Color := clWindowText;
      dbPedido.Columns[iOrdem].Title.Font.Style := [];
      iOrdem := nOrdem;
      iOrdemDesc := False;
      ProcessarFiltro;
   end
   else begin
      iOrdemDesc := not iOrdemDesc;
      if (iOrdemDesc) then begin
         iOrdemTitle := dbPedido.Columns[iOrdem].Title.Caption;
         nOrdemTitle := iOrdemTitle + '(v)';
         dbPedido.Columns[iOrdem].Title.Caption := nOrdemTitle;
      end
      else begin
         dbPedido.Columns[iOrdem].Title.Caption := iOrdemTitle;
      end;
      ProcessarFiltro;
   end;
end;

procedure TfmCancPedidoF.edNumPedidoExit(Sender: TObject);
var sCodCliente: String;
begin
   btnExcluirPedido.Enabled := False;
   btnCarregarPedido.Enabled := False;
   if (Length(Trim(edNumPedido.Text)) = 0) then begin
      LimparCampos;
      exit;
   end;
   if (StrToInt(edNumPedido.Text) = 0) then begin
      LimparCampos;
      exit;
   end;
   if LocalizarSQL('pedido',edNumPedido.Text) then begin
      with DM.SQLLocalizar do begin
           edDataEmissao.Text := FindField('dataemissao').Value;
           edValorTotal.Text := FormatFloat('###,###,##0.00',FindField('valortotal').AsFloat);
           sCodCliente := FindField('id_cliente').AsString;
      end;
      if LocalizarSQL('cliente',sCodCliente) then
         edNomeCliente.Text := DM.SQLLocalizar.FindField('nome').AsString
      else edNomeCliente.Text := 'cliente n?o encontrado';
      btnExcluirPedido.Enabled := True;
      btnCarregarPedido.Enabled := True;
      if btnExcluirPedido.Visible then btnExcluirPedido.SetFocus
      else btnCarregarPedido.SetFocus;
   end
   else begin
      ShowMessage('Pedido n?o localizado.');
      edNumPedido.SetFocus;
   end;
end;

procedure TfmCancPedidoF.FormActivate(Sender: TObject);
begin
   DM.Pedidodb.Connected := True;
   Pedido.Active := True;
   edNumPedido.SetFocus;
end;

procedure TfmCancPedidoF.FormCreate(Sender: TObject);
begin
   edConsultar.Clear;
   edDataEmissaoInicial.DateTime := now-8;
   edDataEmissaoFinal.DateTime := now;
   LimparCampos;
   iOrdem := 1;
   dbPedido.Columns[iOrdem].Title.Font.Color := clBlue;
   dbPedido.Columns[iOrdem].Title.Font.Style := [fsBold];
   iOrdemTitle := dbPedido.Columns[iOrdem].Title.Caption;
   iOrdemDesc := False;
   ProcessarFiltro;
end;

end.

unit pedidoU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZAbstractConnection, ZConnection, Vcl.Buttons, Vcl.Mask, Vcl.DBCtrls,
  Vcl.ComCtrls, System.UITypes, ProdutoPedidoClass;

type
  TpedidoF = class(TForm)
    bxListaPedido: TGroupBox;
    dbPedido: TDBGrid;
    bxInclusaoPedido: TGroupBox;
    edNumPedido: TEdit;
    lbNumPedido: TLabel;
    edDataEmissao: TEdit;
    lbDataEmissao: TLabel;
    edCodCliente: TEdit;
    lbCodCliente: TLabel;
    btnConsCliente: TBitBtn;
    edNomeCliente: TEdit;
    lbCodProduto: TLabel;
    edCodProduto: TEdit;
    btnConsProduto: TBitBtn;
    edDescricaoProduto: TEdit;
    lbQuantidade: TLabel;
    edQuantidade: TEdit;
    lbValorUnitario: TLabel;
    edValorUnitario: TEdit;
    lbValorTotal: TLabel;
    edValorTotal: TEdit;
    btnIncluirProduto: TBitBtn;
    btnCancelarProduto: TBitBtn;
    btnExcluirProduto: TBitBtn;
    dbProdutoTmp: TDBGrid;
    lbSomaProduto: TLabel;
    edSomaProduto: TDBEdit;
    btnExcluirPedido: TBitBtn;
    bxBotoes: TGroupBox;
    btnGravar: TBitBtn;
    btnSair: TBitBtn;
    btnCancelar: TBitBtn;
    lbConsultar: TLabel;
    edConsultar: TEdit;
    btnLimparConsulta: TBitBtn;
    bxEmissao: TGroupBox;
    lbDataEmisInicial: TLabel;
    lbDataEmisFinal: TLabel;
    edDataEmissaoInicial: TDateTimePicker;
    edDataEmissaoFinal: TDateTimePicker;
    btnFiltrar: TBitBtn;
    btnCarregarPedido: TBitBtn;
    procedure LimparCampos;
    procedure LimparCamposProduto;
    procedure DesativarCamposProduto;
    procedure AtivarCamposProduto;
    procedure VerificarCliProd;
    procedure CalcularTotalProduto;
    procedure ExcluirProdutoLista;
    function ValidarPedido: boolean;
    function GravarPedido: boolean;
    procedure ProcessarFiltro;
    procedure btnSairClick(Sender: TObject);
    procedure btnLimparConsultaClick(Sender: TObject);
    procedure edCodClienteExit(Sender: TObject);
    procedure edCodProdutoExit(Sender: TObject);
    procedure btnConsClienteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnConsProdutoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edQuantidadeExit(Sender: TObject);
    procedure edValorUnitarioExit(Sender: TObject);
    procedure edValorUnitarioKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelarProdutoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnIncluirProdutoClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure dbProdutoTmpDblClick(Sender: TObject);
    procedure btnExcluirProdutoClick(Sender: TObject);
    procedure edNumPedidoExit(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure dbPedidoDblClick(Sender: TObject);
    procedure dbPedidoTitleClick(Column: TColumn);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnExcluirPedidoClick(Sender: TObject);
    procedure btnCarregarPedidoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  pedidoF: TpedidoF;
  PedProd: TPedidoProduto;
  iOrdem: integer;
  iOrdemDesc: boolean;
  iOrdemTitle: String;

implementation
uses DMU, funcoesU, fmConsCadClienteU, fmConsCadProdutoU, fmCancPedidoU;

{$R *.dfm}

procedure TpedidoF.ProcessarFiltro;
var cWhere, sConsultar, cDesc, cOrd: String;
begin
   cWhere := '';
   cOrd := iif(iOrdemDesc,' desc','');
   sConsultar := Trim(edConsultar.Text);
   if (Length(sConsultar) > 0) then cDesc := '%'+sConsultar+'%'
   else cDesc := '';
   if (edDataEmissaoInicial.Date > edDataEmissaoFinal.Date) then begin
      ShowMessage('A data de Emissão Inicial deve ser menor/igual a Final.');
      exit;
   end;
   DM.pedidoDB.Connected := True;
   DM.Pedido.DisableControls;
   try
      with DM.Pedido do begin
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
      DM.pedido.EnableControls;
      dbPedido.Refresh;
   end;
end;

function TpedidoF.GravarPedido: boolean;
var bNovo: boolean;
    iIDPedido, iIDPedProd, iIDProduto, iQuant: integer;
    dValorTotalNota, dVlUnit, dVlTotal: double;
begin
   DM.somaprodtmp.Open;
   DM.somaprodtmp.Refresh;
   dValorTotalNota := DM.somaprodtmp.FindField('soma').AsFloat;
   if (Length(Trim(edNumPedido.Text)) = 0) then begin
      bNovo := True;
      iIDPedido := 0;
   end
   else begin
      bNovo := False;
      iIDPedido := StrToInt(edNumPedido.Text);
   end;
   try
      with DM.SQLSalvar do begin
           SQL.Clear;
           SQL.Add('start transaction;');
           ExecSQL;
           SQL.Clear;
           if bNovo then begin
              SQL.Add('insert into pedido ( ');
              SQL.Add('dataemissao, id_cliente, ');
              SQL.Add('valortotal ) ');
              SQL.Add('values (');
              SQL.Add(':vdataemissao, :vid_cliente, ');
              SQL.Add(':vvalortotal ) ');
              ParamByName('vdataemissao').Value := now;
              ParamByName('vid_cliente').Value := StrToInt(edCodCliente.Text);
           end
           else begin
              SQL.Add('update pedido set ');
              SQL.Add('valortotal = :vvalortotal ');
              SQL.Add('where id = :vid ');
              ParamByName('vid').Value := iIDPedido;
           end;
           ParamByName('vvalortotal').Value := dValorTotalNota;
           ExecSQL;
      end;
      if bNovo then begin
         with DM.SQLLocalizar do begin
              Close;
              SQL.Clear;
              SQL.Add('select max(id) as maxid from pedido');
              Open;
              if (RecordCount > 0) then begin
                 iIDPedido := FindField('maxid').AsInteger;
                 Close;
              end
              else begin
                 Close;
                 SQL.Clear;
                 SQL.Add('rollback;');
                 ExecSQL;
                 Result := False;
                 exit;
              end;
         end;
      end;
      edNumPedido.Text := IntToStr(iIDPedido);
      with DM.SQLLocalizar do begin
           Close;
           SQL.Clear;
           SQL.Add('select id from pedidoproduto ');
           SQL.Add('where id = :vid ');
      end;
      with DM.SQLInsert do begin
           SQL.Clear;
           SQL.Add('insert into pedidoproduto (');
           SQL.Add('id_pedido, id_produto, ');
           SQL.Add('quantidade, valorunitario, ');
           SQL.Add('valortotal, idalterado) ');
           SQL.Add('values ( ');
           SQL.Add(':vid_pedido, :vid_produto, ');
           SQL.Add(':vquantidade, :vvalorunitario, ');
           SQL.Add(':vvalortotal, :vidalterado) ');
           ParamByName('vid_pedido').Value := iIDPedido;
           ParamByName('vidalterado').Value := 1;
      end;
      with DM.SQLUpdate do begin
           SQL.Clear;
           SQL.Add('update pedidoproduto set ');
           SQL.Add('quantidade = :vquantidade, ');
           SQL.Add('valorunitario = :vvalorunitario, ');
           SQL.Add('valortotal = :vvalortotal, ');
           SQL.Add('idalterado = :vidalterado ');
           SQL.Add('where id = :vid ');
           ParamByName('vidalterado').Value := 1;
      end;
      with DM.pedidoprodutotmp do begin
           DisableControls;
           Open;
           Refresh;
           First;
           while not Eof do begin
                 iQuant := FindField('quantidade').AsInteger;
                 dVlUnit := FindField('valorunitario').AsFloat;
                 dVlTotal := FindField('valortotal').AsFloat;
                 iIDPedProd := FindField('id_pedidoproduto').AsInteger;
                 DM.SQLLocalizar.Close;
                 DM.SQLLocalizar.ParamByName('vid').Value := iIDPedProd;
                 DM.SQLLocalizar.Open;
                 if (DM.SQLLocalizar.RecordCount > 0) then begin
                    DM.SQLUpdate.ParamByName('vid').Value := iIDPedProd;
                    DM.SQLUpdate.ParamByName('vquantidade').Value := iQuant;
                    DM.SQLUpdate.ParamByName('vvalorunitario').Value := dVlUnit;
                    DM.SQLUpdate.ParamByName('vvalortotal').Value := dVlTotal;
                    DM.SQLUpdate.ExecSQL;
                 end
                 else begin
                    iIDProduto := FindField('id_produto').AsInteger;
                    DM.SQLInsert.ParamByName('vid_produto').Value := iIDProduto;
                    DM.SQLInsert.ParamByName('vquantidade').Value := iQuant;
                    DM.SQLInsert.ParamByName('vvalorunitario').Value := dVlUnit;
                    DM.SQLInsert.ParamByName('vvalortotal').Value := dVlTotal;
                    DM.SQLInsert.ExecSQL;
                 end;
                 Next;
           end;
           EnableControls;
      end;
      with DM.SQLUpdate do begin
           SQL.Clear;
           SQL.Add('delete from pedidoproduto ');
           SQL.Add('where id_pedido = :vid_pedido and ');
           SQL.Add('idalterado = 0 ');
           ParamByName('vid_pedido').Value := iIDPedido;
           ExecSQL;
           SQL.Clear;
           SQL.Add('update pedidoproduto set ');
           SQL.Add('idalterado = 0 ');
           SQL.Add('where id_pedido = :vid_pedido ');
           ParamByName('vid_pedido').Value := iIDPedido;
           ExecSQL;
           SQL.Clear;
           SQL.Add('commit;');
           ExecSQL;
      end;
      Result := True;
   except
      DM.pedidoprodutotmp.EnableControls;
      with DM.SQLSalvar do begin
           SQL.Clear;
           SQL.Add('rollback;');
           ExecSQL;
      end;
      Result := False;
   end;
end;

function TpedidoF.ValidarPedido: boolean;
var cMensagem: WideString;
begin
   cMensagem := '';
   if not LocalizarSQL('cliente',edCodCliente.Text) then begin
      cMensagem := cMensagem + '- O Campo Código do Cliente esta inválido!'+#13+#10;
   end;
   if (DM.pedidoprodutotmp.RecordCount <= 0) then begin
      cMensagem := cMensagem + '- Deve ser informado no mínimo um produto!'+#13+#10;
   end;
   if (Length(Trim(cMensagem)) > 0) then begin
      cMensagem := 'ATENÇÂO!'+#13#10+#13#10+
                   'Divergência(s) encontrada(s) no preenchimento.'+#13+#10+
                   #13+#10+cMensagem+#13+#10+
                   'Corrija e tente salvar novamente.'+#13+#10;
      Result := False;
   end
   else begin
      Result := True;
   end;
end;

procedure TpedidoF.VerificarCliProd;
begin
  if ((DM.pedidoprodutotmp.RecordCount > 0) and
      LocalizarSQL('cliente',edCodCliente.Text)) then begin
      btnGravar.Enabled := True;
      btnCancelar.Enabled := True;
   end
   else begin
      btnGravar.Enabled := False;
   end;
end;

procedure TpedidoF.ExcluirProdutoLista;
var iID: integer;
begin
   if (DM.pedidoprodutotmp.RecordCount = 0) then exit;
   if (PedProd <> nil) then FreeAndNil(PedProd);
   PedProd := TPedidoProduto.Create;
   iID := DM.pedidoprodutotmp.FindField('id').AsInteger;
   if PedProd.LerProdPed(iID) then
      btnExcluirProdutoClick(nil);
end;

procedure TpedidoF.DesativarCamposProduto;
begin
   edCodProduto.Enabled := True;
   btnConsProduto.Enabled := True;
   lbQuantidade.Enabled := False;
   lbValorUnitario.Enabled := False;
   lbValorTotal.Enabled := False;
   edQuantidade.Enabled := False;
   edValorUnitario.Enabled := False;
   edValorTotal.Enabled := False;
   btnExcluirProduto.Enabled := False;
   btnCancelarProduto.Enabled := False;
   btnIncluirProduto.Enabled := False;
end;

procedure TpedidoF.AtivarCamposProduto;
begin
   lbQuantidade.Enabled := True;
   lbValorUnitario.Enabled := True;
   lbValorTotal.Enabled := True;
   edQuantidade.Enabled := True;
   edValorUnitario.Enabled := True;
   edValorTotal.Enabled := True;
   btnCancelarProduto.Enabled := True;
   btnIncluirProduto.Enabled := True;
end;

procedure TpedidoF.LimparCampos;
begin
   edNumPedido.Clear;
   edDataEmissao.Text := DateToStr(now);
   edCodCliente.Clear;
   edNomeCliente.Clear;
   LimparCamposProduto;
   edCodCLiente.Enabled := True;
   btnConsCliente.Enabled := True;
   btnExcluirPedido.Visible := True;
   btnCarregarPedido.Visible := True;
end;

procedure TpedidoF.LimparCamposProduto;
begin
   if (PedProd <> nil) then FreeAndNil(PedProd);
   PedProd := TPedidoProduto.Create;
   edCodProduto.Clear;
   edDescricaoProduto.Clear;
   edQuantidade.Text := '1';
   edValorUnitario.Text := '0,00';
   edValorTotal.Text := '0,00';
   DesativarCamposProduto;
   VerificarCliProd;
   if (DM.pedidoprodutotmp.RecordCount > 0) then begin
      edNumPedido.Enabled := False;
      btnCancelar.Enabled := True;
   end
   else begin
      edNumPedido.Enabled := True;
      btnCancelar.Enabled := False;
   end;
   dbProdutoTmp.Refresh;
end;

procedure TpedidoF.CalcularTotalProduto;
var dQuant, dVlUnitario, dVlTotal: double;
begin
   dQuant := StrParaFloat(edQuantidade.Text);
   dVlUnitario := StrParaFloat(edValorUnitario.Text);
   dVlTotal := (dQuant * dVlUnitario);
   edValorTotal.Text := FormatFloat('###,##0.00',dVlTotal);
end;

procedure TpedidoF.dbPedidoDblClick(Sender: TObject);
begin
   if (DM.pedido.RecordCount = 0) then exit;
   if (not edNumPedido.Enabled) then exit;
   edNumPedido.Text := DM.pedido.FindField('id').AsString;
   edNumPedidoExit(nil);
end;

procedure TpedidoF.dbPedidoTitleClick(Column: TColumn);
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

procedure TpedidoF.dbProdutoTmpDblClick(Sender: TObject);
var iID: integer;
begin
   if (DM.pedidoprodutotmp.RecordCount = 0) then exit;
   if (PedProd <> nil) then FreeAndNil(PedProd);
   PedProd := TPedidoProduto.Create;
   iID := DM.pedidoprodutotmp.FindField('id').AsInteger;
   if PedProd.LerProdPed(iID) then begin
      edCodProduto.Text := PedProd.sID_Produto;
      edQuantidade.Text := PedProd.sQuantidade;
      edValorUnitario.Text := PedProd.sValorUnitario;
      edValorTotal.Text := PedProd.sValorTotal;
      edDescricaoProduto.Text := PedProd.sDescProduto;
      btnExcluirProduto.Enabled := True;
      AtivarCamposProduto;
      edCodProduto.Enabled := False;
      btnConsProduto.Enabled := False;
      edQuantidade.SetFocus;
   end;
end;

procedure TpedidoF.btnCancelarClick(Sender: TObject);
begin
   if (PedProd <> nil) then FreeAndNil(PedProd);
   PedProd := TPedidoProduto.Create;
   PedProd.CriarTabelaTemp;
   LimparCampos;
   edNumPedido.SetFocus;
end;

procedure TpedidoF.btnCancelarProdutoClick(Sender: TObject);
begin
   LimparCamposProduto;
   edCodProduto.SetFocus;
end;

procedure TpedidoF.btnCarregarPedidoClick(Sender: TObject);
begin
   if (fmCancPedidoF=nil) then
      Application.CreateForm(TfmCancPedidoF, fmCancPedidoF)
   else fmCancPedidoF.Pedido.Refresh;
   with fmCancPedidoF do begin
        try
           Caption := 'Carregar Pedido';
           btnExcluirPedido.Visible := False;
           btnCarregarPedido.Top := btnExcluirPedido.Top;
           btnCarregarPedido.Left := btnExcluirPedido.Left;
           btnCarregarPedido.Visible := True;
           ShowModal;
           if (ModalResult = mrOk) then begin
              pedidoF.edNumPedido.Text := edNumPedido.Text;
              pedidoF.edNumPedidoExit(nil);
           end;
        finally
           btnCarregarPedido.Visible := False;
           btnExcluirPedido.Visible := True;
           Caption := 'Cancelar Pedido';
        end;
   end;
end;

procedure TpedidoF.btnConsClienteClick(Sender: TObject);
begin
   if (fmConsCadClienteF=nil) then
      Application.CreateForm(TfmConsCadClienteF, fmConsCadClienteF)
   else fmConsCadClienteF.Cliente.Refresh;
   fmConsCadClienteF.ShowModal;
   if (fmConsCadClienteF.ModalResult = mrOk) then begin
       edCodCliente.Text := fmConsCadClienteF.Cliente.FindField('id').AsString;
       edCodClienteExit(nil);
   end;
end;

procedure TpedidoF.btnConsProdutoClick(Sender: TObject);
begin
   if (fmConsCadProdutoF=nil) then
      Application.CreateForm(TfmConsCadProdutoF, fmConsCadProdutoF)
   else fmConsCadProdutoF.Produto.Refresh;
   fmConsCadProdutoF.ShowModal;
   if (fmConsCadProdutoF.ModalResult = mrOk) then begin
       edCodProduto.Text := fmConsCadProdutoF.Produto.FindField('id').AsString;
       edCodProdutoExit(nil);
   end;
end;

procedure TpedidoF.btnExcluirPedidoClick(Sender: TObject);
begin
   if (fmCancPedidoF=nil) then
      Application.CreateForm(TfmCancPedidoF, fmCancPedidoF)
   else fmCancPedidoF.Pedido.Refresh;
   DM.pedido.DisableControls;
   try
      fmCancPedidoF.ShowModal;
   finally
      DM.pedido.Refresh;
      DM.pedido.EnableControls;
      dbPedido.Refresh;
   end;
end;

procedure TpedidoF.btnExcluirProdutoClick(Sender: TObject);
begin
   if MessageDlg('Deseja Excluir o Produto: '+PedProd.sDescProduto+'?',mtConfirmation,[mbyes,mbno],0)=mryes then begin
      if PedProd.Excluir then btnCancelarProdutoClick(nil)
      else ShowMessage('Não foi possível excluir o produto.');
   end;
end;

procedure TpedidoF.btnFiltrarClick(Sender: TObject);
begin
   ProcessarFiltro;
   dbPedido.SetFocus;
end;

procedure TpedidoF.btnGravarClick(Sender: TObject);
begin
   if not ValidarPedido then exit;
   if GravarPedido then begin
      DM.pedido.Refresh;
      ShowMessage('Pedido Número: '+edNumPedido.Text+' Gravado com sucesso.');
      btnCancelarClick(nil);
   end
   else begin
      ShowMessage('ATENÇÂO! O pedido não foi gravado.');
   end;
end;

procedure TpedidoF.btnIncluirProdutoClick(Sender: TObject);
var cMensagem: WideString;
begin
   PedProd.ID := 0;
   PedProd.ID_PedidoProduto := 0;
   PedProd.sID_Produto := edCodProduto.Text;
   PedProd.sQuantidade := edQuantidade.Text;
   PedProd.sValorUnitario := edValorUnitario.Text;
   PedProd.sValorTotal := edValorTotal.Text;
   cMensagem := PedProd.Validar;
   if (Length(cMensagem) > 0) then begin
      ShowMessage(cMensagem);
      exit;
   end;
   if not PedProd.Salvar then ShowMessage('Erro ao Salvar Produto!')
   else btnCancelarProdutoClick(nil);
end;

procedure TpedidoF.btnLimparConsultaClick(Sender: TObject);
begin
   edConsultar.Clear;
end;

procedure TpedidoF.btnSairClick(Sender: TObject);
begin
   Close;
end;

procedure TpedidoF.edCodClienteExit(Sender: TObject);
begin
   btnGravar.Enabled := False;
   btnExcluirPedido.Visible := True;
   btnCarregarPedido.Visible := True;
   edNomeCliente.Clear;
   if (Length(Trim(edCodCliente.Text)) = 0) then exit;
   if (StrToInt(edCodCliente.Text) = 0) then exit;
   if LocalizarSQL('cliente',edCodCliente.Text) then begin
      edNomeCliente.Text := DM.SQLLocalizar.FindField('nome').AsString;
      btnExcluirPedido.Visible := False;
      btnCarregarPedido.Visible := False;
      if (DM.pedidoprodutotmp.RecordCount > 0) then begin
         btnGravar.Enabled := True;
         btnCancelar.Enabled := True;
         edNumPedido.Enabled := False;
      end
      else begin
         btnCancelar.Enabled := False;
         edNumPedido.Enabled := True;
      end;
      if btnConsCliente.Focused then edCodProduto.SetFocus;
   end
   else begin
      edNomeCliente.Text := 'cliente não localizado';
   end;
end;

procedure TpedidoF.edCodProdutoExit(Sender: TObject);
begin
   if (Length(Trim(edCodProduto.Text)) = 0) then exit;
   if (StrToInt(edCodProduto.Text) = 0) then exit;
   if LocalizarSQL('produto',edCodProduto.Text) then begin
      edDescricaoProduto.Text := DM.SQLLocalizar.FindField('descricao').AsString;
      edValorUnitario.Text := FormatFloat('###,##0.00',DM.SQLLocalizar.FindField('precovenda').AsFloat);
      CalcularTotalProduto;
      AtivarCamposProduto;
      if btnConsProduto.Focused then edQuantidade.SetFocus;
   end
   else begin
      edDescricaoProduto.Text := 'produto não localizado';
      edValorUnitario.Text := '0,00';
      DesativarCamposProduto;
   end;
end;

procedure TpedidoF.edNumPedidoExit(Sender: TObject);
begin
   btnGravar.Enabled := False;
   if (Length(Trim(edNumPedido.Text)) = 0) then exit;
   if (StrToInt(edNumPedido.Text) = 0) then exit;
   if LocalizarSQL('pedido',edNumPedido.Text) then begin
      with DM.SQLLocalizar do begin
           edDataEmissao.Text := FindField('dataemissao').Value;
           edCodCliente.Text := FindField('id_cliente').AsString;
      end;
      if LocalizarSQL('cliente',edCodCliente.Text) then
         edNomeCliente.Text := DM.SQLLocalizar.FindField('nome').AsString
      else edNomeCliente.Text := 'cliente não encontrado';
      if (PedProd <> nil) then FreeAndNil(PedProd);
      PedProd := TPedidoProduto.Create;
      PedProd.CriarTabelaTemp;
      PedProd.LerProdutos(StrToInt(edNumPedido.Text));
      dbProdutoTmp.Refresh;
      edNumPedido.Enabled := False;
      edCodCliente.Enabled := False;
      btnConsCliente.Enabled := False;
      btnCancelar.Enabled := True;
      btnExcluirPedido.Visible := False;
      btnCarregarPedido.Visible := False;
      edCodProduto.SetFocus;
   end
   else begin
      ShowMessage('Pedido não localizado.');
      edNumPedido.Clear;
   end;
end;

procedure TpedidoF.edQuantidadeExit(Sender: TObject);
begin
   if (Length(Trim(edQuantidade.Text)) = 0) then edQuantidade.Text := '1';
   if (StrToInt(edQuantidade.Text) <= 0) then edQuantidade.Text := '1';
   CalcularTotalProduto;
end;

procedure TpedidoF.edValorUnitarioExit(Sender: TObject);
begin
   if (Length(Trim(edValorUnitario.Text)) = 0) then edValorUnitario.Text := '0,00';
   edValorUnitario.Text := FormatFloat('###,##0.00',StrParaFloat(edValorUnitario.Text));
   if StrParaFloat(edValorUnitario.Text) <= 0 then
      ShowMessage('Valor Unitário não pode ser Zero!');
   CalcularTotalProduto;
end;

procedure TpedidoF.edValorUnitarioKeyPress(Sender: TObject; var Key: Char);
begin
   FormatarComoMoeda((Sender as TEdit), Key);
end;

procedure TpedidoF.FormActivate(Sender: TObject);
begin
   DM.pedidodb.Connected := True;
   if (PedProd <> nil) then FreeAndNil(PedProd);
   PedProd := TPedidoProduto.Create;
   PedProd.CriarTabelaTemp;
   LimparCampos;
   DM.pedido.Open;
end;

procedure TpedidoF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if MessageDlg('Deseja sair do sistema?',mtConfirmation,[mbyes,mbno],0)<>mryes then begin
      Action := caNone;
      exit;
   end;
   if (fmCancPedidoF<>nil) then FreeAndNil(fmCancPedidoF);
   if (fmConsCadProdutoF<>nil) then FreeAndNil(fmConsCadProdutoF);
   if (fmConsCadClienteF<>nil) then FreeAndNil(fmConsCadClienteF);
   if (PedProd<>nil) then FreeAndNil(PedProd);
   DM.pedidodb.Connected := False;
   Application.Terminate;
end;

procedure TpedidoF.FormCreate(Sender: TObject);
begin
   iOrdem := 0;
   dbPedido.Columns[iOrdem].Title.Font.Color := clBlue;
   dbPedido.Columns[iOrdem].Title.Font.Style := [fsBold];
   iOrdemTitle := dbPedido.Columns[iOrdem].Title.Caption;
   iOrdemDesc := False;
   btnGravar.Enabled := False;
   btnCancelar.Enabled := False;
   edConsultar.Clear;
   edDataEmissaoInicial.DateTime := now-8;
   edDataEmissaoFinal.DateTime := now;
   ProcessarFiltro;
end;

procedure TpedidoF.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (Key = VK_F2) then begin
      if edCodCliente.Focused then btnConsClienteClick(nil)
      else if edCodProduto.Focused then btnConsProdutoClick(nil)
      else dbPedido.SetFocus;
   end;
   if (Key = VK_DELETE) then begin
      if dbProdutoTmp.Focused then ExcluirProdutoLista;
   end;
   if (Key = VK_RETURN) then begin
      if dbProdutoTmp.Focused then dbProdutoTmpDblClick(nil)
      else if dbPedido.Focused then dbPedidoDblClick(nil);
   end;
end;

end.

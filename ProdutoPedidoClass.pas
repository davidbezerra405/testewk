unit ProdutoPedidoClass;

interface
   uses SysUtils;

   Type
     TPedidoProduto = class
       private
          FID_Produto: integer;
          FID_PedidoProduto: integer;
          FValorUnitario: double;
          FID: integer;
          FValorTotal: double;
          FQuantidade: integer;
          FsID_Produto: String;
          FsDescProduto: String;
          FsID_PedidoProduto: String;
          FsValorUnitario: String;
          FsID: String;
          FsValorTotal: String;
          FsQuantidade: String;
          procedure SetID(const Value: integer);
          procedure SetsID(const Value: String);
          procedure SetID_PedidoProduto(const Value: integer);
          procedure SetsID_PedidoProduto(const Value: String);
          procedure SetID_Produto(const Value: integer);
          procedure SetsID_Produto(const Value: String);
          procedure SetQuantidade(const Value: integer);
          procedure SetsQuantidade(const Value: String);
          procedure SetValorTotal(const Value: double);
          procedure SetsValorTotal(const Value: String);
          procedure SetValorUnitario(const Value: double);
          procedure SetsValorUnitario(const Value: String);
       protected
       public
          property ID: integer read FID write SetID;
          property ID_PedidoProduto: integer read FID_PedidoProduto write SetID_PedidoProduto;
          property ID_Produto: integer read FID_Produto write SetID_Produto;
          property Quantidade: integer read FQuantidade write SetQuantidade;
          property ValorUnitario: double read FValorUnitario write SetValorUnitario;
          property ValorTotal: double read FValorTotal write SetValorTotal;
          property sID: String read FsID write SetsID;
          property sID_PedidoProduto: String read FsID_PedidoProduto write SetsID_PedidoProduto;
          property sID_Produto: String read FsID_Produto write SetsID_Produto;
          property sDescProduto: String read FsDescProduto;
          property sQuantidade: String read FsQuantidade write SetsQuantidade;
          property sValorUnitario: String read FsValorUnitario write SetsValorUnitario;
          property sValorTotal: String read FsValorTotal write SetsValorTotal;
          function LerDescProduto: String;
          function CriarTabelaTemp: boolean;
          function Salvar(): boolean;
          function Validar(): WideString;
          function LerProdPed(iID: integer): boolean;
          function LerProdutos(iID: integer): boolean;
          function Excluir: boolean;
       {published}
     end;

implementation
uses DMU, FuncoesU;

const NOMETABELA: String = 'pedidoprodutotmp';

{ TPedidoProduto }

function TPedidoProduto.LerProdutos(iID: integer): boolean;
begin
   DM.pedidoprodutotmp.Close;
   DM.somaprodtmp.Close;
   try
      with DM.SQLSalvar do begin
           Close;
           SQL.Clear;
           SQL.Add('start transaction');
           ExecSQL;
           SQL.Clear;
           SQL.Add('insert into '+NOMETABELA );
           SQL.Add('( id_pedidoproduto, id_produto, ');
           SQL.Add('quantidade, valorunitario,  ');
           SQL.Add('valortotal) ');
           SQL.Add('select pp.id, pp.id_produto, ');
           SQL.Add('pp.quantidade, pp.valorunitario, ');
           SQL.Add('pp.valortotal ');
           SQL.Add('from pedidoproduto as pp ');
           SQL.Add('where pp.id_pedido = :vid_pedido ');
           SQL.Add('order by pp.id ');
           ParamByName('vid_pedido').Value := iID;
           ExecSQL;
           SQL.Clear;
           SQL.Add('commit');
           ExecSQL;
      end;
      Result := True;
   except
      Result := False;
   end;
   DM.pedidoprodutotmp.Open;
   DM.pedidoprodutotmp.Refresh;
   DM.somaprodtmp.Open;
   DM.somaprodtmp.Refresh;
end;

function TPedidoProduto.Excluir: boolean;
begin
   DM.pedidoprodutotmp.Close;
   DM.somaprodtmp.Close;
   try
      with DM.SQLExcluir do begin
           SQL.Clear;
           SQL.Add('start transaction;');
           ExecSQL;
           SQL.Clear;
           SQL.Add('delete from '+NOMETABELA );
           SQL.Add(' where id = :vid;');
           ParamByName('vid').Value := ID;
           ExecSQL;
           SQL.Clear;
           SQL.Add('commit;');
           ExecSQL;
      end;
      Result := True;
   except
      Result := False;
   end;
   DM.pedidoprodutotmp.Open;
   DM.somaprodtmp.Open;
end;

function TPedidoProduto.LerDescProduto: String;
begin
   if LocalizarSQL('produto',FsID_Produto) then begin
      fsDescProduto := DM.SQLLocalizar.FindField('descricao').Value;
      Result := fsDescProduto;
   end
   else begin
      Result := '';
   end;
end;

function TPedidoProduto.LerProdPed(iID: integer): boolean;
begin
   if LocalizarSQL(NOMETABELA,IntToStr(iID)) then begin
      with DM.SQLLocalizar do begin
           ID := FindField('id').AsInteger;
           ID_PedidoProduto := FindField('id_pedidoproduto').AsInteger;
           ID_Produto := FindField('id_produto').AsInteger;
           Quantidade := FindField('quantidade').AsInteger;
           ValorUnitario := FindField('valorunitario').AsFloat;
           ValorTotal := FindField('valortotal').AsFloat;
      end;
      LerDescProduto;
      Result := True;
   end
   else begin
      Result := False;
   end;
end;

function TPedidoProduto.Validar(): WideString;
var cMensagem: WideString;
begin
   cMensagem := '';
   if not LocalizarSQL('produto',IntToStr(ID_Produto)) then begin
      cMensagem := cMensagem + '- O Campo C?digo do Produto esta inv?lido!'+#13+#10;
   end;
   if (Quantidade <= 0) then begin
      cMensagem := cMensagem + '- O Campo Quantidade deve ser maior que zero!'+#13+#10;
   end;
   if (ValorUnitario <= 0) then begin
      cMensagem := cMensagem + '- O Campo Valor Unit?rio deve ser maior que zero!'+#13+#10;
   end;
   if (Length(Trim(cMensagem)) > 0) then begin
      cMensagem := 'ATEN??O!'+#13#10+#13#10+
                   'Diverg?ncia(s) encontrada(s) no preenchimento.'+#13+#10+
                   #13+#10+cMensagem+#13+#10+
                   'Corrija e tente salvar novamente.'+#13+#10;
   end;
   Result := cMensagem;
end;

function TPedidoProduto.Salvar(): boolean;
begin
   try
      with DM.SQLSalvar do begin
           SQL.Clear;
           SQL.Add('start transaction');
           ExecSQL;
           SQL.Clear;
           if (ID = 0) then begin // incluir novo produto
              SQL.Add('insert into '+NOMETABELA+' ( ');
              SQL.Add('id_pedidoproduto, id_produto, ');
              SQL.Add('quantidade, valorunitario, ');
              SQL.Add('valortotal) ');
              SQL.Add('values ( ');
              SQL.Add(':vid_pedidoproduto, :vid_produto, ');
              SQL.Add(':vquantidade, :vvalorunitario, ');
              SQL.Add(':vvalortotal)');
              ParamByName('vid_pedidoproduto').Value := ID_PedidoProduto;
              ParamByName('vid_produto').Value := ID_Produto;
           end
           else begin // alterar produto
              SQL.Add('update '+NOMETABELA+' set ');
              SQL.Add('quantidade = :vquantidade, ');
              SQL.Add('valorunitario = :vvalorunitario, ');
              SQL.Add('valortotal = :vvalortotal ');
              SQL.Add('where id = :vid ');
              ParamByName('vid').Value := ID;
           end;
           ParamByName('vquantidade').Value := Quantidade;
           ParamByName('vvalorunitario').Value := ValorUnitario;
           ParamByName('vvalortotal').Value := ValorTotal;
           ExecSQL;
           SQL.Clear;
           SQL.Add('commit');
           ExecSQL;
      end;
      DM.pedidoprodutotmp.Refresh;
      DM.pedidoprodutotmp.Last;
      DM.somaprodtmp.Refresh;
      Result := True;
   except
      Result := False;
   end;
end;

function TPedidoProduto.CriarTabelaTemp: boolean;
begin
   DM.pedidoprodutotmp.Close;
   DM.somaprodtmp.Close;
   try
      with DM.SQLCriarTabela do begin
           SQL.Clear;
           SQL.Add('start transaction');
           ExecSQL;
           SQL.Clear;
           SQL.Add('drop table if exists '+NOMETABELA);
           ExecSQL;
           SQL.Clear;
           SQL.Add('create table '+NOMETABELA);
           SQL.Add('(id int primary key auto_increment not null, ');
           SQL.Add('id_pedidoproduto int, ');
           SQL.Add('id_produto int, ');
           SQL.Add('quantidade int, ');
           SQL.Add('valorunitario double, ');
           SQL.Add('valortotal double ) ');
           ExecSQL;
           SQL.Clear;
           SQL.Add('commit');
           ExecSQL;
      end;
      Result := True;
   except
      Result := False;
   end;
   DM.pedidoprodutotmp.Open;
   DM.pedidoprodutotmp.Refresh;
   DM.somaprodtmp.Open;
   DM.somaprodtmp.Refresh;
end;

procedure TPedidoProduto.SetID(const Value: integer);
begin
   if (Length(FsID) = 0) then FID := Value;
   if (Length(FsID) = 0) then FsID := IntToStr(Value);
end;

procedure TPedidoProduto.SetsID(const Value: String);
begin
   if (Length(FsID) = 0) then FsID := Value;
   if (Length(FsID) = 0) then FID := StrToInt(Value);
end;

procedure TPedidoProduto.SetID_PedidoProduto(const Value: integer);
begin
  if (Length(FsID_PedidoProduto) = 0) then FID_PedidoProduto := Value;
  if (Length(FsID_PedidoProduto) = 0) then FsID_PedidoProduto := IntToStr(Value);
end;

procedure TPedidoProduto.SetsID_PedidoProduto(const Value: String);
begin
  if (Length(FsID_PedidoProduto) = 0) then FsID_PedidoProduto := Value;
  if (Length(FsID_PedidoProduto) = 0) then FID_PedidoProduto := StrToInt(Value);
end;

procedure TPedidoProduto.SetID_Produto(const Value: integer);
begin
   FID_Produto := Value;
   FsID_Produto := IntToStr(Value);
end;

procedure TPedidoProduto.SetsID_Produto(const Value: String);
begin
   FsID_Produto := Value;
   FID_Produto := StrToInt(Value);
end;

procedure TPedidoProduto.SetQuantidade(const Value: integer);
begin
  FQuantidade := Value;
  FsQuantidade := IntToStr(Value);
end;

procedure TPedidoProduto.SetsQuantidade(const Value: String);
begin
  FsQuantidade := Value;
  FQuantidade := StrToInt(Value);
end;

procedure TPedidoProduto.SetValorTotal(const Value: double);
begin
  FValorTotal := Value;
  FsValorTotal := FormatFloat('###,###,##0.00',Value);
end;

procedure TPedidoProduto.SetsValorTotal(const Value: String);
begin
  FsValorTotal := Value;
  FValorTotal := StrparaFloat(Value);
end;

procedure TPedidoProduto.SetValorUnitario(const Value: double);
begin
  FValorUnitario := Value;
  FsValorUnitario := FormatFloat('###,###,##0.00',Value);
end;

procedure TPedidoProduto.SetsValorUnitario(const Value: String);
begin
  FsValorUnitario := Value;
  FValorUnitario := StrparaFloat(Value);
end;

end.

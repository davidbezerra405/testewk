unit DMU;

interface

uses
  System.SysUtils, System.Classes, Data.DB, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZAbstractConnection, ZConnection,
  Vcl.Forms, Vcl.Dialogs;

type
  TDM = class(TDataModule)
    pedidodb: TZConnection;
    pedidoprodutotmp: TZQuery;
    pedidoprodutotmpS: TDataSource;
    cliente: TZQuery;
    produto: TZQuery;
    produtoid: TIntegerField;
    produtodescricao: TWideStringField;
    produtoprecovenda: TFloatField;
    clienteS: TDataSource;
    produtoS: TDataSource;
    pedido: TZQuery;
    pedidoid: TIntegerField;
    pedidodataemissao: TDateTimeField;
    pedidoid_cliente: TIntegerField;
    pedidovalortotal: TFloatField;
    pedidonomecliente: TWideStringField;
    pedidocidadecliente: TWideStringField;
    pedidoufcliente: TWideStringField;
    pedidoS: TDataSource;
    pedidoproduto: TZQuery;
    pedidoprodutoid: TIntegerField;
    pedidoprodutoid_pedido: TIntegerField;
    pedidoprodutoid_produto: TIntegerField;
    pedidoprodutoquantidade: TIntegerField;
    pedidoprodutovalorunitario: TFloatField;
    pedidoprodutovalortotal: TFloatField;
    pedidoprodutodescricaoproduto: TWideStringField;
    pedidoprodutoprecoproduto: TFloatField;
    pedidoprodutoS: TDataSource;
    somaprodtmp: TZQuery;
    somaprodtmpsoma: TFloatField;
    somaprodtmpS: TDataSource;
    SQLLocalizar: TZQuery;
    SQLCriarTabela: TZQuery;
    SQLSalvar: TZQuery;
    pedidoprodutotmpid_pedidoproduto: TIntegerField;
    pedidoprodutotmpid_produto: TIntegerField;
    pedidoprodutotmpquantidade: TIntegerField;
    pedidoprodutotmpvalorunitario: TFloatField;
    pedidoprodutotmpvalortotal: TFloatField;
    pedidoprodutotmpdescricaoproduto: TWideStringField;
    pedidoprodutotmpprecoproduto: TFloatField;
    SQLExcluir: TZQuery;
    pedidoprodutotmpid: TIntegerField;
    SQLInsert: TZQuery;
    SQLUpdate: TZQuery;
    pedidoprodutoidalterado: TShortintField;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation
uses funcoesU;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
   pedidodb.Connected := False;
   if ConfConexaoBanco() then begin
   pedidodb.Connected := True;
   end
   else begin
      ShowMessage('Erro na conexão com o banco de dados.');
      Application.Terminate;
   end;
end;

end.

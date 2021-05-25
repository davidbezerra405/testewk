program testewk;

uses
  Vcl.Forms,
  DMU in 'DMU.pas' {DM: TDataModule},
  pedidoU in 'pedidoU.pas' {pedidoF},
  funcoesU in 'funcoesU.pas',
  fmConsCadClienteU in 'fmConsCadClienteU.pas' {fmConsCadClienteF},
  fmConsCadProdutoU in 'fmConsCadProdutoU.pas' {fmConsCadProdutoF},
  ProdutoPedidoClass in 'ProdutoPedidoClass.pas',
  fmCancPedidoU in 'fmCancPedidoU.pas' {fmCancPedidoF},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TpedidoF, pedidoF);
  Application.Run;
end.

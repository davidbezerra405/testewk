object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 398
  Width = 454
  object pedidodb: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    Properties.Strings = (
      'controls_cp=CP_UTF16')
    HostName = 'localhost'
    Port = 3306
    Database = 'testewk'
    User = 'david'
    Password = 'maktub2511'
    Protocol = 'mysql-5'
    Left = 17
    Top = 16
  end
  object pedidoprodutotmp: TZQuery
    Connection = pedidodb
    CachedUpdates = True
    SQL.Strings = (
      'select pp.*,'
      'p.descricao as descricaoproduto,'
      'p.precovenda as precoproduto'
      'from pedidoprodutotmp as pp'
      'left join produto as p on p.id = pp.id_produto')
    Params = <>
    Left = 32
    Top = 160
    object pedidoprodutotmpid_pedidoproduto: TIntegerField
      FieldName = 'id_pedidoproduto'
    end
    object pedidoprodutotmpid_produto: TIntegerField
      FieldName = 'id_produto'
    end
    object pedidoprodutotmpquantidade: TIntegerField
      FieldName = 'quantidade'
      DisplayFormat = '###,###,##0'
    end
    object pedidoprodutotmpvalorunitario: TFloatField
      FieldName = 'valorunitario'
      DisplayFormat = '###,###,##0.00'
    end
    object pedidoprodutotmpvalortotal: TFloatField
      FieldName = 'valortotal'
      DisplayFormat = '###,###,##0.00'
    end
    object pedidoprodutotmpdescricaoproduto: TWideStringField
      FieldName = 'descricaoproduto'
      Required = True
      Size = 50
    end
    object pedidoprodutotmpprecoproduto: TFloatField
      FieldName = 'precoproduto'
    end
    object pedidoprodutotmpid: TIntegerField
      FieldName = 'id'
      Required = True
    end
  end
  object pedidoprodutotmpS: TDataSource
    DataSet = pedidoprodutotmp
    Left = 32
    Top = 216
  end
  object cliente: TZQuery
    Connection = pedidodb
    SQL.Strings = (
      'select id, nome, cidade, uf '
      'from cliente'
      'order by id')
    Params = <>
    Left = 89
    Top = 16
  end
  object produto: TZQuery
    Connection = pedidodb
    SQL.Strings = (
      'select id, descricao, precovenda'
      'from produto'
      'order by id')
    Params = <>
    Left = 145
    Top = 16
    object produtoid: TIntegerField
      FieldName = 'id'
      Required = True
    end
    object produtodescricao: TWideStringField
      FieldName = 'descricao'
      Required = True
      Size = 50
    end
    object produtoprecovenda: TFloatField
      FieldName = 'precovenda'
      DisplayFormat = '###,###,##0.00'
    end
  end
  object clienteS: TDataSource
    DataSet = cliente
    Left = 89
    Top = 72
  end
  object produtoS: TDataSource
    DataSet = produto
    Left = 145
    Top = 72
  end
  object pedido: TZQuery
    Connection = pedidodb
    SQL.Strings = (
      'select p.*, '
      'c.nome as nomecliente,'
      'c.cidade as cidadecliente,'
      'c.uf as ufcliente'
      'from pedido as p'
      'left join cliente as c on c.id = p.id_cliente')
    Params = <>
    Left = 217
    Top = 16
    object pedidoid: TIntegerField
      FieldName = 'id'
      Required = True
    end
    object pedidodataemissao: TDateTimeField
      FieldName = 'dataemissao'
    end
    object pedidoid_cliente: TIntegerField
      FieldName = 'id_cliente'
    end
    object pedidovalortotal: TFloatField
      FieldName = 'valortotal'
      DisplayFormat = '###,###,##0.00'
    end
    object pedidonomecliente: TWideStringField
      FieldName = 'nomecliente'
      Required = True
      Size = 50
    end
    object pedidocidadecliente: TWideStringField
      FieldName = 'cidadecliente'
      Required = True
      Size = 40
    end
    object pedidoufcliente: TWideStringField
      FieldName = 'ufcliente'
      Size = 2
    end
  end
  object pedidoS: TDataSource
    DataSet = pedido
    Left = 217
    Top = 72
  end
  object pedidoproduto: TZQuery
    Connection = pedidodb
    SQL.Strings = (
      'select pp.*,'
      'p.descricao as descricaoproduto,'
      'p.precovenda as precoproduto'
      'from pedidoproduto as pp'
      'left join produto as p on p.id = pp.id_produto')
    Params = <>
    Left = 273
    Top = 16
    object pedidoprodutoid: TIntegerField
      FieldName = 'id'
      Required = True
    end
    object pedidoprodutoid_pedido: TIntegerField
      FieldName = 'id_pedido'
    end
    object pedidoprodutoid_produto: TIntegerField
      FieldName = 'id_produto'
    end
    object pedidoprodutoquantidade: TIntegerField
      FieldName = 'quantidade'
      DisplayFormat = '###,###,##0'
    end
    object pedidoprodutovalorunitario: TFloatField
      FieldName = 'valorunitario'
      DisplayFormat = '###,###,##0.00'
    end
    object pedidoprodutovalortotal: TFloatField
      FieldName = 'valortotal'
      DisplayFormat = '###,###,##0.00'
    end
    object pedidoprodutodescricaoproduto: TWideStringField
      FieldName = 'descricaoproduto'
      Required = True
      Size = 50
    end
    object pedidoprodutoprecoproduto: TFloatField
      FieldName = 'precoproduto'
      DisplayFormat = '###,###,##0.00'
    end
    object pedidoprodutoidalterado: TShortintField
      FieldName = 'idalterado'
    end
  end
  object pedidoprodutoS: TDataSource
    DataSet = pedidoproduto
    Left = 281
    Top = 72
  end
  object somaprodtmp: TZQuery
    Connection = pedidodb
    SQL.Strings = (
      'select sum(valortotal) as soma'
      'from pedidoprodutotmp'
      '')
    Params = <>
    Left = 120
    Top = 160
    object somaprodtmpsoma: TFloatField
      FieldName = 'soma'
      ReadOnly = True
      DisplayFormat = '###,###,##0.00'
    end
  end
  object somaprodtmpS: TDataSource
    DataSet = somaprodtmp
    Left = 120
    Top = 216
  end
  object SQLLocalizar: TZQuery
    Connection = pedidodb
    Params = <>
    Left = 25
    Top = 280
  end
  object SQLCriarTabela: TZQuery
    Connection = pedidodb
    Params = <>
    Left = 25
    Top = 336
  end
  object SQLSalvar: TZQuery
    Connection = pedidodb
    Params = <>
    Left = 121
    Top = 272
  end
  object SQLExcluir: TZQuery
    Connection = pedidodb
    Params = <>
    Left = 113
    Top = 336
  end
  object SQLInsert: TZQuery
    Connection = pedidodb
    Params = <>
    Left = 185
    Top = 272
  end
  object SQLUpdate: TZQuery
    Connection = pedidodb
    Params = <>
    Left = 185
    Top = 336
  end
end

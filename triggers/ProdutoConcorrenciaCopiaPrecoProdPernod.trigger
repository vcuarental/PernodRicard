/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
**********************************************************************************
* 
* NAME: ProdutoConcorrenciaCopiaPrecoProdPernod.trigger
* AUTHOR: ROGÉRIO ALVARENGA                        DATE: 
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                          DATE: 08/01/2013
*******************************************************************************/
trigger ProdutoConcorrenciaCopiaPrecoProdPernod on Produto_Concorr_ncia__c (before update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

  Map< String, List< Produto_Concorr_ncia__c > > lMapPernodProds = new Map< String, List< Produto_Concorr_ncia__c > >();
  Map< String, List< Produto_Concorr_ncia__c > > lMapConcProds = new Map< String, List< Produto_Concorr_ncia__c > >();
  List< Produto_Concorr_ncia__c > lList;
  Id idRecTypePC = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard' );
  
  Set< String > lSetProdIDs = new Set< String >();
  for ( Produto_Concorr_ncia__c p : trigger.new ){
    if ( !lSetProdIDs.contains( p.id ) && idRecTypePC ==  p.RecordTypeId ){
      lSetProdIDs.add( p.id );
    }
  }
  List< String > lListProdIds = new List< String >();
  lListProdIds.addAll( lSetProdIDs );
  
  List< Produto_Concorr_ncia__c > lListProd;

   if(!Utils.wasMigrationDone('1')) {  
      lListProd = [ SELECT Produto_PERNOD__c, Produto_PERNOD__r.SKU__c 
                                  FROM Produto_Concorr_ncia__c WHERE id=:lListProdIds
                                  AND RecordTypeId =: idRecTypePC];
    }else{
      lListProd = [ SELECT LAT_Product__c, LAT_Product__r.LAT_SKU__c 
                                  FROM Produto_Concorr_ncia__c WHERE id=:lListProdIds
                                  AND RecordTypeId =: idRecTypePC];
    }
                                  
  Map< String, String > lMapProd = new Map< String, String >();
  for ( Produto_Concorr_ncia__c lProd : lListProd ){
    if(!Utils.wasMigrationDone('1')) {  
      lMapProd.put( lProd.Produto_PERNOD__c, lProd.Produto_PERNOD__r.SKU__c );
    }else{
      lMapProd.put( lProd.LAT_Product__c, lProd.LAT_Product__r.LAT_SKU__c );
    }
  }
  
  for ( Produto_Concorr_ncia__c p : trigger.new )
  {
    if( idRecTypePC != p.RecordTypeId ) continue;
    
    // Produtos Pernod
    String lKey;
    if(!Utils.wasMigrationDone('1')) {  
      lKey = lMapProd.get( p.Produto_PERNOD__c );
    }else{
      lKey = lMapProd.get( p.LAT_Product__c );
    }
    lList = lMapPernodProds.get( lKey );
    if ( lList == null )
    {
      lList = new List< Produto_Concorr_ncia__c >();
      lMapPernodProds.put( lKey, lList );
    }
    lList.add( p );
    
    // Produtos Concorrentes
    lList = lMapConcProds.get( p.Produto_Concorrente__c );
    if ( lList == null )
    {
      lList = new List< Produto_Concorr_ncia__c >();
      lMapConcProds.put( p.Produto_Concorrente__c, lList );
    }
    lList.add( p );
  }
  
  // Produtos Pernod
  for ( String lRef : lMapPernodProds.keySet() )
  {
    lList = lMapPernodProds.get( lRef );    
    integer lLen = lList.size();

    for ( Integer i=0; i<lLen; i++ )
    {
      Produto_Concorr_ncia__c lProd = lList[ i ];
      lProd.RecordTypeId = idRecTypePC;
      Decimal lPrecoGarrafa;
      Decimal lCxEstoque;
      Decimal lCxCompra;
      Decimal lPrecoDose;
      Decimal lFrente;
      Decimal lPontos;
      Boolean lConfinado = false;
      
      if ( lProd.Qtde_de_Caixas_Estoque__c > 0 ) lCxEstoque = lProd.Qtde_de_Caixas_Estoque__c;
      if ( lProd.Qtde_de_Caixas_Compra__c > 0 ) lCxCompra = lProd.Qtde_de_Caixas_Compra__c;
      if ( lProd.Pre_o_Garrafa_Pernod__c > 0 ) lPrecoGarrafa = lProd.Pre_o_Garrafa_Pernod__c;
      if ( lProd.Pre_o_Dose_Pernod__c > 0 ) lPrecoDose = lProd.Pre_o_Dose_Pernod__c;
      if ( lProd.Qtde_de_Frentes_Pernod__c > 0 ) lFrente = lProd.Qtde_de_Frentes_Pernod__c;
      if ( lProd.Qtde_de_Pontos_Pernod__c > 0 ) lPontos = lProd.Qtde_de_Pontos_Pernod__c;
      if ( lProd.Confinado_Pernod__c ) lConfinado = true;
      
      if ( lCxEstoque != null || lCxCompra != null || lPrecoGarrafa != null || lPrecoDose != null ) 
      {
        for ( Integer j=0; j<lLen; j++ )
        {
          lProd = lList[ j ];
          if ( lProd.Qtde_de_Caixas_Estoque__c == null && lCxEstoque != null ) lProd.Qtde_de_Caixas_Estoque__c = lCxEstoque;
          if ( lProd.Qtde_de_Caixas_Compra__c == null && lCxCompra != null ) lProd.Qtde_de_Caixas_Compra__c = lCxCompra;
          if ( lProd.Pre_o_Garrafa_Pernod__c == null && lPrecoGarrafa != null ) lProd.Pre_o_Garrafa_Pernod__c = lPrecoGarrafa;
          if ( lProd.Pre_o_Dose_Pernod__c == null && lPrecoDose != null ) lProd.Pre_o_Dose_Pernod__c = lPrecoDose;
          if ( lProd.Qtde_de_Frentes_Pernod__c == null && lFrente != null ) lProd.Qtde_de_Frentes_Pernod__c = lFrente;
          if ( lProd.Qtde_de_Pontos_Pernod__c == null && lPontos != null ) lProd.Qtde_de_Pontos_Pernod__c = lPontos;
          if ( !lProd.Confinado_Pernod__c && lConfinado ) lProd.Confinado_Pernod__c = lConfinado;
        }
      }
    }
  }
  
  // Produtos Concorrentes
  for ( String lRef : lMapConcProds.keySet() )
  {
    lList = lMapConcProds.get( lRef );
    integer lLen = lList.size();
    
    for ( Integer i=0; i<lLen; i++ )
    {
      Produto_Concorr_ncia__c lProd = lList[ i ];
      lProd.RecordTypeId = idRecTypePC;
      Decimal lPrecoGarrafa;
      Decimal lPrecoDose;
      Boolean lPromocao = false;
      Boolean lAtivacao = false;
      Decimal lVolume;
      Decimal lFrente;
      Decimal lPontos;
      Boolean lConfinado = false;
      
      if ( lProd.Pre_o_garrafa_Concorrente__c > 0 ) lPrecoGarrafa = lProd.Pre_o_garrafa_Concorrente__c;
      if ( lProd.Pre_o_Dose_Concorrente__c > 0 ) lPrecoDose = lProd.Pre_o_Dose_Concorrente__c;
      if ( lProd.Promo_o__c ) lPromocao = true;
      if ( lProd.Ativa_o__c ) lAtivacao = true;
      if ( lProd.Volume__c > 0 ) lVolume = lProd.Volume__c;
      if ( lProd.Qtde_de_Frentes_Concorrencia__c > 0 ) lFrente = lProd.Qtde_de_Frentes_Concorrencia__c;
      if ( lProd.Qtde_de_Pontos_Concorrencia__c > 0 ) lPontos = lProd.Qtde_de_Pontos_Concorrencia__c;
      if ( lProd.Confinado_Concorrente__c ) lConfinado = true;
      
      if ( lPrecoGarrafa != null || lPrecoDose != null ) 
        for ( Integer j=0; j<lLen; j++ )
        {
          lProd = lList[ j ];
          if ( lProd.Pre_o_garrafa_Concorrente__c == null && lPrecoGarrafa != null ) lProd.Pre_o_garrafa_Concorrente__c = lPrecoGarrafa;
          if ( lProd.Pre_o_Dose_Concorrente__c == null && lPrecoDose != null ) lProd.Pre_o_Dose_Concorrente__c = lPrecoDose;
          if ( !lProd.Promo_o__c && lPromocao ) lProd.Promo_o__c = lPromocao;
          if ( !lProd.Ativa_o__c && lAtivacao ) lProd.Ativa_o__c = lAtivacao;
          if ( lProd.Volume__c == null && lVolume != null ) lProd.Volume__c = lVolume;
          if ( lProd.Qtde_de_Frentes_Concorrencia__c == null && lFrente != null ) lProd.Qtde_de_Frentes_Concorrencia__c = lFrente;
          if ( lProd.Qtde_de_Pontos_Concorrencia__c == null && lPontos != null ) lProd.Qtde_de_Pontos_Concorrencia__c = lPontos;
          if ( !lProd.Confinado_Concorrente__c && lConfinado ) lProd.Confinado_Concorrente__c = lConfinado;
        }
    }
  }
 }
}
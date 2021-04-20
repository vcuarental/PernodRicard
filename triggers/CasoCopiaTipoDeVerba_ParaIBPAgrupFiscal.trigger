/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
********************************************************************************
*
* Trigger que copia o tipo de verba para o IBP e Agrupamento Fiscal
* NAME: CasoCopiaTipoDeVerba_ParaIBPAgrupFiscal.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 14/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE: INSERIDO MÉTODO RecordTypeForTest.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/
trigger CasoCopiaTipoDeVerba_ParaIBPAgrupFiscal on Case (before insert, before update) {
  String i = '';
/*
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

  String lRecType = RecordTypeForTest.getRecType( 'Case', 'Inserir_o_Tipo_de_Verba' );
  
  List< String > lListContratoID = new List< String >();
  List< String > lListAnoFiscal = new List< String >();
  Map< String, Case > lMapCase = new Map< String, Case >();
  List< String > listRecTypeInv = new List< String >();
  listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
  listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
  String idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
  
  for ( Case c : Trigger.new ){
    if ( c.Status == 'Aprovado' && ( Trigger.isInsert || c.status != Trigger.oldMap.get( c.id ).Status ) && c.recordTypeId == lRecType )
    {
      lListContratoID.add( c.LAT_Contract__c );
      lListAnoFiscal.add( c.Fiscal_Year_description__c );
      lMapCase.put( c.LAT_Contract__c, c );
    }
  }
  if ( lListContratoID.size() == 0 ) return;
  
  List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = [ SELECT Sistema__c, LAT_contract__c, Ano_Fiscal__c  
                     FROM Investimento_Bonificacao_e_Pagamento__c WHERE LAT_contract__c =:lListContratoID 
                     AND Ano_Fiscal__c =:lListAnoFiscal AND RecordTypeId =: listRecTypeInv];
                     
  for ( Investimento_Bonificacao_e_Pagamento__c lIBP : lListIBP )
  {
    Case c = lMapCase.get( lIBP.LAT_Contract__c );
    if ( c == null || c.Fiscal_Year_description__c != lIBP.Ano_Fiscal__c ) continue;
    lIBP.Sistema__c = c.System__c;
    lIBP.CasoEspecial__c = true;
  }
  
  List< Agrupamento_Fiscal_Year__c > lListAgrFiscal = [SELECT Sistema__c, LAT_Contract__c, Ano_Fiscal__c, Tipo_de_Verba__c
    FROM Agrupamento_Fiscal_Year__c WHERE LAT_Contract__c =:lListContratoID
    AND Ano_Fiscal__c =:lListAnoFiscal AND RecordTypeId =: idRecTypeAgr];
    
  for ( Agrupamento_Fiscal_Year__c lAFiscal : lListAgrFiscal )
  {
    Case c = lMapCase.get( lAFiscal.LAT_Contract__c );
    if ( c == null || c.Fiscal_Year_description__c != lAFiscal.Ano_Fiscal__c ) continue;
    lAFiscal.Sistema__c = c.System__c;
    lAFiscal.Tipo_de_Verba__c = c.Amount_Type__c;
    lAFiscal.CasoEspecial__c = true;
  }
  
  if ( lListIBP.size() > 0 ) update lListIBP;
  if ( lListAgrFiscal.size() > 0 ) update lListAgrFiscal;

  }
*/
}
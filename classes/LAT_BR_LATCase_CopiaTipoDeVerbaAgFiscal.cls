//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_LATCase_CopiaTipoDeVerbaAgFiscal {
	
	public static void execute(){
		
		//    Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {

		  String lRecType = RecordTypeForTest.getRecType( 'LAT_Case__c', 'Inserir_o_Tipo_de_Verba' );
		  
		  List< String > lListContratoID = new List< String >();
		  List< String > lListAnoFiscal = new List< String >();
		  Map< String, LAT_Case__c > lMapCase = new Map< String, LAT_Case__c >();
		  List< String > listRecTypeInv = new List< String >();
		  listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
		  listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
		  String idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
		  
		  for ( LAT_Case__c c : LAT_CaseTriggerHandler.triggerNew){
		    if ( c.LAT_Status__c == 'Aprovado' && ( Trigger.isInsert || c.LAT_Status__c != LAT_CaseTriggerHandler.mapOld.get( c.id ).LAT_Status__c ) && c.recordTypeId == lRecType )
		    {
		      lListContratoID.add( c.LAT_Contract__c );
		      lListAnoFiscal.add( c.LAT_FiscalYearDescription__c );
		      lMapCase.put( c.LAT_Contract__c, c );
		    }
		  }
		  if ( lListContratoID.size() == 0 ) return;
		  
		  List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = [ SELECT Sistema__c, LAT_contract__c, Ano_Fiscal__c  
		                     FROM Investimento_Bonificacao_e_Pagamento__c WHERE LAT_contract__c =:lListContratoID 
		                     AND Ano_Fiscal__c =:lListAnoFiscal AND RecordTypeId =: listRecTypeInv];
		                     
		  for ( Investimento_Bonificacao_e_Pagamento__c lIBP : lListIBP )
		  {
		    LAT_Case__c c = lMapCase.get( lIBP.LAT_Contract__c );
		    if ( c == null || c.LAT_FiscalYearDescription__c != lIBP.Ano_Fiscal__c ) continue;
		    lIBP.Sistema__c = c.LAT_System__c;
		    lIBP.CasoEspecial__c = true;
		  }
		  
		  List< Agrupamento_Fiscal_Year__c > lListAgrFiscal = [SELECT Sistema__c, LAT_Contract__c, Ano_Fiscal__c, Tipo_de_Verba__c
		    FROM Agrupamento_Fiscal_Year__c WHERE LAT_Contract__c =:lListContratoID
		    AND Ano_Fiscal__c =:lListAnoFiscal AND RecordTypeId =: idRecTypeAgr];
		    
		  for ( Agrupamento_Fiscal_Year__c lAFiscal : lListAgrFiscal )
		  {
		    LAT_Case__c c = lMapCase.get( lAFiscal.LAT_Contract__c );
		    if ( c == null || c.LAT_FiscalYearDescription__c != lAFiscal.Ano_Fiscal__c ) continue;
		    lAFiscal.Sistema__c = c.LAT_System__c;
		    lAFiscal.Tipo_de_Verba__c = c.LAT_AmountType__c;
		    lAFiscal.CasoEspecial__c = true;
		  }
		  
		  if ( lListIBP.size() > 0 ) update lListIBP;
		  if ( lListAgrFiscal.size() > 0 ) update lListAgrFiscal;

		}
	}

}
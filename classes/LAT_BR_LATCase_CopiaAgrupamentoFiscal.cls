//LAT_CASE__c TRIGGER
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_LATCase_CopiaAgrupamentoFiscal {
	
	public static void execute(){
		
		//    Check if this trigger is bypassed by SESAME (data migration Brazil)
		if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
		    
		    String lRecType = RecordTypeForTest.getRecType( 'LAT_Case__c', 'Gerar_D_A_no_sistema_ME' );
		    String rtDA = RecordTypeForTest.getRecType( 'LAT_Case__c', 'AlterarDAnoSistemaME');
		    String idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
		    List< String > listRecTypeInv = new List< String >();
		    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
		    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
		    
		    List< String > lListAgrFiscalID = new List< String >();
		    List< String > lListAnoFiscal = new List< String >();
		    List< String > lListIdsContrato = new List< String >();
		    Map< String, LAT_Case__c > lMapCase = new Map< String, LAT_Case__c >();
		    List< Investimento_Bonificacao_e_Pagamento__c > lListInvest;
		    List< Investimento_Bonificacao_e_Pagamento__c > lListIBPUpdate = new List< Investimento_Bonificacao_e_Pagamento__c >();
		    Map< String, List<Investimento_Bonificacao_e_Pagamento__c> > lMapListIBP = new Map< String, List< Investimento_Bonificacao_e_Pagamento__c >>();
		    
		    for ( LAT_Case__c c : LAT_CaseTriggerHandler.triggerNew )
		      if ( c.LAT_GroupingFiscalYear__c != null && (c.recordTypeId == lRecType || c.recordTypeId == rtDA)
		      && c.LAT_status__c == 'Fechado e Resolvido' && ( Trigger.isInsert || c.LAT_status__c != LAT_CaseTriggerHandler.mapOld.get( c.id ).LAT_status__c ) )
		      {
		        lListAgrFiscalID.add( c.LAT_GroupingFiscalYear__c );
		        lListIdsContrato.add( c.LAT_Contract__c );
		        lMapCase.put( c.LAT_GroupingFiscalYear__c, c );
		    }
		    
		    if ( lListAgrFiscalID.size() == 0 ) return;
		    
		    List< Agrupamento_Fiscal_Year__c > lListAgrFiscal = [ SELECT Id, Ano_Fiscal__c, Numero_da_D_A__c, 
		           Tipo_de_Workflow__c, LAT_Contract__c  
		           FROM Agrupamento_Fiscal_Year__c WHERE id=:lListAgrFiscalID AND RecordTypeId =: idRecTypeAgr];
		           
		    for(Agrupamento_Fiscal_Year__c a : lListAgrFiscal ){
		        lListAnoFiscal.add( a.Ano_Fiscal__c );
		    }
		    
		    List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = [ SELECT Id, Ano_Fiscal__c, 
		        Numero_da_DA__c, LAT_contract__c 
		        FROM Investimento_Bonificacao_e_Pagamento__c WHERE LAT_contract__c =: lListIdsContrato
		        AND Ano_Fiscal__c =:lListAnoFiscal AND RecordTypeId =: listRecTypeInv];
		    
		    for( Investimento_Bonificacao_e_Pagamento__c inv : lListIBP ){
		        List< Investimento_Bonificacao_e_Pagamento__c > lList = lMapListIBP.get( inv.Ano_Fiscal__c+inv.LAT_contract__c );
		        if( lList == null ){
		            lList = new List< Investimento_Bonificacao_e_Pagamento__c >();
		            lMapListIBP.put( inv.Ano_Fiscal__c+inv.LAT_contract__c, lList );
		        }
		        lList.add( inv );
		    }
		    
		    for ( Agrupamento_Fiscal_Year__c lAFY : lListAgrFiscal )
		    {
		        LAT_Case__c c = lMapCase.get( lAFY.id );
		        if ( c == null ) continue;
		        lAFY.Numero_da_D_A__c = c.LAT_DANumber__c;
		        lAFY.Tipo_de_Workflow__c = c.LAT_WFType__c;
		        lAFY.CasoEspecial__c = true;
		        List< Investimento_Bonificacao_e_Pagamento__c > lList = lMapListIBP.get( lAFY.Ano_Fiscal__c+lAFY.LAT_Contract__c );

		        if( lList != null && lList.size() > 0 ){
		            for( Investimento_Bonificacao_e_Pagamento__c inv : lList ){
		                inv.Numero_da_DA__c = String.valueOf( c.LAT_DANumber__c );
		                inv.CasoEspecial__c = true;
		                lListIBPUpdate.add( inv );
		            }
		        }
		    }
		    
		    if ( lListAgrFiscal.size() > 0 ) update lListAgrFiscal;
		    if( lListIBPUpdate.size() > 0 ) update lListIBPUpdate;

		}

	}

}
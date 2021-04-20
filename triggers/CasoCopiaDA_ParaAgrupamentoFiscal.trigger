/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Copia informações do caso (DA e Tipo de WF) para o Agrupamento Fiscal
* NAME: CasoCopiaDA_ParaAgrupamentoFiscal.trigger
* AUTHOR: ROGERIO ALVARENGA                         DATE: 14/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE: Inserido método da classe RecordTypeForTest e nos selects a clasula 
* que referencia tipo de registro.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
*******************************************************************************/

trigger CasoCopiaDA_ParaAgrupamentoFiscal on Case (before insert, before update) {
    String i = '';
/*
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    String lRecType = RecordTypeForTest.getRecType( 'Case', 'Gerar_D_A_no_sistema_ME' );
    String rtDA = RecordTypeForTest.getRecType( 'Case', 'AlterarDAnoSistemaME');
    String idRecTypeAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
    List< String > listRecTypeInv = new List< String >();
    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
    List< String > lListAgrFiscalID = new List< String >();
    List< String > lListAnoFiscal = new List< String >();
    List< String > lListIdsContrato = new List< String >();
    Map< String, Case > lMapCase = new Map< String, Case >();
    List< Investimento_Bonificacao_e_Pagamento__c > lListInvest;
    List< Investimento_Bonificacao_e_Pagamento__c > lListIBPUpdate = new List< Investimento_Bonificacao_e_Pagamento__c >();
    Map< String, List<Investimento_Bonificacao_e_Pagamento__c> > lMapListIBP = new Map< String, List< Investimento_Bonificacao_e_Pagamento__c >>();
    
    for ( Case c : Trigger.new )
      if ( c.Grouping_Fiscal_Year__c != null && (c.recordTypeId == lRecType || c.recordTypeId == rtDA)
      && c.Status == 'Fechado e Resolvido' && ( Trigger.isInsert || c.status != Trigger.oldMap.get( c.id ).Status ) )
      {
        lListAgrFiscalID.add( c.Grouping_Fiscal_Year__c );
        lListIdsContrato.add( c.LAT_Contract__c );
        lMapCase.put( c.Grouping_Fiscal_Year__c, c );
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
        Case c = lMapCase.get( lAFY.id );
        if ( c == null ) continue;
        lAFY.Numero_da_D_A__c = c.DA_Number__c;
        lAFY.Tipo_de_Workflow__c = c.WF_Type__c;
        lAFY.CasoEspecial__c = true;
        List< Investimento_Bonificacao_e_Pagamento__c > lList = lMapListIBP.get( lAFY.Ano_Fiscal__c+lAFY.LAT_Contract__c );

        if( lList != null && lList.size() > 0 ){
            for( Investimento_Bonificacao_e_Pagamento__c inv : lList ){
                inv.Numero_da_DA__c = String.valueOf( c.DA_Number__c );
                inv.CasoEspecial__c = true;
                lListIBPUpdate.add( inv );
            }
        }
    }
    
    if ( lListAgrFiscal.size() > 0 ) update lListAgrFiscal;
    if( lListIBPUpdate.size() > 0 ) update lListIBPUpdate;

    }
*/
    
}
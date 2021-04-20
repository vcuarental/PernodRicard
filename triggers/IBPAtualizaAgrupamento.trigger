/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Quando o contrato passar para 'Ativo' dispara a integração de contrato com o SCV
* NAME: IBPAtualizaAgrupamento.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                          DATE: 08/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
trigger IBPAtualizaAgrupamento on Investimento_Bonificacao_e_Pagamento__c (after insert, after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    List< String > lListIdIBP = new List< String >();
    List< String > lListIdContrato = new List< String >();
    List< Id > lListIdsRecType = new List< Id >();
    List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = new List< Investimento_Bonificacao_e_Pagamento__c >();
    Set< Id > setRecTypeInv = new Set< Id >();
    Id idRecTypeAgr = RecordTypeForTest.getRecType( 'Agrupamento_Fiscal_Year__c', 'BRA_Standard' );
    
    //RecordType de Caso - Inserir tipo de verba e Gerar DA
    lListIdsRecType.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF' ) );
    lListIdsRecType.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on' ) );
    lListIdsRecType.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on' ) );
    lListIdsRecType.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on' ) );
    
    //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
    if( Trigger.isInsert ){
        for( Investimento_Bonificacao_e_Pagamento__c i: trigger.new ){
            if( setRecTypeInv.contains( i.RecordTypeId ) ){
                lListIdContrato.add( i.LAT_contract__c );
                lListIBP.add( i );
            }
        }
    }else if( Trigger.isUpdate ){
        for( Investimento_Bonificacao_e_Pagamento__c i : trigger.new ){
            if( setRecTypeInv.contains( i.RecordTypeId ) ) continue;
            if( Trigger.oldMap.get( i.Id ).Custo_Bonificado__c != i.Custo_Bonificado__c ||
                Trigger.oldMap.get( i.Id ).Valor_R__c != i.Valor_R__c ||
                Trigger.oldMap.get( i.Id ).Volume_Cx__c != i.Volume_Cx__c ){
                lListIdContrato.add( i.LAT_contract__c );
                lListIBP.add( i );
            }
        }
    }
    
    List< LAT_Contract__c > lListContract = 
        [ SELECT Id, Status__c FROM LAT_Contract__c WHERE RecordTypeId =: lListIdsRecType
            AND ID =: lListIdContrato ];
            
    if( lListContract.size() == 0 ) return;
    
    List< Agrupamento_Fiscal_Year__c > lListAgr = [SELECT Id, LAT_Contract__c, Ano_Fiscal__c, 
        Ano_fiscal_calculadoag__c, valor_total__c, Volume_Total__c FROM Agrupamento_Fiscal_Year__c 
        WHERE LAT_Contract__c =: lListIdContrato AND RecordTypeId =: idRecTypeAgr];
      
    Map< String, Agrupamento_Fiscal_Year__c > lMapAgrFiscal = new Map< String, Agrupamento_Fiscal_Year__c >();
    if( lListAgr.size() > 0 ){
        for( Agrupamento_Fiscal_Year__c ag : lListAgr ){
            String lKey = ag.LAT_Contract__c + '|' + ag.Ano_Fiscal__c;
            lMapAgrFiscal.put( lKey, ag );
        }
    }
      
    for ( Investimento_Bonificacao_e_Pagamento__c lIBP : lListIBP )
    {
        String lKey = lIBP.LAT_Contract__c + '|' + lIBP.Ano_Fiscal__c;
        Agrupamento_Fiscal_Year__c lAgrFiscal = lMapAgrFiscal.get( lKey );
        if ( lAgrFiscal == null )
        {
            lAgrFiscal = new Agrupamento_Fiscal_Year__c();
            lAgrFiscal.LAT_Contract__c = lIBP.LAT_contract__c;
            lAgrFiscal.Ano_Fiscal__c = lIBP.Ano_Fiscal__c;
            lAgrFiscal.Ano_fiscal_calculadoag__c = String.valueOf( lIBP.Ano_fiscal_calculado__c );
            lAgrFiscal.valor_total__c = 0;
            lAgrFiscal.Volume_Total__c = 0;
            lAgrFiscal.RecordTypeId = idRecTypeAgr;
            lMapAgrFiscal.put( lKey, lAgrFiscal );
        }
        lAgrFiscal.CasoEspecial__c = true;
        
        if( Trigger.isUpdate ){
    
          if( Trigger.oldMap.get( lIBP.Id ).Custo_Bonificado__c != null && Trigger.oldMap.get( lIBP.Id ).Custo_Bonificado__c > 0 )
              lAgrFiscal.valor_total__c -= Trigger.oldMap.get( lIBP.Id ).Custo_Bonificado__c; 
          
          if( Trigger.oldMap.get( lIBP.Id ).Valor_R__c != null && Trigger.oldMap.get( lIBP.Id ).Valor_R__c > 0 )
              lAgrFiscal.valor_total__c -= Trigger.oldMap.get( lIBP.Id ).Valor_R__c; 
          
          if( Trigger.oldMap.get( lIBP.Id ).Volume_Cx__c != null && Trigger.oldMap.get( lIBP.Id ).Volume_Cx__c > 0 )
              lAgrFiscal.valor_total__c -= Trigger.oldMap.get( lIBP.Id ).Volume_Cx__c; 
        }
        
        if ( lIBP.Custo_Bonificado__c > 0 ) lAgrFiscal.valor_total__c += lIBP.Custo_Bonificado__c;
        if ( lIBP.Valor_R__c > 0 ) lAgrFiscal.valor_total__c += lIBP.Valor_R__c;
        if ( lIBP.Volume_Cx__c > 0 ) lAgrFiscal.Volume_Total__c += lIBP.Volume_Cx__c;        
    }
    List< Agrupamento_Fiscal_Year__c > lList = lMapAgrFiscal.values();
    if( lList != null && lList.size() > 0 ) upsert lList;
 }
}
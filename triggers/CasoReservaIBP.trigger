/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Reserva as IBPs do ano fiscal atual após o status do contrato igual à ATIVO e a
* Demanda fechada.
*
* NAME: CasoReservaIBP.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 22/10/2012
*
* MAINTENANCE: INSERIDO MÉTODO RecordTypeForTest E CLAUSULA WHERE DO SELECT OM RECORDTYPEID.
* AUTHOR: CARLOS CARVALHO                           DATE: 08/01/2013 
********************************************************************************/
trigger CasoReservaIBP on Case (after update) {
    String i = '';
/*
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    List< String > listIdContrato = new List< String >();
    List< Investimento_Bonificacao_e_Pagamento__c > listIBP;
    List< Investimento_Bonificacao_e_Pagamento__c > listIBPUpdate;
    List< LAT_Contract__c > listContrato = new List< LAT_Contract__c >();
    Decimal anoFiscalAtual;
    Map< String, LAT_Contract__c > mapContrato = new Map< String, LAT_Contract__c >();
    List< String > listRecTypeInv = new List< String >();
    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    listRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
  
    //RecordType de Caso - Gerar DA
    Id idRecTypeGDA = RecordTypeForTest.getRecType( 'Case', 'Gerar_D_A_no_sistema_ME' );
  
    for( Case c : trigger.new ){
        if( c.RecordTypeId == idRecTypeGDA && c.Status == 'Fechado e resolvido' )
            listIdContrato.add( c.LAT_Contract__c );
    }
    
    if( System.today().month() >= 7 )
        anoFiscalAtual = Decimal.valueOf( System.today().year()+1);
    else
        anoFiscalAtual = Decimal.valueOf( System.today().year() );
    
    listIBP = [Select Id, Status_da_verba__c, Ano_fiscal__c, LAT_contract__c, CasoEspecial__c
        From Investimento_Bonificacao_e_Pagamento__c Where LAT_contract__c =: listIdContrato
        AND Ano_fiscal_calculado__c =: anoFiscalAtual AND LAT_contract__r.Status__c = 'Ativo'
        AND RecordTypeId =: listRecTypeInv];
    
    if( listIBP != null && listIBP.size() > 0 ){
        for( Investimento_Bonificacao_e_Pagamento__c i : listIBP ){
            i.Status_da_Verba__c = 'Reservado';
            i.CasoEspecial__c = true;
            listIBPUpdate.add( i );
        }
        update listIBPUpdate;       
    }
    }
*/
}
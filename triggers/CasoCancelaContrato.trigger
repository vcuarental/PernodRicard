/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Cancela contrato se demanda for reprovada.
*
* NAME: CasoCancelaContrato.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 18/10/2012
*
* MAINTENANCE: 
* AUTHOR: CARLOS CARVALHO                           DATE: 07/10/2013 
* DESC: Inserido validação de tipos de regsitro.
*
* AUTHOR: CARLOS CARVALHO                           DATE: 15/01/2013
* DESC: INSERIDO VERIFICAÇÃO NO IF: lListIdsContrato.size() > 0 
********************************************************************************/
trigger CasoCancelaContrato on Case (after insert, after update) {
    String i = '';
/*
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis
    List< String > lListIdsContrato = new List< String >();
    List< LAT_Contract__c > lListContract = new List< LAT_Contract__c >();
    List< LAT_Contract__c > lListContractUpdate = new List< LAT_Contract__c >();
    
    //RecordType de Caso - Inserir tipo de verba e Gerar DA
    Id idRecTypeITV = RecordTypeForTest.getRecType( 'Case', 'Inserir_o_Tipo_de_Verba' );
    Id idRecTypeGDA = RecordTypeForTest.getRecType( 'Case', 'Gerar_D_A_no_sistema_ME' );
    Id idRecTypeOnContNaoAprovado = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'OnTradeContratoNaoAprovado' );
  
    for( Case caso:trigger.new ){
        if( ( caso.Status == 'Não aprovado' || caso.Status == 'Fechado e cancelado') && 
            (caso.RecordTypeId == idRecTypeGDA || caso.RecordTypeId == idRecTypeITV) ){
            
            lListIdsContrato.add( caso.LAT_Contract__c );
        }
    }
    
    if( lListIdsContrato != null && lListIdsContrato.size() > 0 ){
        lListContract = ContractDAO.getInstance().getListContractByIds( lListIdsContrato );
        
        if( lListContract.size() == 0 ) return;
        
        for( LAT_Contract__c c : lListContract ){
            //if ( ContratoSemaphoro.hasExec( c.id ) ) continue;
            if( ContratoSemaphoro.setNewCode( c.Id, 'CasoCancelaContrato' ) ) continue;
            c.Status__c = 'Não aprovado';
            c.RecordTypeId = idRecTypeOnContNaoAprovado;
            lListContractUpdate.add( c );
        }
        
        if( lListContractUpdate != null ){
            update lListContractUpdate;
        }
    }

    }
*/
}
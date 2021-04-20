/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Quando um Agrupamento é atualizado ou inserido o contrato não pode estar 
* em aprovação ou ativo.
*
* NAME: AgrupamentoValidaContratoAtivo.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 24/10/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
trigger AgrupamentoValidaContratoAtivo on Agrupamento_Fiscal_Year__c (before insert, before update) {

//String triggerName = 'AgrupamentoValidaContratoAtivo';  

/* Get context User */
//    User thisUser = [ SELECT Id,BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId() ];
//    String bypass = ''+thisUser.BypassTriggers__c;
    
//    /* Check if this trigger is bypassed or not */
//    if(!bypass.contains(triggerName)){  

//     Check if this trigger is bypassed by SESAME (data migration Brazil)
 if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
     
    List< String > listIdContrato = new List< String >();
    List< Agrupamento_Fiscal_Year__c > listAgrup = new List< Agrupamento_Fiscal_Year__c >();
    List< LAT_Contract__c > listContrato = new List< LAT_Contract__c >();
    Map< String, LAT_Contract__c > mapContrato;
    Id idAgr = RecordTypeForTest.getRecType('Agrupamento_Fiscal_Year__c', 'BRA_Standard');
    
    for(Agrupamento_Fiscal_Year__c a: trigger.new ){
        if( a.RecordTypeId == idAgr ){
            listIdContrato.add( a.LAT_Contract__c );
            listAgrup.add( a );
        }
    }
    
    if( listIdContrato.size() > 0 ) return;
    
    listContrato = [Select Id, Status__c From LAT_Contract__c Where Id =: listIdContrato AND (Status__c = 'Ativo' OR Status__c = 'Em aprovação')];
    
    if( listContrato != null && listContrato.size() > 0 ){
        mapContrato = new Map< String, LAT_Contract__c >();
        for( LAT_Contract__c c : listContrato ){
            mapContrato.put( c.Id , c );
        }
        for( Agrupamento_Fiscal_Year__c a : listAgrup ){
            LAT_Contract__c lCon = mapContrato.get( a.LAT_Contract__c );
            if( lCon == null ) continue;
            
            if( !a.CasoEspecial__c ){
                a.addError('Não é possível Inserir/editar registros com o status do contrato = Ativo ou Em Aprovação');
            }
            else{
                a.CasoEspecial__c = false;
            }
        }
    }
 }

    
}
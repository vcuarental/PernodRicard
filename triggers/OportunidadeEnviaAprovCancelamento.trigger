/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* NAME: OportunidadeEnviaAprovCancelamento.trigger
* AUTHOR:                                               DATE: 
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
*******************************************************************************/
trigger OportunidadeEnviaAprovCancelamento on Opportunity (after update) {

/*
//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
    //Declaração de variáveis   
    Set< Id > setRecTypeOpp = new Set< Id >();
    
    //Recupera os ids de tipo de registro de ooportunidade
    setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao'));
    setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao_do_cabecalho'));
    setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Nova_oportunidade'));
    
    for ( Opportunity opp : trigger.new ) {
		//if ( setRecTypeOpp.contains( opp.RecordTypeId ) && opp.Tem_Item_cancelado__c > Trigger.oldMap.get(opp.id).Tem_Item_cancelado__c  && (trigger.new[i].CD_Action__c <> 'C')) {
        if ( setRecTypeOpp.contains( opp.RecordTypeId ) && opp.Tem_Item_cancelado__c > Trigger.oldMap.get(opp.id).Tem_Item_cancelado__c) {
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Pedido ou itens cancelados enviados para aprovação');
                req.setNextApproverIds(new List<Id>{opp.ownerId});
                req.setObjectId(opp.Id);
                
                // submit the approval request for processing
                Approval.ProcessResult result = Approval.process(req);
                
                // display if the request was successful
                System.debug('Pedido ou itens cancelados enviados para aprovação: '+result.isSuccess());
        }
    }
 }
*/

}
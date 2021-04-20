/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Opportunity
*******************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016
*
********************************************************************************/

public without sharing class LAT_MX_AP02_OpportunityWOS{
       
    /*****************************************************************************************
    * Nombre del metodo: updatesAvailableCreditLimit
    * Descripcion: Metodo que carga en un set los Ids de los Accounts de los cuales se debe 
                   recalcular el Available Credit Limit y llama a la clase que realiza el calculo
    * Desarrollador: Elena J. Schwarzböck 
    * Fecha: 12/12/2013
    * Modo: after delete
    *****************************************************************************************/

    public static boolean isProcessing;
    public static void updatesAvailableCreditLimit(Map<Id,Opportunity> oldMap){
        
        Set<String> setAccountsToUpdate = new Set<String>();       

        for(Opportunity opp: oldMap.values()){
            setAccountsToUpdate.add(opp.AccountId);
            Id oId = opp.Id;
            String name = opp.Name;
            System.debug('&&&&&&&&' + oId + ' '+name);

        }       
        String returnMessage;
        if(!setAccountsToUpdate.isEmpty()){
            returnMessage = LAT_MX_AvailableCreditLimit.CalculatesAvailableCreditLimit(setAccountsToUpdate);
            if(returnMessage != 'OK'){
            System.debug('&&&&&&&& returnMessage' + returnMessage);                
                for(Opportunity opp: oldMap.values()){
                    if(setAccountsToUpdate.contains(opp.AccountId)){
                        opp.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                        //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                    }
                }
            }
        }
    }
    
    //MIGRATED 04/11/2016 
    public static void updatesAvailableCreditLimit(Map<Id,LAT_Opportunity__c> oldMap){
        
        Set<String> setAccountsToUpdate = new Set<String>();       

        for(LAT_Opportunity__c opp: oldMap.values()){
            setAccountsToUpdate.add(opp.LAT_Account__c);
            Id oId = opp.Id;
            String name = opp.Name;
            System.debug('&&&&&&&&' + oId + ' '+name);
            
        }       
        String returnMessage;
        if(!setAccountsToUpdate.isEmpty()){
            returnMessage = LAT_MX_AvailableCreditLimit.CalculatesAvailableCreditLimit(setAccountsToUpdate);
            System.debug('&&&&&&&& returnMessage' + returnMessage);
            if(returnMessage != 'OK'){
                for(LAT_Opportunity__c opp: oldMap.values()){
                    if(setAccountsToUpdate.contains(opp.LAT_Account__c)){
                        opp.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                        //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                    }
                }
            }
        }
    }

    public static void postToChatter(List<LAT_Opportunity__c> triggerNew, Map<Id,LAT_Opportunity__c> oldMap) {
        if (isProcessing != null || isProcessing == true) {
            return;
        }
        isProcessing = true;
        Map<Id,LAT_Opportunity__c> oppExtraData = new Map<Id,LAT_Opportunity__c>( [SELECT Id, OwnerId, Owner.Name, LAT_Account__r.Name, LAT_Account__r.CLient_code_AN8__c FROM LAT_Opportunity__c WHERE Id IN: oldMap.values()]);

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        LAT_CHATTER_POST_BODY__c cs = [SELECT Body__c FROM LAT_CHATTER_POST_BODY__c WHERE Name = 'LAT_MX_OPP_Integrada_JDE'];
        String body = cs.Body__c;
        SObject chatterGroup;
        if (!Test.isRunningTest()) {
            chatterGroup = [select Id, Name from CollaborationGroup where Name = 'PR Mexico – Administración Comercial']; 
        } else {
            chatterGroup = triggerNew.get(0);
        }
       
                    
        for (LAT_Opportunity__c opp : triggerNew) {
            if (opp.LAT_OrderOrigin__c == 'APP' || opp.LAT_OrderOrigin__c == 'CRM') {
                if (opp.LAT_NROrderJDE__c != null) {
                    if (oldMap.get(opp.Id).LAT_NROrderJDE__c == null || oldMap.get(opp.Id).LAT_NROrderJDE__c == '') {
                        body = body.replace('xx_KAM_NAME_xx', oppExtraData.get(opp.Id).Owner.Name );
                        body = body.replace('xx_PEDIDO_LINK_xx',oldMap.get(opp.Id).Name  );
                        body = body.replace('xx_NR_JDE_xx', opp.LAT_NROrderJDE__c );
                        body = body.replace('xx_AN8_AND_CLIENT_NAME__xx', oppExtraData.get(opp.Id).LAT_Account__r.CLient_code_AN8__c +'-'+ oppExtraData.get(opp.Id).LAT_Account__r.Name);
                        if (opp.LAT_DTDelivery__c != null) {
                            body = body.replace('xx_EXPECTED_DATE__xx', String.valueOf(opp.LAT_DTDelivery__c ));
                        } else {
                            body = body.replace('xx_EXPECTED_DATE__xx', String.valueOf(opp.LAT_CloseDate__c ));
                        }
                        
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                        textSegmentInput.text = body;
                        System.debug('%%%% textSegmentInput.text : '+textSegmentInput.text);
                        messageBodyInput.messageSegments.add(textSegmentInput);
                        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                        mentionSegment.id = oppExtraData.get(opp.Id).OwnerId;
                        messageBodyInput.messageSegments.add(mentionSegment);
                        ConnectApi.MentionSegmentInput mentionSegment2 = new ConnectApi.MentionSegmentInput();
                        mentionSegment2.id = chatterGroup.Id;
                        messageBodyInput.messageSegments.add(mentionSegment2);

                        System.debug('%%%% messageBodyInput : '+messageBodyInput);
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId = opp.Id;
                      

                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                        batchInputs.add(batchInput);
                        

                    }
                }
            }
            if (batchInputs.size() > 0) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            } 
        }
    }
}


/*
xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx
*/
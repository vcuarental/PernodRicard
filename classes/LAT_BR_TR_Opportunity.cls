public with sharing class LAT_BR_TR_Opportunity {
    
    /*****************************************************************************************
    * Nombre del metodo: createFeedOnStatusUpdate
    * Descripcion: Creates a feed indicating that the status of the orther has change
    * Desarrollador: Mariano Boezio
    * Fecha: 26/03/2015
    * Modo: after update
    *****************************************************************************************/
    /********************************************************************************
    *                       
    * MIGRACION LICENCIAS 
    * AUTHOR: ZIMMIC                     DATE: 03/11/2016
    *
    ********************************************************************************/

    //MIGRATED 03/11/2016 
    public static void createFeedOnStatusUpdate(List<LAT_Opportunity__c> triggerNew, List<LAT_Opportunity__c> triggerOld){
        LAT_CS007_PushNotifications__c PushNotificationSetting = new LAT_CS007_PushNotifications__c();

        // See if the notifications are enabled
        List<LAT_CS007_PushNotifications__c> PNList = [SELECT Id, LAT_isEnabled__c FROM LAT_CS007_PushNotifications__c LIMIT 1];
        if (!PNList.isEmpty()) {
            PushNotificationSetting = PNList.get(0);
        }
        
        if (PushNotificationSetting.LAT_isEnabled__c) {
            Map<id, LAT_Opportunity__c> oldMap = new Map<id, LAT_Opportunity__c>();
            Map<id, List<LAT_OpportunityLineItem__c>> oliMap = new Map<id, List<LAT_OpportunityLineItem__c>>();
            List<ConnectApi.BatchInput> feedList = new List<ConnectApi.BatchInput>();

            // Get stages that will send notification
            Set<String> stages = new Set<String>();
            stages.addAll(LAT_GeneralConfigDao.getValueAsStringArray('OPP_STAGES_TO_PUSH',','));

            // Get stages that will to show line items in feed post
            Set<String> lineItemStages = new Set<String>();
            lineItemStages.addAll(LAT_GeneralConfigDao.getValueAsStringArray('OPP_PUSH_STAGE_TO_SHOW_ITEMS',','));
            
            // Construct Map with list of line items to be displayed if the oppty stage
            // is in the previously created set
            for (LAT_OpportunityLineItem__c oli: [SELECT LAT_Sku__c,LAT_MX_RealDeliveryDate__c, LAT_Product__r.Name, LAT_StatusDescription__c, LAT_Opportunity__c 
                                                FROM LAT_OpportunityLineItem__c 
                                                WHERE LAT_Opportunity__c IN: triggerNew]) {
                if (oliMap.get(oli.LAT_Opportunity__c) == null) {
                    oliMap.put(oli.LAT_Opportunity__c, new List<LAT_OpportunityLineItem__c>{oli});
                } else {
                    oliMap.get(oli.LAT_Opportunity__c).add(oli);
                }
            }

            // Construct map with old information of the opportunity
            for (LAT_Opportunity__c opp: triggerOld) {
                oldMap.put(opp.id, opp);
            }

            // For each of the updated opportunities, check that the stageName is changed.
            // if it is then a feed is created to this opportunity if it isn't nothing is done.
            for (LAT_Opportunity__c opp: triggerNew) {

                if (opp.LAT_StageName__c != oldMap.get(opp.id).LAT_StageName__c 
                    && opp.LAT_Integration__c && stages.contains(opp.LAT_StageName__c)) {
                    //ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;

                    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                    //input.feedElementType = ConnectApi.​FeedElement​Type.FeedItem;
                    input.subjectId = opp.id;

                    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                    // Create mention to Opportunity Owner
                    ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment.id = opp.OwnerId;
                    messageInput.messageSegments.add(mentionSegment);

                    // Create Status change text
                    ConnectApi.TextSegmentInput textSegment;
                    textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = '\n\n' + String.format(Label.LAT_OPP_PushMessage, new List<String>{opp.Name, LAT_BR_TR_Opportunity.getTranslatedStageName(oldMap.get(opp.id).LAT_StageName__c), LAT_BR_TR_Opportunity.getTranslatedStageName(opp.LAT_StageName__c)}) + '\n';
                    Integer textlength = textSegment.text.length();
                    messageInput.messageSegments.add(textSegment);

                    // Check if the the line items should be shown for this opportunity
                    if (lineItemStages.contains(opp.LAT_StageName__c) &&
                        oliMap.get(opp.id) != null) {
                        
                        ConnectApi.TextSegmentInput linetextSegment = new ConnectApi.TextSegmentInput();
                        linetextSegment.text = '';

                        // For each line item show SKU | Product Name | Status Description
                        for (LAT_OpportunityLineItem__c oli: oliMap.get(opp.id)) {
                            String lineSegment = '\n' + oli.LAT_Sku__c + ' | ' + oli.LAT_Product__r.Name + ' | ' + (oli.LAT_StatusDescription__c != null ? oli.LAT_StatusDescription__c : '') + (oli.LAT_MX_RealDeliveryDate__c != null ?  ' | ' + oli.LAT_MX_RealDeliveryDate__c.format() : '');
                            if ((linetextSegment.text.length() + textlength + lineSegment.length()) < 5000) {
                                linetextSegment.text += lineSegment;
                            } else {
                                break;
                            }
                        }
                        messageInput.messageSegments.add(linetextSegment);
                    }
                    input.body = messageInput;
                    
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                    feedList.add(batchInput);
                }
            }

            // Post FeedElement
            if (feedList != null && !feedList.isEmpty() && !Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(null, feedList); 
            }
        }
    }

    public static String getTranslatedStageName(String stageName) {
        if (stageName.contains('Totally billed')) {
            return Label.LAT_BR_TR_TotallyBilled;
        } else if (stageName.contains('Partially billed')) {
            return Label.LAT_BR_TR_PartiallyBilled;
        } else if (stageName.contains('Partially Delivered')) {
            return Label.LAT_BR_TR_PartiallyDelivered;
        } else if (stageName.contains('Totally Delivered')) {
            return Label.LAT_BR_TR_TotallyDelivered;
        } else {
            return stageName;
        }
    }

    //MIGRATED 03/11/2016 
    public static void validateAndIntegrate(List<LAT_Opportunity__c> triggerNew){
        List<LAT_Opportunity__c> oppToUpdate = new List<LAT_Opportunity__c>();
        for (LAT_Opportunity__c opp: triggerNew) {
            if (opp.LAT_StageName__c == 'Mobile Order' && opp.LAT_OrderOrigin__c != 'EDI') {
                if(LAT_Cota.processingIds == null){
                    LAT_Cota.processingIds = new Set<Id>();
                }
                if  (!LAT_Cota.processingIds.contains(opp.Id)) { 
                    LAT_Cota.validateCotaAndIntegrateFuture(opp.id);
                    LAT_Cota.processingIds.add(opp.Id);
                }
            }
        }
    }

    //MIGRATED 03/11/2016 
    public static void cancelOpportunity(List<LAT_Opportunity__c> triggerNew, Map<id, LAT_Opportunity__c> mapOld) {
        List<LAT_Opportunity__c> toCancel = new List<LAT_Opportunity__c>();
        System.debug('cancelOpportunity[triggerNew : ' + triggerNew + ' - mapOld : ' + mapOld + '] ->');
 
        for (LAT_Opportunity__c opp: triggerNew) {
            System.debug('cancelOpportunity[opp.LAT_CDAction__c : ' + opp.LAT_CDAction__c + ' - mapOld.get(opp.id).LAT_CDAction__c : ' + mapOld.get(opp.id).LAT_CDAction__c + ']');
            if (opp.LAT_CDAction__c == 'C' && mapOld.get(opp.id).LAT_CDAction__c != 'C') {
                System.debug('cancelOpportunity[opp to cancel : ' + opp.Id + ']');
                toCancel.add(opp);
            }
        }
 
        System.debug('cancelOpportunity[toCancel : ' + toCancel + ']');
        if (!toCancel.isEmpty()) {
            List<LAT_OpportunityLineItem__c> oportunidadeLista = [ SELECT id, LAT_CDAction__c, LAT_Remover__c 
                                                                    FROM LAT_OpportunityLineItem__c 
                                                                    WHERE LAT_Opportunity__c IN: toCancel];
       
            for(LAT_OpportunityLineItem__c item : oportunidadeLista) {
                item.LAT_CDAction__c = 'C';
                item.LAT_Remover__c = true;
            }
            System.debug('cancelOpportunity[oportunidadeLista : ' + oportunidadeLista + ']');
                    
            update oportunidadeLista;

            String oppId = toCancel.get(0).id;
            System.debug('cancelOpportunity[oppId : ' + oppId + ']');
            SalesOrderHandlerInterface.LAT_SalesOrderInterfaceFuture(oppId);
        }
    }

    public static void validateFlexApprovalRejected(List<LAT_Opportunity__c> triggerNew, Map<id, LAT_Opportunity__c> mapOld) {
        for(LAT_Opportunity__c opp : triggerNew){
            if(opp.LAT_StageName__c == 'Pedido Reprovado' && (mapOld.get(opp.Id).LAT_StageName__c == 'Pedido Flex em Aprovação' || mapOld.get(opp.Id).LAT_StageName__c == 'EDI Em Aprovação' )){
                //TODO Hacer Rollback de todos los IMM POSTS
                LAT_Rest_PriceFlex_SyncParams.processRejectedFlexOpportunity(opp.Id);
            }
        }
    }

    public static void checkIsEDIReteined(List<LAT_Opportunity__c> triggerNew, Map<id, LAT_Opportunity__c> mapOld){
        Set<Id> oppToSend = new Set<Id>();
        System.debug('%%%% en checkIsEDIReteined');
        for (LAT_Opportunity__c opp: triggerNew) {
            System.debug('%%%% en checkIsEDIReteined, opp.LAT_OrderOrigin__c:'+opp.LAT_OrderOrigin__c);
            System.debug('%%%% en checkIsEDIReteined, opp.LAT_IsOnHoldEDI__c:'+opp.LAT_IsOnHoldEDI__c);
            if(opp.LAT_OrderOrigin__c == 'EDI' && opp.LAT_IsOnHoldEDI__c){
                if(mapOld == null){
                    oppToSend.add(opp.Id);
                } else {
                    if(mapOld.get(opp.Id) != null){
                        if(mapOld.get(opp.Id).LAT_IsOnHoldEDI__c != opp.LAT_IsOnHoldEDI__c){
                            oppToSend.add(opp.Id);
                        }
                    } else {
                        oppToSend.add(opp.Id);
                    }
                }
                
            }
        }
        if(oppToSend.size() > 0){
            sendEdiReteinedOpps(oppToSend);
        }
    }
    
    @future
    public static void sendEdiReteinedOpps(Set<Id> oppIds){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<LAT_Opportunity__c> opps = [SELECT Id, Owner.Email, LAT_Account__r.Owner.Manager.Email, LAT_Account__r.Name, LAT_Account__r.Client_code_An8__c, LAT_TotalValue__c,                                        LAT_NROrderJDE__c FROM LAT_Opportunity__c WHERE Id IN :oppIds];
        
        for(LAT_Opportunity__c opp : opps){
            List<String> toAddress = new List<String>{opp.Owner.Email, opp.LAT_Account__r.Owner.Manager.Email};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    mail.setToAddresses(toAddress);
		    mail.setSubject('Revisar Pedido EDI de número '+opp.LAT_NROrderJDE__c+' - ' +opp.LAT_Account__r.Name+ ' ('+opp.LAT_Account__r.Client_code_An8__c+') – R$ '+opp.LAT_TotalValue__c.setScale(2));
            String message = '<html><body>Favor revisar e liberar o Pedido EDI de número '+opp.LAT_NROrderJDE__c+' para o cliente ' +opp.LAT_Account__r.Name+ ' ('+opp.LAT_Account__r.Client_code_An8__c+') e valor R$ '+opp.LAT_TotalValue__c.setScale(2)+'.<br><br>Obrigado,<br><br>Adm. Vendas</body></html>';
		    mail.setHtmlBody(message);
            emails.add(mail);
        }
            
        if(emails.size() > 0 && !Test.isRunningTest())
		    Messaging.sendEmail(emails);
    }

    public static void validateEDIApprovalApproved(List<LAT_Opportunity__c> triggerNew, Map<id, LAT_Opportunity__c> mapOld) {
        Set<String> setAllowedOlStates = null;

        System.debug('validateEDIApprovalApproved [] ->');
        setAllowedOlStates = allowedOldStates();

        for(LAT_Opportunity__c opp : triggerNew){
            if(opp.LAT_OrderOrigin__c == 'EDI' && setAllowedOlStates.contains(mapOld.get(opp.Id).LAT_StageName__c)  && opp.LAT_FlexApproved__c && !mapOld.get(opp.Id).LAT_FlexApproved__c) {
                System.debug('validateEDIApprovalApproved [Sending EDI order to JDE... ' + opp.Id + ']');

                LAT_BridgeGS1_Order.integrateEdiOrder(opp.Id);
            }
        }

        System.debug('validateEDIApprovalApproved [] <-');
    }

    private static Set<String> allowedOldStates() {
        Set<String> setAllowedOlStates = null;
        System.debug('allowedOldStates [] ->');

        setAllowedOlStates = new Set<String>();
        setAllowedOlStates.add('EDI Em Aprovação');
        setAllowedOlStates.add('Pedido processado no JDE');

        System.debug('allowedOldStates ['  + setAllowedOlStates + '] <-');
        return setAllowedOlStates;
    }
    /* DEPRECATED ZONE */
    public static void validateAndIntegrate(List<Opportunity> triggerNew){    
    }
    
    public static void createFeedOnStatusUpdate(List<Opportunity> triggerNew, List<Opportunity> triggerOld){
    }

    public static void cancelOpportunity(List<Opportunity> triggerNew, Map<id, Opportunity> mapOld) {        
    }
}
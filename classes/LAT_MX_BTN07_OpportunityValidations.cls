/**********************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                                        *
*   Date:27/11/2013     Descripcion:  Validates the Opportunity before sending to JDE                                             *  
***********************************************************************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016
*
********************************************************************************/
global without sharing class LAT_MX_BTN07_OpportunityValidations{
   
    webService static String PaymentPeridoValidation(String IdPedido){
        if(!Utils.wasMigrationDone('12')) {        
            Opportunity opp = [SELECT Id, LAT_MX_ClientPaymentPeriod__c, LAT_MX_OrderPaymentPeriod__c, RecordTypeId, StageName, AccountId, LAT_MX_LastTotalAmountSentToJDE__c, LAT_MX_AmountWithTaxes__c FROM Opportunity WHERE Id =: IdPedido];
            Profile profile = [select Name from profile where id = : userinfo.getProfileId() limit 1][0];
            User currentUser = [Select id,LAT_MX_KAM__c, Profile.Name from User where id =: userinfo.getUserId()][0];
            String lat_Kam = currentUser.LAT_MX_KAM__c;
            String perfil = currentUser.Profile.Name;
            List<OpportunityLineItem> listOli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: opp.Id LIMIT 1];
            
            if(listOli.isEmpty()){
                return ('Error: ' + label.LAT_MX_BTN07_00002);
                //LAT_MX_BTN07_00002: No es posible enviar a JDE porque no hay productos seleccionados.
            }
            
            String[] profileNames = LAT_GeneralConfigDao.getValueAsStringArray('LAT_MX_OpportunityValidations_Profiles', ' , ');
            Boolean containsProfileName = false;
            for(String pn : profileNames) containsProfileName = pn == currentUser.Profile.Name ? true : false;
            
            system.debug('containsProfileName #### Mauri' + containsProfileName);
            if(containsProfileName && currentUser.LAT_MX_KAM__c != null){
                opp.ownerId = currentUser.LAT_MX_KAM__c;
                try{
                    update opp;
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                }
            }
            
            if(opp.LAT_MX_ClientPaymentPeriod__c != opp.LAT_MX_OrderPaymentPeriod__c && opp.LAT_MX_LastTotalAmountSentToJDE__c != opp.LAT_MX_AmountWithTaxes__c){
                
                Account acc = [SELECT Id, LAT_MX_CreditAndCollectionsExecutive__c FROM Account WHERE Id =: opp.AccountId];
                
                if(acc.LAT_MX_CreditAndCollectionsExecutive__c != null){
                    User us = [SELECT Id, ManagerId FROM User WHERE id =: acc.LAT_MX_CreditAndCollectionsExecutive__c];
                    if(us.ManagerId != null){
                        opp.LAT_MX_CredAndCollExecutiveManager__c = us.ManagerId;
                    }
                }
                opp.StageName = 'Payment period approval';
                opp.Integracao__c = true;
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_OrderBlocked');
                
                try{
                    update opp;
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                }           
                
                Approval.ProcessSubmitRequest ap = new Approval.ProcessSubmitRequest();
                ap.setObjectId(opp.Id);
                Approval.ProcessResult result = Approval.process(ap);

                return label.LAT_MX_BTN07_00001;
                //LAT_MX_BTN07_00001: Enviado a aprobación
            }else{
                return 'ok';
            }
        }
        //MIGRATED 04/11/2016
        else {
            LAT_Opportunity__c opp = [SELECT Id, LAT_MX_ClientPaymentPeriod__c, LAT_MX_OrderPaymentPeriod__c, RecordTypeId, LAT_StageName__c, LAT_Account__c, LAT_MX_LastTotalAmountSentToJDE__c, LAT_MX_AmountWithTaxes__c FROM LAT_Opportunity__c WHERE Id =: IdPedido];
            Profile profile = [select Name from profile where id = : userinfo.getProfileId() limit 1][0];
            User currentUser = [Select id,LAT_MX_KAM__c, Profile.Name from User where id =: userinfo.getUserId()][0];
            String lat_Kam = currentUser.LAT_MX_KAM__c;
            String perfil = currentUser.Profile.Name;
            List<LAT_OpportunityLineItem__c> listOli = [SELECT Id,  LAT_Product__r.Name, LAT_Product__r.LAT_RestrictionEnd__c, LAT_Product__r.LAT_RestrictionInit__c, LAT_Product__r.LAT_RestrictionDescription__c 
                                                        FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: opp.Id];
            
            if(listOli.isEmpty()){
                return ('Error: ' + label.LAT_MX_BTN07_00002);
                //LAT_MX_BTN07_00002: No es posible enviar a JDE porque no hay productos seleccionados.
            }
            //VER IMPLEMENTACION DE getValueAsStringArray PARA QUE DEVUELVA LOS PERFILES NUEVOS
            String[] profileNames = LAT_GeneralConfigDao.getValueAsStringArray('LAT_MX_OpportunityValidations_Profiles', ' , ');

            Boolean containsProfileName = false;
            for(String pn : profileNames) containsProfileName = pn == currentUser.Profile.Name ? true : false;
            
            system.debug('containsProfileName #### Mauri' + containsProfileName);
            if(containsProfileName && currentUser.LAT_MX_KAM__c != null){
                opp.ownerId = currentUser.LAT_MX_KAM__c;
                try{
                    update opp;
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                }
            }
            
            if(opp.LAT_MX_ClientPaymentPeriod__c != opp.LAT_MX_OrderPaymentPeriod__c && opp.LAT_MX_LastTotalAmountSentToJDE__c != opp.LAT_MX_AmountWithTaxes__c){
                
                Account acc = [SELECT Id, LAT_MX_CreditAndCollectionsExecutive__c FROM Account WHERE Id =: opp.LAT_Account__c];
                
                if(acc.LAT_MX_CreditAndCollectionsExecutive__c != null){
                    User us = [SELECT Id, ManagerId FROM User WHERE id =: acc.LAT_MX_CreditAndCollectionsExecutive__c];
                    if(us.ManagerId != null){
                        opp.LAT_MX_CredAndCollExecutiveManager__c = us.ManagerId;
                    }
                }
                opp.LAT_StageName__c = 'Payment period approval';
                opp.LAT_Integration__c = true;
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_OrderBlocked');
                
                try{
                    update opp;
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                }           
                
                Approval.ProcessSubmitRequest ap = new Approval.ProcessSubmitRequest();
                ap.setObjectId(opp.Id);
                Approval.ProcessResult result = Approval.process(ap);

                return label.LAT_MX_BTN07_00001;
                //LAT_MX_BTN07_00001: Enviado a aprobación
            }else{
                String strRestricciones = checkRestricciones(listOli);
                if (strRestricciones != '' && strRestricciones != null) {
                    return strRestricciones;
                } else {
                    return 'ok';
                }
                
            }            
        }
    }

    // Cante version
    webService static String PaymentPeridoValidation2(String IdPedido){
            LAT_Opportunity__c opp = [SELECT Id, LAT_MX_ClientPaymentPeriod__c, LAT_MX_OrderPaymentPeriod__c, RecordTypeId, LAT_StageName__c, LAT_Account__c, 
                                            LAT_MX_LastTotalAmountSentToJDE__c, LAT_MX_AmountWithTaxes__c,
                                            (SELECT Id, LAT_SkuText__c, LAT_AR_UOM__c, LAT_Quantity__c FROM OpportunityLineItems__r)
                                            FROM LAT_Opportunity__c WHERE Id =: IdPedido];
            Profile profile = [select Name from profile where id = : userinfo.getProfileId() limit 1][0];
            User currentUser = [Select id,LAT_MX_KAM__c, Profile.Name from User where id =: userinfo.getUserId()][0];
            String lat_Kam = currentUser.LAT_MX_KAM__c;
            String perfil = currentUser.Profile.Name;
            //List<LAT_OpportunityLineItem__c> listOli = [SELECT Id FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c =: opp.Id LIMIT 1];
            
            //if(listOli.isEmpty()){
            //    return ('Error: ' + label.LAT_MX_BTN07_00002);
                //LAT_MX_BTN07_00002: No es posible enviar a JDE porque no hay productos seleccionados.
            //}
            //VER IMPLEMENTACION DE getValueAsStringArray PARA QUE DEVUELVA LOS PERFILES NUEVOS
            String[] profileNames = LAT_GeneralConfigDao.getValueAsStringArray('LAT_MX_OpportunityValidations_Profiles', ' , ');

            Boolean containsProfileName = false;
            for(String pn : profileNames) containsProfileName = pn == currentUser.Profile.Name ? true : false;
            
            system.debug('containsProfileName #### Mauri' + containsProfileName);

            // MauriTrue = error
            if(containsProfileName && currentUser.LAT_MX_KAM__c != null){
                opp.ownerId = currentUser.LAT_MX_KAM__c;
                try{
                    update opp;
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                }
            }
            system.debug('MauriOdio++++' + opp.LAT_MX_ClientPaymentPeriod__c);
            system.debug('MauriOdio++++' + opp.LAT_MX_OrderPaymentPeriod__c);
            system.debug('MauriOdio++++' + opp.LAT_MX_LastTotalAmountSentToJDE__c);
            system.debug('MauriOdio++++' + opp.LAT_MX_AmountWithTaxes__c);
            system.debug('MauriOdio++++' + (opp.LAT_MX_ClientPaymentPeriod__c != opp.LAT_MX_OrderPaymentPeriod__c && opp.LAT_MX_LastTotalAmountSentToJDE__c != opp.LAT_MX_AmountWithTaxes__c));
            if(opp.LAT_MX_ClientPaymentPeriod__c != opp.LAT_MX_OrderPaymentPeriod__c && opp.LAT_MX_LastTotalAmountSentToJDE__c != opp.LAT_MX_AmountWithTaxes__c){
                system.debug('MauriOdio++++Entroogood');
                Account acc = [SELECT Id, LAT_MX_CreditAndCollectionsExecutive__c FROM Account WHERE Id =: opp.LAT_Account__c];
                
                if(acc.LAT_MX_CreditAndCollectionsExecutive__c != null){
                    User us = [SELECT Id, ManagerId FROM User WHERE id =: acc.LAT_MX_CreditAndCollectionsExecutive__c];
                    if(us.ManagerId != null){
                        opp.LAT_MX_CredAndCollExecutiveManager__c = us.ManagerId;
                    }
                }
                opp.LAT_StageName__c = 'Payment period approval';
                opp.LAT_Integration__c = true;
                opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_OrderBlocked');
                List<LAT_OpportunityLineItem__c> lines = opp.OpportunityLineItems__r;
                LAT_MX_WS02_PriceCalculateInterface.execute(opp.Id, opp.OpportunityLineItems__r);
                if(lines.size() > 0) {
                    update lines;
                }

                try{
                    update opp;
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                }           
                
                Approval.ProcessSubmitRequest ap = new Approval.ProcessSubmitRequest();
                ap.setObjectId(opp.Id);
                Approval.ProcessResult result = Approval.process(ap);

                return label.LAT_MX_BTN07_00001;
                //LAT_MX_BTN07_00001: Enviado a aprobación
            }else{
                return 'ok';
            }            
        }

    @future(callout=true)
    public static void metodo(Id oppId) {
            String msg = PaymentPeridoValidation2(oppId);
            LAT_DebugUtil debug = new LAT_DebugUtil();
            debug.setOrigin('LAT_MX_LATOpportunityAfter Mobile Order');
            if (msg == 'ok' ) {
                //
                debug.setResult('envio directo a jde');
                System.debug('%%%% envio directo a jde');
                LAT_MX_WS03_SalesOrderHandlerInterface.SalesOrderInterface(oppId);
                LAT_MX_WS03_SalesOrderHandlerInterface.isProcessing = true;

            } else {
                // nada
                System.debug('%%%% se envio a aprobacion' + msg);
                debug.setResult('%%%% se envio a aprobacion' + msg);
            }
            debug.insertDebug();
    }
    
    public static String checkRestricciones(List<LAT_OpportunityLineItem__c> olis) {
        Boolean hayRestr = false;
        String mensaje = '';
        for (LAT_OpportunityLineItem__c oli : olis) {
            System.debug('%%%%%% oli.LAT_Product__r.LAT_RestrictionEnd__c : '+oli.LAT_Product__r.LAT_RestrictionEnd__c);
            System.debug('%%%%%% oli.LAT_Product__r.LAT_RestrictionInit__c : '+oli.LAT_Product__r.LAT_RestrictionInit__c);
            System.debug('%%%%%% oli.LAT_Product__r.LAT_RestrictionDescription__c : '+oli.LAT_Product__r.LAT_RestrictionDescription__c);
            if (oli.LAT_Product__r.LAT_RestrictionEnd__c >= Date.today() && oli.LAT_Product__r.LAT_RestrictionInit__c <= Date.today()) {
                hayRestr = true;
                System.debug('%%%%%%% restriccion : ' + oli.LAT_Product__r.Name + ': '+oli.LAT_Product__r.LAT_RestrictionDescription__c);
                mensaje = mensaje + ' - ' + oli.LAT_Product__r.Name + ': '+oli.LAT_Product__r.LAT_RestrictionDescription__c + '.\n';
                System.debug('%%%%%%% restriccion MENSAJE: ' + mensaje);
            }
        }
        if (hayRestr) {
            System.debug('%%%%%%% checkRestricciones --> mensaje Antes : '+mensaje);
             mensaje = 'Los siguientes Productos están restringidos, para continuar de todas formas presione OK: \n' + mensaje;
        }
        System.debug('%%%%%%% checkRestricciones --> mensaje : '+mensaje);
        return mensaje;
    }       
}
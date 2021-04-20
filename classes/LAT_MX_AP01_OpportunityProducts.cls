/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Opportunity Products
********************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_AP01_OpportunityProducts{
       
    /*****************************************************************************************************************
    * Nombre del metodo: quotaCalculation
    * Descripcion: Metodo que recalcula el valor de la Cuota
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 28/11/2013
    * Modo: after insert, after update, after delete
    ******************************************************************************************************************/
    
    public static void quotaCalculation(List<OpportunityLineItem> triggerNew, map<Id,OpportunityLineItem> oldMap){                            
        
        Set<String> setQuotaIds = new Set<String>();
        
        if(!triggerNew.isEmpty()){          
            for(OpportunityLineItem oli: triggerNew){
                if(oli.LAT_MX_Quota__c != null && oli.cd_line_status__c != null && (integer.valueOf(oli.cd_line_status__c) < 560 || (integer.valueOf(oli.cd_line_status__c) == 560 && (trigger.isInsert || (oldMap != null && oli.cd_line_status__c != oldMap.get(oli.Id).cd_line_status__c))))){
                    setQuotaIds.add(oli.LAT_MX_Quota__c);
                }          
            }
        }       
        
        if(!oldMap.isEmpty()){          
            for(OpportunityLineItem oli: oldMap.Values()){
                if(oli.LAT_MX_Quota__c != null && oli.cd_line_status__c != null && (integer.valueOf(oli.cd_line_status__c) < 560 || (integer.valueOf(oli.cd_line_status__c) == 560 && oli.cd_line_status__c != oldMap.get(oli.Id).cd_line_status__c))){
                    setQuotaIds.add(oli.LAT_MX_Quota__c);
                }          
            }
        }    
        
        if(!setQuotaIds.isEmpty()){
        
            Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('Opportunity',
                                                                    new set<String>{'LAT_MX_OPP_HeaderBlocked',
                                                                                    'LAT_MX_OPP_NewOrder',
                                                                                    'LAT_MX_OPP_OrderBlocked'});     
            
            List<OpportunityLineItem> listOli = [SELECT Id, Quantity, LAT_MX_Quota__c, 
                                                    OpportunityId, PriceBookEntry.Product2.Name 
                                                    FROM OpportunityLineItem 
                                                    WHERE LAT_MX_Quota__c IN: setQuotaIds 
                                                    AND Remover__c = false 
                                                    AND Opportunity.RecordTypeId IN: setOppRt];
    
            List<LAT_MX_QTA_Quota__c> listQuota = [SELECT Id, Name, LAT_MX_QuotaBalance__c, 
                                                    LAT_MX_Quota__c 
                                                    FROM LAT_MX_QTA_Quota__c 
                                                    WHERE Id IN: setQuotaIds];                     
            
            for(LAT_MX_QTA_Quota__c quota: listQuota){
                quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c;
            }            
            
            Map<String,Decimal> mapQuotaIdQuantity = new Map<String,Decimal>();
            Set<String> setIdOpps = new Set<String>();       
            
            for(OpportunityLineItem oli: listOli){
                setIdOpps.add(oli.OpportunityId);
                if(!mapQuotaIdQuantity.containsKey(oli.LAT_MX_Quota__c)){
                    mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, oli.Quantity);
                }else{
                    Decimal Quantity = mapQuotaIdQuantity.get(oli.LAT_MX_Quota__c) + oli.Quantity;
                    mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, Quantity);
                }
            }
            
            Map<String,Opportunity> mapOpps = new Map<String,Opportunity>([SELECT Id, 
                                                                            LAT_MX_OrderNumberCRM__c, 
                                                                            Account.Name 
                                                                            FROM Opportunity 
                                                                            WHERE Id IN: setIdOpps]);
            
            Map<String,LAT_MX_QTA_Quota__c> mapNegativeQuotas = new Map<String,LAT_MX_QTA_Quota__c>();              
            
            for(LAT_MX_QTA_Quota__c quota: listQuota){
                if(mapQuotaIdQuantity.containsKey(quota.Id)){
                    quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c - mapQuotaIdQuantity.get(quota.Id);
                    if(quota.LAT_MX_QuotaBalance__c < 0){
                        mapNegativeQuotas.put(quota.Id, quota);
                    }
                }
            }
            
            try{
                update listQuota;
            }catch(DMLException e){
            
            }
            
            Map<Opportunity,List<OpportunityLineItem>> mapOppOlis = new Map<Opportunity,List<OpportunityLineItem>>();
            
            for(OpportunityLineItem oli: listOli){
                if(mapNegativeQuotas.containsKey(oli.LAT_MX_Quota__c)){
                    if(!mapOppOlis.containsKey(mapOpps.get(oli.OpportunityId))){
                        mapOppOlis.put(mapOpps.get(oli.OpportunityId),new List<OpportunityLineItem>{oli});
                    }else{
                        mapOppOlis.get(mapOpps.get(oli.OpportunityId)).add(oli); 
                    }
                }  
            }
            
            Set<String> setIdMembers = new Set<String>();       
            Group grupo = [SELECT Id, (SELECT UserOrGroupId FROM groupMembers) 
                            FROM Group 
                            WHERE Name = 'LAT_MX_QuotaAdmins']; 
            
            for(GroupMember member : grupo.groupMembers){        
                setIdMembers.add(member.userOrGroupId);    
            }    
            
            List<User> listUsers = [SELECT Email 
                                    FROM User 
                                    WHERE Id IN: setIdMembers];
            List<String> listMailsAdresses = new List<String>();   
            
            for(User u : listUsers) {        
                listMailsAdresses.add(u.email);    
            }    
            
            List<Messaging.SingleEmailMessage> listMails = new List<Messaging.SingleEmailMessage>();
            
            for(Opportunity opp: mapOppOlis.keySet()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(listMailsAdresses);   
                mail.setSubject('Cuota de producto excedida');
                String cuerpoDeMail = '';
                cuerpoDeMail += 'El pedido ' + opp.LAT_MX_OrderNumberCRM__c + ' perteneciente al cliente ' + opp.Account.Name; 
                cuerpoDeMail += ' posee los siguientes productos con cuota excedente como resultado de modificaciones realizadas en JDE: <br/><br/>';
                for(OpportunityLineItem oli: mapOppOlis.get(opp)){
                    cuerpoDeMail += '<a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + oli.LAT_MX_Quota__c + '>' + mapNegativeQuotas.get(oli.LAT_MX_Quota__c).Name + ' excedida por ' + oli.PriceBookEntry.Product2.Name + '</a>' + '<br/>';
                }
                cuerpoDeMail += '<br/>';
                cuerpoDeMail += 'Por favor, corrija las cuotas correspondientes. <br/><br/>';                 
                cuerpoDeMail += 'Si desea acceder al pedido, haga click en el siguiente link: <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '>haga click aquí</a> <br/><br/>';
                cuerpoDeMail += 'Cordialmente,<br/><br/><br/>';
                cuerpoDeMail += 'Equipo CRM';
                mail.setHTMLBody(cuerpoDeMail);
                listMails.add(mail);
            }      
            
            try{
                Messaging.sendEmail(listMails);
            }catch(Exception e){} 
        
        }       
    }

    //MIGRATED 04/11/2016
    public static void quotaCalculation(List<LAT_OpportunityLineItem__c> triggerNew, map<Id,LAT_OpportunityLineItem__c> oldMap){                            
        
        Set<String> setQuotaIds = new Set<String>();
        
        if(!triggerNew.isEmpty()){          
            for(LAT_OpportunityLineItem__c oli: triggerNew){
                if(oli.LAT_MX_Quota__c != null && oli.LAT_CdLineStatus__c != null && (integer.valueOf(oli.LAT_CdLineStatus__c) < 560 || (integer.valueOf(oli.LAT_CdLineStatus__c) == 560 && (trigger.isInsert || (oldMap != null && oli.LAT_CdLineStatus__c != oldMap.get(oli.Id).LAT_CdLineStatus__c))))){
                    setQuotaIds.add(oli.LAT_MX_Quota__c);
                }          
            }
        }       
        
        if(!oldMap.isEmpty()){          
            for(LAT_OpportunityLineItem__c oli: oldMap.Values()){
                if(oli.LAT_MX_Quota__c != null && oli.LAT_CdLineStatus__c != null && (integer.valueOf(oli.LAT_CdLineStatus__c) < 560 || (integer.valueOf(oli.LAT_CdLineStatus__c) == 560 && oli.LAT_CdLineStatus__c != oldMap.get(oli.Id).LAT_CdLineStatus__c))){
                    setQuotaIds.add(oli.LAT_MX_Quota__c);
                }          
            }
        }    
        
        if(!setQuotaIds.isEmpty()){
        
            Set<Id> setOppRt = Global_RecordTypeCache.getRtIdSet('LAT_Opportunity__c',
                                                                    new set<String>{'LAT_MX_OPP_HeaderBlocked',
                                                                                    'LAT_MX_OPP_NewOrder',
                                                                                    'LAT_MX_OPP_OrderBlocked'});     
            
            List<LAT_OpportunityLineItem__c> listOli = [SELECT Id, LAT_Quantity__c, LAT_MX_Quota__c, 
                                                    LAT_Opportunity__c, LAT_Product__r.Name 
                                                    FROM LAT_OpportunityLineItem__c 
                                                    WHERE LAT_MX_Quota__c IN: setQuotaIds 
                                                    AND LAT_Remover__c = false 
                                                    AND LAT_Opportunity__r.RecordTypeId IN: setOppRt];
    
            List<LAT_MX_QTA_Quota__c> listQuota = [SELECT Id, Name, LAT_MX_QuotaBalance__c, 
                                                    LAT_MX_Quota__c 
                                                    FROM LAT_MX_QTA_Quota__c 
                                                    WHERE Id IN: setQuotaIds];                     
            
            for(LAT_MX_QTA_Quota__c quota: listQuota){
                quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c;
            }            
            
            Map<String,Decimal> mapQuotaIdQuantity = new Map<String,Decimal>();
            Set<String> setIdOpps = new Set<String>();       
            
            for(LAT_OpportunityLineItem__c oli: listOli){
                setIdOpps.add(oli.LAT_Opportunity__c);
                if(!mapQuotaIdQuantity.containsKey(oli.LAT_MX_Quota__c)){
                    mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, oli.LAT_Quantity__c);
                }else{
                    Decimal Quantity = mapQuotaIdQuantity.get(oli.LAT_MX_Quota__c) + oli.LAT_Quantity__c;
                    mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, Quantity);
                }
            }
            
            Map<String,LAT_Opportunity__c> mapOpps = new Map<String,LAT_Opportunity__c>([SELECT Id, 
                                                                            LAT_MX_OrderNumberCRM__c, 
                                                                            LAT_Account__r.Name 
                                                                            FROM LAT_Opportunity__c 
                                                                            WHERE Id IN: setIdOpps]);
            
            Map<String,LAT_MX_QTA_Quota__c> mapNegativeQuotas = new Map<String,LAT_MX_QTA_Quota__c>();              
            
            for(LAT_MX_QTA_Quota__c quota: listQuota){
                if(mapQuotaIdQuantity.containsKey(quota.Id)){
                    quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c - mapQuotaIdQuantity.get(quota.Id);
                    if(quota.LAT_MX_QuotaBalance__c < 0){
                        mapNegativeQuotas.put(quota.Id, quota);
                    }
                }
            }
            
            try{
                update listQuota;
            }catch(DMLException e){
            
            }
            
            Map<LAT_Opportunity__c,List<LAT_OpportunityLineItem__c>> mapOppOlis = new Map<LAT_Opportunity__c,List<LAT_OpportunityLineItem__c>>();
            
            for(LAT_OpportunityLineItem__c oli: listOli){
                if(mapNegativeQuotas.containsKey(oli.LAT_MX_Quota__c)){
                    if(!mapOppOlis.containsKey(mapOpps.get(oli.LAT_Opportunity__c))){
                        mapOppOlis.put(mapOpps.get(oli.LAT_Opportunity__c),new List<LAT_OpportunityLineItem__c>{oli});
                    }else{
                        mapOppOlis.get(mapOpps.get(oli.LAT_Opportunity__c)).add(oli); 
                    }
                }  
            }
            
            Set<String> setIdMembers = new Set<String>();       
            Group grupo = [SELECT Id, (SELECT UserOrGroupId FROM groupMembers) 
                            FROM Group 
                            WHERE Name = 'LAT_MX_QuotaAdmins']; 
            
            for(GroupMember member : grupo.groupMembers){        
                setIdMembers.add(member.userOrGroupId);    
            }    
            
            List<User> listUsers = [SELECT Email 
                                    FROM User 
                                    WHERE Id IN: setIdMembers];
            List<String> listMailsAdresses = new List<String>();   
            
            for(User u : listUsers) {        
                listMailsAdresses.add(u.email);    
            }    
            
            List<Messaging.SingleEmailMessage> listMails = new List<Messaging.SingleEmailMessage>();
            
            for(LAT_Opportunity__c opp: mapOppOlis.keySet()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(listMailsAdresses);   
                mail.setSubject('Cuota de producto excedida');
                String cuerpoDeMail = '';
                cuerpoDeMail += 'El pedido ' + opp.LAT_MX_OrderNumberCRM__c + ' perteneciente al cliente ' + opp.LAT_Account__r.Name; 
                cuerpoDeMail += ' posee los siguientes productos con cuota excedente como resultado de modificaciones realizadas en JDE: <br/><br/>';
                for(LAT_OpportunityLineItem__c oli: mapOppOlis.get(opp)){
                    cuerpoDeMail += '<a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + oli.LAT_MX_Quota__c + '>' + mapNegativeQuotas.get(oli.LAT_MX_Quota__c).Name + ' excedida por ' + oli.LAT_Product__r.Name + '</a>' + '<br/>';
                }
                cuerpoDeMail += '<br/>';
                cuerpoDeMail += 'Por favor, corrija las cuotas correspondientes. <br/><br/>';                 
                cuerpoDeMail += 'Si desea acceder al pedido, haga click en el siguiente link: <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id + '>haga click aquí</a> <br/><br/>';
                cuerpoDeMail += 'Cordialmente,<br/><br/><br/>';
                cuerpoDeMail += 'Equipo CRM';
                mail.setHTMLBody(cuerpoDeMail);
                listMails.add(mail);
            }      
            
            try{
                Messaging.sendEmail(listMails);
            }catch(Exception e){} 
        
        }       
    }

    /********************************************************************************************************************************
    * Nombre del metodo: relateToQuota
    * Descripcion: Metodo que relaciona el Opportunity Product con la Cuota vigente (si la hubiera) al momento del primer envio a JDE
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 29/11/2013
    * Modo: before insert, before update
    *********************************************************************************************************************************/
   
    public static void relateToQuota(List<OpportunityLineItem> triggerNew, Map<Id,OpportunityLineItem> oldMap){
    
        Set<String> setPBEId = new Set<String>();
        Set<String> setOppId = new Set<String>();
        for(OpportunityLineItem oli: triggerNew){
            if(oli.cd_line_status__c != null && oldMap.get(oli.Id).cd_line_status__c == null){
                setOppId.add(oli.OpportunityId);
                setPBEId.add(oli.PricebookEntryId);
            }          
        }
        if(!setOppId.isEmpty()){
            Map<String,Opportunity> mapOpp = new Map<String,Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE Id IN: setOppId]);
            Set<String> setAccountIds = new Set<String>();
            for(Opportunity opp: mapOpp.Values()){
                setAccountIds.add(opp.AccountId);      
            }
            if(!setAccountIds.isEmpty()){
                List<LAT_MX_QTA_Quota__c> listQuota = [SELECT Id, LAT_MX_QuotaBalance__c, LAT_MX_Product__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c FROM LAT_MX_QTA_Quota__c WHERE LAT_MX_Client__c IN: setAccountIds AND LAT_MX_ValidityUntil__c >=: date.Today() AND LAT_MX_ValiditySince__c <=: date.Today()];
                
                Map<String,LAT_MX_QTA_Quota__c> mapProdAndAccountIdQuota = new Map<String,LAT_MX_QTA_Quota__c>();
                for(LAT_MX_QTA_Quota__c quota: listQuota){
                    mapProdAndAccountIdQuota.put(quota.LAT_MX_Product__c + '-' + quota.LAT_MX_Client__c, quota);
                }
                
                Map<String,PricebookEntry> mapPBE = new Map<String,PricebookEntry>([SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN: setPBEId]);
                
                for(OpportunityLineItem oli: triggerNew){
                    if(oli.cd_line_status__c != null && oldMap.get(oli.Id).cd_line_status__c == null){
                        if(mapProdAndAccountIdQuota.containsKey(mapPBE.get(oli.PricebookEntryId).Product2Id + '-' + mapOpp.get(oli.OpportunityId).AccountId)){
                            oli.LAT_MX_Quota__c = mapProdAndAccountIdQuota.get(mapPBE.get(oli.PricebookEntryId).Product2Id + '-' + mapOpp.get(oli.OpportunityId).AccountId).Id;
                        }
                    }
                }
            }
        } 
    }

    //MIGRATED 04/11/2016
    public static void relateToQuota(List<LAT_OpportunityLineItem__c> triggerNew, Map<Id,LAT_OpportunityLineItem__c> oldMap){
    
        Set<String> setPBEId = new Set<String>();
        Set<String> setOppId = new Set<String>();
        for(LAT_OpportunityLineItem__c oli: triggerNew){
            if(oli.LAT_CdLineStatus__c != null && oldMap.get(oli.Id).LAT_CdLineStatus__c == null){
                setOppId.add(oli.LAT_Opportunity__c);
                setPBEId.add(oli.LAT_Product__c);
            }          
        }
        if(!setOppId.isEmpty()){
            Map<String,LAT_Opportunity__c> mapOpp = new Map<String,LAT_Opportunity__c>([SELECT Id, LAT_Account__c FROM LAT_Opportunity__c WHERE Id IN: setOppId]);
            Set<String> setAccountIds = new Set<String>();
            for(LAT_Opportunity__c opp: mapOpp.Values()){
                setAccountIds.add(opp.LAT_Account__c);      
            }
            if(!setAccountIds.isEmpty()){
                List<LAT_MX_QTA_Quota__c> listQuota = [SELECT Id, LAT_MX_QuotaBalance__c, LAT_Product__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c FROM LAT_MX_QTA_Quota__c WHERE LAT_MX_Client__c IN: setAccountIds AND LAT_MX_ValidityUntil__c >=: date.Today() AND LAT_MX_ValiditySince__c <=: date.Today()];
                
                Map<String,LAT_MX_QTA_Quota__c> mapProdAndAccountIdQuota = new Map<String,LAT_MX_QTA_Quota__c>();
                for(LAT_MX_QTA_Quota__c quota: listQuota){
                    mapProdAndAccountIdQuota.put(quota.LAT_Product__c + '-' + quota.LAT_MX_Client__c, quota);
                }
                
                Map<String,LAT_Product__c> mapPBE = new Map<String,LAT_Product__c>([SELECT Id FROM LAT_Product__c WHERE Id IN: setPBEId]);
                
                for(LAT_OpportunityLineItem__c oli: triggerNew){
                    if(oli.LAT_CdLineStatus__c != null && oldMap.get(oli.Id).LAT_CdLineStatus__c == null){
                        if(mapProdAndAccountIdQuota.containsKey(mapPBE.get(oli.LAT_Product__c).Id + '-' + mapOpp.get(oli.LAT_Opportunity__c).LAT_Account__c)){
                            oli.LAT_MX_Quota__c = mapProdAndAccountIdQuota.get(mapPBE.get(oli.LAT_Product__c).Id  + '-' + mapOpp.get(oli.LAT_Opportunity__c).LAT_Account__c).Id;
                        }
                    }
                }
            }
        } 
    }
    
    /********************************************************************************************************************************
    * Nombre del metodo: blockOrder
    * Descripcion: Metodo que cambia el Record Type de la Opportunity a 'Pedido Bloqueado' cuando todos los productos tienen 
    *              Status (Hasta) mayor a 560.
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 29/11/2013
    * Modo: after insert, after update, after delete
    *********************************************************************************************************************************/
    
    public static void blockOrder(List<OpportunityLineItem> triggerNew,Map<Id,OpportunityLineItem> oldMap){
        
        Set<String> setOppIds = new Set<String>();
        if(!triggerNew.isEmpty()){  
            for(OpportunityLineItem oli: triggerNew){
                setOppIds.add(oli.OpportunityId);
            }
        }else if(!oldMap.isEmpty()){
            for(OpportunityLineItem oli: oldMap.Values()){
                setOppIds.add(oli.OpportunityId);
            }
        }           
              
        String rtOrderBlocked = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_OrderBlocked');
        
        List<Opportunity> listOpp = [SELECT Id, RecordTypeId, LAT_MX_LogisticsStatus__c, LAT_MX_BackorderItems__c, (SELECT Id, OpportunityId, Backorder__c, LAT_MX_CDLineStatusFrom__c, cd_line_status__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN: setOppIds AND RecordTypeId !=: rtOrderBlocked];

        List<Opportunity> listOppsToUpdate = new List<Opportunity>();
        
        for(Opportunity opp: listOpp){
            Integer i = 0;
            String MinStatus = null;
            String MinPreviousStatus = null;
            Boolean isToBeBlocked = true;
            opp.LAT_MX_BackorderItems__c = false;
            for(OpportunityLineItem oli: opp.OpportunityLineItems){
                if((oli.cd_line_status__c != null && integer.valueOf(oli.cd_line_status__c) <= 560) || oli.cd_line_status__c == null){
                    isToBeBlocked = false;
                }
                if(oli.LAT_MX_CDLineStatusFrom__c != null && (MinStatus == null || (MinStatus != null && oli.LAT_MX_CDLineStatusFrom__c < MinStatus))){
                    MinStatus = oli.LAT_MX_CDLineStatusFrom__c;
                    if(MinStatus == '999' && oldMap.containsKey(oli.Id)){
                        MinPreviousStatus = oldMap.get(oli.Id).LAT_MX_CDLineStatusFrom__c;
                    }
                }
                if(oli.Backorder__c == 1){
                    opp.LAT_MX_BackorderItems__c = true;
                }
                i++;
            }
            if(isToBeBlocked){
                opp.RecordTypeId = rtOrderBlocked;
            }
            
            if(!opp.OpportunityLineItems.isEmpty() && MinStatus != null){
                if(MinStatus == '540'){
                    opp.LAT_MX_LogisticsStatus__c = 'Ready to ship';
                }else if(MinStatus == '560'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order in assortment';
                }else if(MinStatus == '580'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order in delivery';
                }else if(MinStatus == '600'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order billed';
                }else if(MinStatus == '620'){
                    opp.LAT_MX_LogisticsStatus__c = 'Bill printed ';
                }else if(MinStatus == '999' && MinPreviousStatus != null && MinPreviousStatus == '620'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order entered';
                }
            }
            listOppsToUpdate.add(opp);  
        }        
        if(!listOppsToUpdate.isEmpty()){
            try{
                update listOppsToUpdate;
            }catch(DMlException e){
                if(!triggerNew.isEmpty()){  
                    for(OpportunityLineItem oli: triggerNew){
                        oli.addError(label.LAT_MX_AP01_00022);
                        //LAT_MX_AP01_00022: Uno o mas productos del pedido no se pudieron actualizar correctamente.
                    }
                }else if(!oldMap.isEmpty()){
                    for(OpportunityLineItem oli: oldMap.Values()){
                        oli.addError(label.LAT_MX_AP01_00022);
                        //LAT_MX_AP01_00022: Uno o mas productos del pedido no se pudieron actualizar correctamente. 
                    }
                }                
            }
        }
    }

    //MIGRATED 04/11/2016
    public static void blockOrder(List<LAT_OpportunityLineItem__c> triggerNew,Map<Id,LAT_OpportunityLineItem__c> oldMap){
        
        Set<String> setOppIds = new Set<String>();
        if(!triggerNew.isEmpty()){  
            for(LAT_OpportunityLineItem__c oli: triggerNew){
                setOppIds.add(oli.LAT_Opportunity__c);
            }
        }else if(!oldMap.isEmpty()){
            for(LAT_OpportunityLineItem__c oli: oldMap.Values()){
                setOppIds.add(oli.LAT_Opportunity__c);
            }
        }           
              
        String rtOrderBlocked = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_OrderBlocked');
        
        List<LAT_Opportunity__c> listOpp = [SELECT Id, RecordTypeId, LAT_MX_LogisticsStatus__c, LAT_MX_BackorderItems__c, (SELECT Id, LAT_Opportunity__c, LAT_Backorder__c, LAT_MX_CDLineStatusFrom__c, LAT_CdLineStatus__c FROM OpportunityLineItems__r) FROM LAT_Opportunity__c WHERE Id IN: setOppIds AND RecordTypeId !=: rtOrderBlocked];

        List<LAT_Opportunity__c> listOppsToUpdate = new List<LAT_Opportunity__c>();
        
        for(LAT_Opportunity__c opp: listOpp){
            Integer i = 0;
            String MinStatus = null;
            String MinPreviousStatus = null;
            Boolean isToBeBlocked = true;
            opp.LAT_MX_BackorderItems__c = false;
            for(LAT_OpportunityLineItem__c oli: opp.OpportunityLineItems__r){
                if((oli.LAT_CdLineStatus__c != null && integer.valueOf(oli.LAT_CdLineStatus__c) <= 560) || oli.LAT_CdLineStatus__c == null){
                    isToBeBlocked = false;
                }
                if(oli.LAT_MX_CDLineStatusFrom__c != null && (MinStatus == null || (MinStatus != null && oli.LAT_MX_CDLineStatusFrom__c < MinStatus))){
                    MinStatus = oli.LAT_MX_CDLineStatusFrom__c;
                    if(MinStatus == '999' && oldMap.containsKey(oli.Id)){
                        MinPreviousStatus = oldMap.get(oli.Id).LAT_MX_CDLineStatusFrom__c;
                    }
                }
                if(oli.LAT_Backorder__c == 1){
                    opp.LAT_MX_BackorderItems__c = true;
                }
                i++;
            }
            if(isToBeBlocked){
                opp.RecordTypeId = rtOrderBlocked;
            }
            
            if(!opp.OpportunityLineItems__r.isEmpty() && MinStatus != null){
                if(MinStatus == '540'){
                    opp.LAT_MX_LogisticsStatus__c = 'Ready to ship';
                }else if(MinStatus == '560'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order in assortment';
                }else if(MinStatus == '580'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order in delivery';
                }else if(MinStatus == '600'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order billed';
                }else if(MinStatus == '620'){
                    opp.LAT_MX_LogisticsStatus__c = 'Bill printed ';
                }else if(MinStatus == '999' && MinPreviousStatus != null && MinPreviousStatus == '620'){
                    opp.LAT_MX_LogisticsStatus__c = 'Order entered';
                }
            }
            listOppsToUpdate.add(opp);  
        }        
        if(!listOppsToUpdate.isEmpty()){
            try{
                update listOppsToUpdate;
            }catch(DMlException e){
                if(!triggerNew.isEmpty()){  
                    for(LAT_OpportunityLineItem__c oli: triggerNew){
                        oli.addError(label.LAT_MX_AP01_00022);
                        //LAT_MX_AP01_00022: Uno o mas productos del pedido no se pudieron actualizar correctamente.
                    }
                }else if(!oldMap.isEmpty()){
                    for(LAT_OpportunityLineItem__c oli: oldMap.Values()){
                        oli.addError(label.LAT_MX_AP01_00022);
                        //LAT_MX_AP01_00022: Uno o mas productos del pedido no se pudieron actualizar correctamente. 
                    }
                }                
            }
        }
    }    

    /****************************************************************************************
    * Nombre del metodo: updatesCountry
    * Descripcion: Metodo que completa el campo Country cuando se inserta un nuevo registro
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 02/12/2013
    * Modo: before insert
    ****************************************************************************************/
    
    public static void updatesCountry(List<OpportunityLineItem> triggerNew){

        Set<String> setOppIds = new Set<String>();
        for(OpportunityLineItem oli: triggerNew){
            setOppIds.add(oli.OpportunityId);
        }
                
        Map<String,Opportunity> mapOpp = new Map<String,Opportunity>([SELECT Id, Account.Revenue_Country__c FROM Opportunity WHERE Id IN: setOppIds]);
        
        for(OpportunityLineItem oli: triggerNew){
            oli.LAT_MX_Country__c = mapOpp.get(oli.OpportunityId).Account.Revenue_Country__c;
        }     
    }

    //MIGRATED 04/11/2016
    public static void updatesCountry(List<LAT_OpportunityLineItem__c> triggerNew){

        Set<String> setOppIds = new Set<String>();
        for(LAT_OpportunityLineItem__c oli: triggerNew){
            setOppIds.add(oli.LAT_Opportunity__c);
        }
                
        Map<String,LAT_Opportunity__c> mapOpp = new Map<String,LAT_Opportunity__c>([SELECT Id, LAT_Account__r.Revenue_Country__c FROM LAT_Opportunity__c WHERE Id IN: setOppIds]);
        
        for(LAT_OpportunityLineItem__c oli: triggerNew){
            oli.LAT_MX_Country__c = mapOpp.get(oli.LAT_Opportunity__c).LAT_Account__r.Revenue_Country__c;
        }     
    }

    public static void updateUnit (List<OpportunityLineItem> triggerNew) {
        Map<String,id> mapeoKey = LAT_ConversionRate.getOpportunityMapping('12', triggerNew, 'C9');
        Map <String,Double> porcentajes = LAT_ConversionRate.ConversionRateCalculation(mapeoKey);
        for(OpportunityLineItem oli: triggerNew){
            if(oli.Sku__c != null && oli.CD_unit__c != null){
                String keyConv = '12-'+oli.Sku__c+'-'+oli.CD_unit__c+'-C9';
                Double factor = porcentajes.get(keyConv);    
                if(factor != null && oli.Quantity != null)
                    oli.LAT_C9Quantity__c = oli.Quantity * factor;    
            }
        }  
    }

    //MIGRATED 04/11/2016
    public static void updateUnit (List<LAT_OpportunityLineItem__c> triggerNew) {
        Map<String,id> mapeoKey = LAT_ConversionRate.getOpportunityMapping('12', triggerNew, 'C9');
        Map <String,Double> porcentajes = LAT_ConversionRate.ConversionRateCalculation(mapeoKey);
        Set<String> productosSinUCR = new Set<String>();
        for(LAT_OpportunityLineItem__c oli: triggerNew){
            //If the line has been canceled, we put all quantities to 0.
            if (oli.LAT_CdLineStatus__c == '999' && oli.LAT_StatusDescription__c== 'Cancelado') {
                oli.LAT_Quantity__c = 0;
            } 
            if(oli.LAT_Sku__c != null && oli.LAT_CDUnit__c != null){
                String keyConv = '12-'+oli.LAT_Sku__c+'-'+oli.LAT_CDUnit__c+'-C9';
                Double factor = porcentajes.get(keyConv);    
                if(factor != null && oli.LAT_Quantity__c != null) {
                    oli.LAT_C9Quantity__c = oli.LAT_Quantity__c * factor;    
                } else {
                    if (factor == null) {
                        productosSinUCR.add(oli.LAT_Product__c);
                    }
                }
            }
        }
        if (productosSinUCR.size() > 0 && trigger.isInsert) {
            sendEmailUCR(productosSinUCR);
        }  
    }

    public static decimal parseHelper(string headerText, string campoFormatacao, integer columnIndex) {
        
        integer startIndex = -1;
        integer endIndex = -1;
        
        startIndex = campoFormatacao.indexOf(headerText);
        endIndex = campoFormatacao.indexOf('</tr>', startIndex);
        decimal parsedValue = 0;
        
        string htmlFiltrado = '';
        if(startIndex <= -1 || endIndex <= -1){
            return null;
        }
        htmlFiltrado = campoFormatacao.substring(startIndex, endIndex);
        if (htmlFiltrado == '') {
            return null;
        }
        htmlFiltrado = htmlFiltrado.split('</td>')[columnIndex];
        htmlFiltrado = htmlFiltrado.replaceAll('<.*?>','');
        if (htmlFiltrado != '') {
            parsedValue = Decimal.valueOf(htmlFiltrado.replaceAll('\\.', '').replaceAll(',','.').trim().replaceAll('[^0-9\\.]', ''));
        }
        return parsedValue;
    }
         //MIGRATED 03/11/2016 
    public static void decodeCompositionPrice(List<LAT_OpportunityLineItem__c> triggerNew){
        integer columnNumber = 2; //number 0 is invalid, it's the header
        for(LAT_OpportunityLineItem__c oli :triggerNew){
            if(oli.LAT_FormatField__c != null && oli.LAT_FormatField__c != ''){
                oli.LAT_IPI__c = parseHelper('IEPS', oli.LAT_FormatField__c, columnNumber);
                oli.LAT_NFValue__c = parseHelper('Sub Total', oli.LAT_FormatField__c, columnNumber);//parseHelper('Valor NF PRB', oli.Campo_de_formatacao__c, columnNumber);
                oli.LAT_NFTotal__c = parseHelper('Importe Total', oli.LAT_FormatField__c, columnNumber);
                oli.LAT_TaxReplacement__c = parseHelper('IVA', oli.LAT_FormatField__c, columnNumber);
            }
        }
    }

    public static void setIndexMargin(List<LAT_OpportunityLineItem__c> triggerNew) {
        Set<Id> idProducts = new Set<Id>();
        
        for (LAT_OpportunityLineItem__c oli: triggerNew) {
           idProducts.add(oli.LAT_Product__c); 
        }  
        Map<Id, LAT_Product__c> mapProductsById = new Map<Id, LAT_Product__c>([SELECT Id, LAT_IndexMarca__c FROM LAT_Product__c WHERE Id IN :idProducts]);

       for (LAT_OpportunityLineItem__c oli: triggerNew) {
            if (mapProductsById.keySet().contains(oli.LAT_Product__c) && oli.LAT_C9Quantity__c != null) {
                oli.LAT_IndexMarca__c = mapProductsById.get(oli.LAT_Product__c).LAT_IndexMarca__c * oli.LAT_C9Quantity__c;
            }
        }  
    }
    
    @TestVisible
    private static void sendEmailUCR(Set<String> prodsIds) {
        
        List<LAT_Product__c> prods = [SELECT Id, Name, LAT_Sku__c FROM LAT_Product__c WHERE Id IN :prodsIds];
        LAT_GeneralConfig__c gc = [SELECT Name, id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'MX_UnitConvRates_Notification_Users'];
        List<String> usersOnCopy = gc.LAT_Value__c.split(',');

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(usersOnCopy);
        mail.setSubject('CRM - Factor de  Conversión faltante para Productos');
        String msg = 'Estimado, \nEncontramos que los siguientes productos no tienen asignado un Factor de Conversion de CA a C9:\n ' ;
        for (LAT_Product__c prod : prods) {
            msg += '<b> - ' + prod.Name + ' (SKU: ' + prod.LAT_Sku__c + ')</b> \n';
        }
        msg += '\nEs necesario crear dichos registros para evitar futuros inconvenientes. ';
        msg += '\nLink a la tabla de Conversiones : ' + 'https://' + URL.getSalesforceBaseUrl().getHost() + '/aMW';

        msg += '\n\nMuchas gracias! \n\nEquipo CRM ';

        mail.setPlainTextBody(msg);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
   }      

    public static void setCancelationReaseonDescription(List<LAT_OpportunityLineItem__c> triggerNew) {
        Set<Id> idProducts = new Set<Id>();

        List<UDC__c> codeDescriptions = [SELECT CodDefUsuario__c, Descricao2__c,Internal_Id__c,Name 
                                        FROM UDC__c WHERE Internal_Id__c LIKE '12-%' AND CodProd__c = '42' AND CodUs__c = 'RR'];
        Map<String, String> codeDescriptionsMap = new Map<String, String> ();
        for (UDC__c udc : codeDescriptions) {
            codeDescriptionsMap.put(udc.CodDefUsuario__c, udc.Name);
        }
        
        for (LAT_OpportunityLineItem__c oli: triggerNew) {
            if(oli.LAT_MX_CancellationReason__c != null) {
                if(codeDescriptionsMap.keySet().contains(oli.LAT_MX_CancellationReason__c)) {
                    oli.LAT_MX_CancelationReaseonDescription__c = codeDescriptionsMap.get(oli.LAT_MX_CancellationReason__c);
                }
            }
        }  
       
    }

}
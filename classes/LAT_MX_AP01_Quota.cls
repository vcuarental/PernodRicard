/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Quota
*******************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016
*
********************************************************************************/

public with sharing class LAT_MX_AP01_Quota {

    /*****************************************************************************************************************
    * Nombre del metodo: QuotaBalanceWhenInsert
    * Descripcion: Metodo que completa el campo Quota Balance cuando se inserta un registro
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 09/12/2013
    * Modo: before update
    ******************************************************************************************************************/
    
    public static void QuotaBalanceWhenInsert(List<LAT_MX_QTA_Quota__c> triggerNew){      

        for(LAT_MX_QTA_Quota__c quota: triggerNew){
            quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c;
        }
    
    }
       
    /*****************************************************************************************************************
    * Nombre del metodo: calculateQuotaBalance
    * Descripcion: Metodo que calcula el valor de Quota Balanca
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 09/12/2013
    * Modo: before update
    ******************************************************************************************************************/
    
    public static void calculateQuotaBalance(List<LAT_MX_QTA_Quota__c> triggerNew, map<Id,LAT_MX_QTA_Quota__c> oldMap){                
        if(!Utils.wasMigrationDone('12')) {         
            Set<String> setIdQuota = new Set<String>();
            
            for(LAT_MX_QTA_Quota__c quota: triggerNew){
                if(oldMap.containsKey(quota.Id) && quota.LAT_MX_Quota__c != oldMap.get(quota.Id).LAT_MX_Quota__c){
                    setIdQuota.add(quota.Id);
                }
            }
            
            List<OpportunityLineItem> listOli = new List<OpportunityLineItem>();
            
            if(!setIdQuota.isEmpty()){
                listOli = [SELECT Id, Quantity, LAT_MX_Quota__c FROM OpportunityLineItem WHERE LAT_MX_Quota__c IN: setIdQuota AND Remover__c = false];              
            }
                
            for(LAT_MX_QTA_Quota__c quota: triggerNew){
                if(oldMap.containsKey(quota.Id) && quota.LAT_MX_Quota__c != oldMap.get(quota.Id).LAT_MX_Quota__c){
                    quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c;
                }
            }
             
            Map<String,Decimal> mapQuotaIdQuantity = new Map<String,Decimal>();
            
            if(!listOli.isEmpty()){
                system.debug('ENTRO');
                for(OpportunityLineItem oli: listOli){
                    if(!mapQuotaIdQuantity.containsKey(oli.LAT_MX_Quota__c)){
                        mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, oli.Quantity);
                    }else{
                        Decimal Quantity = mapQuotaIdQuantity.get(oli.LAT_MX_Quota__c) + oli.Quantity;
                        mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, Quantity);
                    }
                }
                    
                for(LAT_MX_QTA_Quota__c quota: triggerNew){
                    if(mapQuotaIdQuantity.containsKey(quota.Id)){
                        quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c - mapQuotaIdQuantity.get(quota.Id);
                    }
                }
            }
        }
        //MIGRATED 04/11/2016
        else {
            Set<String> setIdQuota = new Set<String>();
            
            for(LAT_MX_QTA_Quota__c quota: triggerNew){
                if(oldMap.containsKey(quota.Id) && quota.LAT_MX_Quota__c != oldMap.get(quota.Id).LAT_MX_Quota__c){
                    setIdQuota.add(quota.Id);
                }
            }
            
            List<LAT_OpportunityLineItem__c> listOli = new List<LAT_OpportunityLineItem__c>();
            
            if(!setIdQuota.isEmpty()){
                listOli = [SELECT Id, LAT_Quantity__c, LAT_MX_Quota__c FROM LAT_OpportunityLineItem__c WHERE LAT_MX_Quota__c IN: setIdQuota AND LAT_Remover__c = false];              
            }
                
            for(LAT_MX_QTA_Quota__c quota: triggerNew){
                if(oldMap.containsKey(quota.Id) && quota.LAT_MX_Quota__c != oldMap.get(quota.Id).LAT_MX_Quota__c){
                    quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c;
                }
            }
             
            Map<String,Decimal> mapQuotaIdQuantity = new Map<String,Decimal>();
            
            if(!listOli.isEmpty()){
                system.debug('ENTRO');
                for(LAT_OpportunityLineItem__c oli: listOli){
                    if(!mapQuotaIdQuantity.containsKey(oli.LAT_MX_Quota__c)){
                        mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, oli.LAT_Quantity__c);
                    }else{
                        Decimal Quantity = mapQuotaIdQuantity.get(oli.LAT_MX_Quota__c) + oli.LAT_Quantity__c;
                        mapQuotaIdQuantity.put(oli.LAT_MX_Quota__c, Quantity);
                    }
                }
                    
                for(LAT_MX_QTA_Quota__c quota: triggerNew){
                    if(mapQuotaIdQuantity.containsKey(quota.Id)){
                        quota.LAT_MX_QuotaBalance__c = quota.LAT_MX_Quota__c - mapQuotaIdQuantity.get(quota.Id);
                    }
                }
            }                        
        }

    }
    
    /*****************************************************************************************************************
    * Nombre del metodo: validatesVigence
    * Descripcion: Metodo que valida las vigencias para que 2 cuotas para un mismo producto no puedan estar dentro del mismo periodo
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 11/12/2013
    * Modo: before insert, before update
    ******************************************************************************************************************/
    
    public static void validatesVigence(List<LAT_MX_QTA_Quota__c> triggerNew){      
        if(!Utils.wasMigrationDone('12')) {  
            Set<String> setProducts = new Set<String>();
            Set<String> setAccounts = new Set<String>();
            
            for(LAT_MX_QTA_Quota__c quota: triggerNew){
                setProducts.add(quota.LAT_MX_Product__c);
                setAccounts.add(quota.LAT_MX_Client__c);
            }
            
            List<LAT_MX_QTA_Quota__c> listQuotas = [SELECT Id, LAT_MX_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c FROM LAT_MX_QTA_Quota__c WHERE LAT_MX_Product__c IN: setProducts AND LAT_MX_Client__c IN: setAccounts AND Id NOT IN: triggerNew];
            
            Map<String,List<LAT_MX_QTA_Quota__c>> mapIdProductQuota = new Map<String,List<LAT_MX_QTA_Quota__c>>();
            
            system.debug('ESTA VACIA LA LISTA? ' + listQuotas.isEmpty());
            
            if(!listQuotas.isEmpty()){      
                for(LAT_MX_QTA_Quota__c quota: listQuotas){
                    if(!mapIdProductQuota.containsKey(quota.LAT_MX_Client__c + '-' + quota.LAT_MX_Product__c)){
                        mapIdProductQuota.put(quota.LAT_MX_Client__c + '-' + quota.LAT_MX_Product__c,new List<LAT_MX_QTA_Quota__c>{quota});
                    }else{
                        mapIdProductQuota.get(quota.LAT_MX_Client__c + '-' + quota.LAT_MX_Product__c).add(quota);
                    }
                }
                for(LAT_MX_QTA_Quota__c quota: triggerNew){
                    if(mapIdProductQuota.containsKey(quota.LAT_MX_Client__c + '-' + quota.LAT_MX_Product__c)){
                        for(LAT_MX_QTA_Quota__c quotaExistente: mapIdProductQuota.get(quota.LAT_MX_Client__c + '-' + quota.LAT_MX_Product__c)){
                            if((quota.LAT_MX_ValiditySince__c >= quotaExistente.LAT_MX_ValiditySince__c && quota.LAT_MX_ValiditySince__c <= quotaExistente.LAT_MX_ValidityUntil__c) ||
                               (quota.LAT_MX_ValidityUntil__c <= quotaExistente.LAT_MX_ValidityUntil__c && quota.LAT_MX_ValidityUntil__c >= quotaExistente.LAT_MX_ValiditySince__c)){
                                 quota.addError(label.LAT_MX_AP01_00019);
                                 //LAT_MX_AP01_00019: El periodo ingresado coincide con una cuota existente para el cliente y producto seleccionado.
                            }
                        }
                    }
                }
            }
        }
        //MIGRATED 03/11/2016
        else {
            Set<String> setProducts = new Set<String>();
            Set<String> setAccounts = new Set<String>();
            Date dateSince          = null;
            for(LAT_MX_QTA_Quota__c quota: triggerNew){
                dateSince   =   quota.LAT_MX_ValiditySince__c;
                setProducts.add(quota.LAT_Product__c);
                setAccounts.add(quota.LAT_MX_Client__c);
            }
            
            List<LAT_MX_QTA_Quota__c> listQuotas = [SELECT Id, LAT_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c FROM LAT_MX_QTA_Quota__c 
                                                    WHERE LAT_Product__c IN: setProducts AND LAT_MX_Client__c IN: setAccounts AND Id NOT IN: triggerNew
                                                            AND LAT_MX_ValidityUntil__c >= :dateSince];
            
            Map<String,List<LAT_MX_QTA_Quota__c>> mapIdProductQuota = new Map<String,List<LAT_MX_QTA_Quota__c>>();
            
            system.debug('ESTA VACIA LA LISTA? ' + listQuotas.isEmpty());
            
            if(!listQuotas.isEmpty()){      
                for(LAT_MX_QTA_Quota__c quota: listQuotas){
                    if(!mapIdProductQuota.containsKey(quota.LAT_MX_Client__c + '-' + quota.LAT_Product__c)){
                        mapIdProductQuota.put(quota.LAT_MX_Client__c + '-' + quota.LAT_Product__c,new List<LAT_MX_QTA_Quota__c>{quota});
                    }else{
                        mapIdProductQuota.get(quota.LAT_MX_Client__c + '-' + quota.LAT_Product__c).add(quota);
                    }
                }
                for(LAT_MX_QTA_Quota__c quota: triggerNew){
                    if(mapIdProductQuota.containsKey(quota.LAT_MX_Client__c + '-' + quota.LAT_Product__c)){
                        for(LAT_MX_QTA_Quota__c quotaExistente: mapIdProductQuota.get(quota.LAT_MX_Client__c + '-' + quota.LAT_Product__c)){
                            if((quota.LAT_MX_ValiditySince__c >= quotaExistente.LAT_MX_ValiditySince__c && quota.LAT_MX_ValiditySince__c <= quotaExistente.LAT_MX_ValidityUntil__c) ||
                               (quota.LAT_MX_ValidityUntil__c <= quotaExistente.LAT_MX_ValidityUntil__c && quota.LAT_MX_ValidityUntil__c >= quotaExistente.LAT_MX_ValiditySince__c)){
                                 quota.addError(label.LAT_MX_AP01_00019);
                                 //LAT_MX_AP01_00019: El periodo ingresado coincide con una cuota existente para el cliente y producto seleccionado.
                            }
                        }
                    }
                }
            }            
        }
    }
}
/* ---------------------------------------------------------------------------
* Filename: ASI_HK_CRM_SalesOrderItemStockRelease
* Author:   Kelvin Chan (Introv)
* Purpose:  Perform check and updates on SO and SO Line base on their Stock Release Status
*
* Copyright 2018 Introv Limited. All rights reserved.
* Customer confidential. Do not distribute.
*
* History
* -----------------------------------------------------------------------------
* 2018-07-27 Kelvin Chan           Create
* 2018-09-21 Wilken Lee            [WL 1.0] Only allow Sales Admin to edit Stock Release info 
*/
public without sharing class ASI_HK_CRM_SalesOrderItemStockRelease extends ASI_HK_CRM_TriggerAbstract {
    public Boolean isSalesAdmin;
	
    public ASI_HK_CRM_SalesOrderItemStockRelease() {
        super('ASI_HK_CRM_SalesOrderItemStockRelease');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) 
    {
        System.debug('ASI_HK_CRM_SalesOrderItemStockRelease | executeTriggerAction | Start');   
        
        // added before trigger Introv Kelvin 2018-07-23 
        List<ASI_HK_CRM_Sales_Order_Item__c> soDetails = (List<ASI_HK_CRM_Sales_Order_Item__c>)sObjList;
        
        List<ASI_HK_CRM_Sales_Order_Item__c> soNeedStockReserve = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        List<ASI_HK_CRM_Sales_Order_Item__c> soRemoveStockReserve = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        Map<Id, Id> mapSOLStockReleased = new Map<Id, Id>();
        
		/*[WL 1.0] BEGIN*/
		isSalesAdmin = false;
		List<PermissionSetAssignment> pSetAssignList = [select AssigneeId, PermissionSetId from PermissionSetAssignment 
														where PermissionSetId in (select Id from PermissionSet where Name = 'ASI_CRM_HK_SA_Add_on') and AssigneeId = :UserInfo.getUserId()];
		if (pSetAssignList.size() > 0)
			isSalesAdmin = true;
			
		system.debug('isSalesAdmin: ' + isSalesAdmin);	
		/*[WL 1.0] END*/
		
        for(ASI_HK_CRM_Sales_Order_Item__c soline : soDetails){
            if((soline.ASI_HK_CRM_Stock_Reserve_Status__c == null || soline.ASI_HK_CRM_Stock_Reserve_Status__c == 'Not Required')
               && (tAction == TriggerAction.BEFORE_INSERT || (tAction == TriggerAction.BEFORE_UPDATE && ((ASI_HK_CRM_Sales_Order_Item__c)oldMap.get(soline.Id)).ASI_HK_CRM_Reserve_Stock_No__c == NULL))
               && soline.ASI_HK_CRM_Reserve_Stock_No__c != NULL){
				
				/*[WL 1.0] BEGIN*/
				if (!isSalesAdmin){
					soline.addError('Please contact Sales Admin for Stock Release.');
				}
				else {
					soNeedStockReserve.add(soline);
				}
				/*[WL 1.0] END*/
		    }
			else if(tAction == TriggerAction.BEFORE_UPDATE && soline.ASI_HK_CRM_Stock_Reserve_Status__c == 'Open'
                        && soline.ASI_HK_CRM_Reserve_Stock_No__c == NULL && ((ASI_HK_CRM_Sales_Order_Item__c)oldMap.get(soline.Id)).ASI_HK_CRM_Reserve_Stock_No__c != NULL){
                            soRemoveStockReserve.add(soline);
                        }else if(tAction == TriggerAction.BEFORE_UPDATE &&
                                 ((ASI_HK_CRM_Sales_Order_Item__c)oldMap.get(soline.Id)).ASI_HK_CRM_Stock_Reserve_Status__c == 'Open'
                                 && soline.ASI_HK_CRM_Stock_Reserve_Status__c != ((ASI_HK_CRM_Sales_Order_Item__c)oldMap.get(soline.Id)).ASI_HK_CRM_Stock_Reserve_Status__c
                                 && (soline.ASI_HK_CRM_Stock_Reserve_Status__c == 'Stock Released' || soline.ASI_HK_CRM_Stock_Reserve_Status__c == 'Insufficient Stock' 
                                     || soline.ASI_HK_CRM_Stock_Reserve_Status__c == 'SK Order Number Not Found' || soline.ASI_HK_CRM_Stock_Reserve_Status__c == 'SKU Not Found')){
                                         mapSOLStockReleased.put(soline.Id, soline.ASI_HK_CRM_Sales_Order__c);
                                     }
        }
        
        System.debug('ASI_HK_CRM_SalesOrderItemStockRelease | executeTriggerAction | soNeedStockReserve.size() : ' + soNeedStockReserve.size());  
        if(soNeedStockReserve.size() > 0){
            updateStatusToOpen(soNeedStockReserve);
        }
        
        System.debug('ASI_HK_CRM_SalesOrderItemStockRelease | executeTriggerAction | soRemoveStockReserve.size() : ' + soRemoveStockReserve.size());  
        if(soRemoveStockReserve.size() > 0){
            updateStatusToNotRequired(soRemoveStockReserve);
        }
        
        System.debug('ASI_HK_CRM_SalesOrderItemStockRelease | executeTriggerAction | mapSOLStockReleased.size() : ' + mapSOLStockReleased.size());  
        if(mapSOLStockReleased.size() > 0){
            checkAllSOLineReleasedStock(mapSOLStockReleased);
        }
        
        System.debug('ASI_HK_CRM_SalesOrderItemStockRelease | executeTriggerAction | End');  
    }
    
    //To update the SO Line's Stock Reserve Status after SK Order Number was given
    private void updateStatusToOpen(List<ASI_HK_CRM_Sales_Order_Item__c> listSOLine){
        for(ASI_HK_CRM_Sales_Order_Item__c soline : listSOLine){
            soline.ASI_HK_CRM_Stock_Reserve_Status__c = 'Open';
        }
    }
    
    //To update the SO Line's Stock Reserve Status to Not Required after SK Order Number was removed
    private void updateStatusToNotRequired(List<ASI_HK_CRM_Sales_Order_Item__c> listSOLine){
        for(ASI_HK_CRM_Sales_Order_Item__c soline : listSOLine){
            soline.ASI_HK_CRM_Stock_Reserve_Status__c = 'Not Required';
        }
    }
    
    //After SO Line has been processed with Stock Release, check if the Header Status can be updated for being interfaced to JDE after all SO Line has been updated
    private void checkAllSOLineReleasedStock(Map<Id, Id> mapSOL){
        Set<Id> setSOHNotReady = new Set<Id>();
        Map<Id, ASI_HK_CRM_Sales_Order__c> mapSOUpdate = new Map<Id, ASI_HK_CRM_Sales_Order__c>();
        for(ASI_HK_CRM_Sales_Order_Item__c listSOLs : [SELECT ASI_HK_CRM_Sales_Order__c From ASI_HK_CRM_Sales_Order_Item__c 
                                                       WHERE ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Order_Status_Name__c = 'Interfaced to Stock Reserve' 
                                                       AND Id NOT IN :mapSOL.keySet() AND ASI_HK_CRM_Sales_Order__c = :mapSOL.values() AND ASI_HK_CRM_Stock_Reserve_Status__c IN ('Open')]){
                                                           setSOHNotReady.add(listSOLs.ASI_HK_CRM_Sales_Order__c);
                                                           System.debug('ASI_HK_CRM_SalesOrderItemStockRelease | checkAllSOLineReleasedStock | setSOHNotReady Add : ' + listSOLs.ASI_HK_CRM_Sales_Order__c);
                                                       }
        
        for(Id idSOH : mapSOL.values()){
            if(!setSOHNotReady.contains(idSOH) && !mapSOUpdate.containsKey(idSOH)){
                System.debug('ASI_HK_CRM_SalesOrderItemStockRelease | checkAllSOLineReleasedStock | setSOHNotReady not contains : ' + idSOH);
                mapSOUpdate.put(idSOH, new ASI_HK_CRM_Sales_Order__c(Id = idSOH, ASI_HK_CRM_Order_Status_Name__c = 'Interfaced to JDE'));
            }
        }
        
        if(mapSOUpdate.size() > 0){
            update mapSOUpdate.values();
        }
    }
}
/*
*    Description    :    Apex helper class that gets invoked through After Update event
*                        on EUR_CRM_Sales_Order__c
*                        The class essentially considers only ZA Sales Order records
*                        and make the external web service callouts when the given condition is met
*
*    Version    Author        Date            Description
*    1.0        Sid           12/30/2015      Initial Draft
*/

public with sharing class EUR_CRM_ZA_SalesOrderCallout extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_ZA_SalesOrderCallout() {
        super('EUR_CRM_ZA_SalesOrderCallout');
    }

    private Set<String> validRecordTypes = new Set<String>{
      'EUR_ZA_Direct_Sales_Order',
      'EUR_ZA_Free_Goods_Order'    
    };
    
    //Method will execute on AFTER_UPDATE event of EUR_CRM_Sales_Order__c
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        //Get record type list for SalesOrder
        List<Recordtype> salesOrderRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Sales_Order__c');
        Map<Id,Recordtype> salesOrderRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : salesOrderRecordTypes ){
           salesOrderRecordTypesMap.put(rt.id,rt);
        }
        
        List<EUR_CRM_Sales_Order__c> salesOrderList = (List<EUR_CRM_Sales_Order__c>) sObjList;
        List<EUR_CRM_Sales_Order__c> validSalesOrderList = new List<EUR_CRM_Sales_Order__c>();
               
        //Get all ZA SalesOrder Records
        for(EUR_CRM_Sales_Order__c so : salesOrderList) {
            String salesOrdeRTDevName = salesOrderRecordTypesMap.get(so.recordtypeid).developername;
            if(validRecordTypes.contains(salesOrdeRTDevName )){
                validSalesOrderList.add(so);
            }
        }
        
        System.debug('validSalesOrder ' + validSalesOrderList);
        if(!validSalesOrderList.isEmpty()) {
            for(EUR_CRM_Sales_Order__c objSo : validSalesOrderList){
                if(objSo.EUR_CRM_No_of_Order_Items_Match_Header__c == true && objSo.EUR_CRM_Order_Status__c == 'In Process' && objSo.EUR_CRM_Endpoint_Sync_Status__c == null){
                    
                    if(salesOrderRecordTypesMap.get(objSo.recordtypeid).developername == 'EUR_ZA_Direct_Sales_Order'){
                        System.debug('Perform Web Service Callout on Direct Sales Order');
                        System.enqueueJob(new EUR_CRM_ZA_SoCalloutQueueable(objSo.Id));
                    }
                    else if(salesOrderRecordTypesMap.get(objSo.recordtypeid).developername == 'EUR_ZA_Free_Goods_Order' && objSo.EUR_CRM_Approval_Status__c == 'Approved'){
                        System.debug('Perform Web Service Callout on Free Goods Order');
                        System.enqueueJob(new EUR_CRM_ZA_SoCalloutQueueable(objSo.Id));
                    }
                }
            }
        }
    }
}
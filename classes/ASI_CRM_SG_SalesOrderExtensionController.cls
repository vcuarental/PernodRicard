public without sharing class ASI_CRM_SG_SalesOrderExtensionController {
    id reqID;
    List<ASI_KOR_Sales_Order_Transaction__c> reqLineList = new List<ASI_KOR_Sales_Order_Transaction__c>();
    ASI_KOR_Sales_Order_Request__c request = new ASI_KOR_Sales_Order_Request__c();

    public ASI_CRM_SG_SalesOrderExtensionController(apexpages.standardController sc) {      
        reqLineList = [select id, Name,ASI_CRM_Total_Request_Quantity_Bottle__c, ASI_CRM_SG_SKU__c, ASI_CRM_SG_SKU__r.Name, ASI_CRM_SG_SKU__r.ASI_HK_CRM_Packaging_Size__c, 
            ASI_CRM_SG_Request_Quantity_Bottle__c, ASI_CRM_SG_Request_Quantity_Carton__c, ASI_CRM_SG_FOC__c, ASI_CRM_Stock_Availability__c, 
            ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c from ASI_KOR_Sales_Order_Transaction__c where ASI_KOR_Sales_Order_Request__c = :sc.getId()];
        
        reqID = sc.getId();
        request = [select id, recordType.DeveloperName from ASI_KOR_Sales_Order_Request__c where id = :sc.getId()];
    }
    
     public pageReference checkInventory() {
        Set<String> skuSet = new Set<String>();
        Set<Id> skuIdSet = new Set<Id>();
        
        if (reqLineList.size() > 0){
            for (ASI_KOR_Sales_Order_Transaction__c reqLine:reqLineList){
                skuSet.add(reqLine.ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c);
                skuIdSet.add(reqLine.ASI_CRM_SG_SKU__c);
            }
            
            //20170411 Wilken CHM114615809: Add criteria for available qty checking, as some market share same branch plant Qty
            Set<Id> requestItemRecordTypeId = new Set<Id>();
            if (request.recordType.DeveloperName.contains('ASI_CRM_SG_LA') ||
                    request.recordType.DeveloperName.contains('ASI_CRM_SG_VIDF') ||
                        request.recordType.DeveloperName.contains('ASI_CRM_SG_MM') ||
                            request.recordType.DeveloperName.contains('ASI_CRM_SG_MY') ||
                                request.recordType.DeveloperName.contains('ASI_CRM_SG_CA')
                ){
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_LA'));
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_VIDF'));
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_MM'));
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_MY'));
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_CA'));
            }
            else if (request.recordType.DeveloperName.contains('ASI_CRM_SG_PH')){
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_PH'));
            }
            else if (request.recordType.DeveloperName.contains('ASI_CRM_SG_VI')){
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_VI'));
            }
            else if (request.recordType.DeveloperName.contains('ASI_CRM_SG_IN')){
                requestItemRecordTypeId.add(Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_SG_IN'));
            }

            system.debug('Request Item Record Type ID Aggregated Set:' + requestItemRecordTypeId);

            Map<id,ASI_MFM_SKU_Code__c> skuMap = new Map<id,ASI_MFM_SKU_Code__c>([select id, Name, ASI_HK_CRM_Available_Quantity__c, ASI_HK_CRM_Packaging_Size__c 
                    from ASI_MFM_SKU_Code__c where id in :skuIdSet]);

            //20170411 Wilken CHM114615809: Aggregate in-progress request's on-hold quantity based on branch/plant
            List<ASI_KOR_Sales_Order_Transaction__c> otherReqLineList = new List<ASI_KOR_Sales_Order_Transaction__c>([select id, Name, ASI_CRM_Stock_Availability__c, ASI_CRM_SG_SKU__c, ASI_CRM_Total_Request_Quantity_Bottle__c, 
                ASI_KOR_Sales_Order_Request__r.ASI_KOR_JDE_Sales_Order_Number__c , ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c 
                from ASI_KOR_Sales_Order_Transaction__c 
                    where ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c in :skuSet and recordTypeId = :requestItemRecordTypeId and Id != :reqLineList]);
            
            //Start checking available quantity for each request line
            for (ASI_KOR_Sales_Order_Transaction__c reqLine:reqLineList){
                Decimal onHoldQuantity = 0;
                System.debug('Current Request Line Name: ' + reqLine.Name);
                
                for (ASI_KOR_Sales_Order_Transaction__c otherReqLine:otherReqLineList){
                    System.debug('Other Req Line: ' + otherReqLine.Name + ' Other SKU: ' + otherReqLine.ASI_CRM_SG_SKU__c);
                    if (otherReqLine.id != reqLine.id && otherReqLine.ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c == reqLine.ASI_CRM_SG_SKU__r.ASI_MFM_SKU_Code__c 
                        && requestItemRecordTypeId.contains(otherReqLine.recordTypeId)
                        && otherReqLine.ASI_KOR_Sales_Order_Request__r.ASI_KOR_JDE_Sales_Order_Number__c == null
                            && otherReqLine.ASI_CRM_Stock_Availability__c == 'YES'){
                        System.debug('Other Line SKU: ' + otherReqLine.ASI_CRM_SG_SKU__c);
                        onHoldQuantity += otherReqLine.ASI_CRM_Total_Request_Quantity_Bottle__c;
                    }
                }
                
                System.debug('Enquire Ava. Qty: SKU Name: ' + reqLine.ASI_CRM_SG_SKU__r.Name + ' Total Request Bottle: ' + reqLine.ASI_CRM_Total_Request_Quantity_Bottle__c + ' Availability: ' + skuMap.get(reqLine.ASI_CRM_SG_SKU__c).ASI_HK_CRM_Available_Quantity__c + ' Other On Hold Qty: ' + onHoldQuantity);
                if (reqLine.ASI_CRM_Total_Request_Quantity_Bottle__c + onHoldQuantity <= skuMap.get(reqLine.ASI_CRM_SG_SKU__c).ASI_HK_CRM_Available_Quantity__c)
                    reqLine.ASI_CRM_Stock_Availability__c = 'YES';
                else 
                    reqLine.ASI_CRM_Stock_Availability__c = 'NO';
            }
            
            update reqLineList;
        }
        
        return new pageReference('/' + reqID);
    }
    
    public pageReference notifyOperation(){
        ASI_KOR_Sales_Order_Request__c req = [select id from ASI_KOR_Sales_Order_Request__c where id = :reqID];
        
        req.ASI_CRM_Submit_to_PRS__c = true;
        
        update req;
		
        return new pageReference('/' + reqID);
    }
}
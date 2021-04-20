public class ASI_CRM_SG_FGSubmitForApp_ctrl {
    @AuraEnabled
    public static String getRecord(String recordId){
        try{
       ASI_FOC_Free_Goods_Request__c freeGoods = [Select Id, ASI_FOC_Request_Status__c,ASI_CRM_Contract__c, recordType.developerName,ASI_CRM_SG_Total_Amount__c,ASI_CRM_System_Remark__c from ASI_FOC_Free_Goods_Request__c where Id = :recordId limit 1];
        List<ASI_FOC_Request_Item__c> tempRequestItemsList = ((List<ASI_FOC_Request_Item__c>)queryAll(recordId, 'ASI_FOC_Request_Item__c', 'ASI_FOC_Request_Order__c', '', ', ASI_FOC_SKU__r.name '));
    	Map<ID, Decimal> skuCommittedQty = new Map<ID, Decimal>();
		Set<ID> skuIDs = new Set<ID>();
        for(ASI_FOC_Request_Item__c requestItemW : tempRequestItemsList) {
                if(requestItemW.ASI_FOC_SKU__c != null) {
                    skuIDs.add(requestItemW.ASI_FOC_SKU__c);
                }
       }
       String errorMessage = '';
       List<AggregateResult> allRequestItems = [SELECT ASI_FOC_SKU__c, SUM(ASI_FOC_Request_Quantity_Bottle__c)CommQtySum FROM ASI_FOC_Request_Item__c
                                                            WHERE ASI_FOC_SKU__c IN : skuIDs AND recordtype.developername = 'ASI_SG_CRM_Request_Items'
                                                            AND ASI_FOC_Request_Order__r.recordtype.developername = : freeGoods.recordtype.developername 
                                                            AND (ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c = 'Submitted' OR ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c = 'Approved') 
                                                            AND ASI_FOC_Request_Order__r.ASI_CRM_Sync_to_JDE__c = false
                                                            GROUP BY ASI_FOC_SKU__c];
         for(AggregateResult result : allRequestItems){
                Decimal totalCommittedqty =  Integer.valueof((Decimal)result.get('CommQtySum'));
                ID sku = (ID)result.get('ASI_FOC_SKU__c');
                skuCommittedQty.put(sku, totalCommittedqty);
            }
         Decimal totalRequestQty = 0;
         for(ASI_FOC_Request_Item__c requestItem : tempRequestItemsList) {
                totalRequestQty += requestItem.ASI_FOC_Request_Quantity_Bottle__c != null ? requestItem.ASI_FOC_Request_Quantity_Bottle__c : 0;
                Decimal availableQty = requestItem.ASI_CRM_SG_Available_Quantity__c != null ? requestItem.ASI_CRM_SG_Available_Quantity__c : 0;
                Decimal totalCommittedqty = (skuCommittedQty.get(requestItem.ASI_FOC_SKU__c) != null ? skuCommittedQty.get(requestItem.ASI_FOC_SKU__c) : 0) + (requestItem.ASI_FOC_Request_Quantity_Bottle__c != null ? requestItem.ASI_FOC_Request_Quantity_Bottle__c : 0);

            }
        if(freeGoods.recordtype.developername  == 'ASI_CRM_SG_FOC' && (freeGoods.ASI_CRM_SG_Total_Amount__c == 0 || tempRequestItemsList.size() == 0)) {
                errorMessage += ' Total amount must be greater than 0 for approval. \n ';
            }
         if(freeGoods.recordtype.developername  == 'ASI_CRM_SG_FOC' && freeGoods.ASI_CRM_System_Remark__c != 'SG Promotion' && freeGoods.ASI_CRM_Contract__c == null) {
                errorMessage += ' Please input Contract. \n ';
            }
          if(freeGoods.recordtype.developername  == 'ASI_CRM_SG_POSM' && (tempRequestItemsList.size() == 0 || totalRequestQty == 0)) {
                errorMessage += ' Total request quantity must be greater than 0 for approval. \n ';
            }
            
            if(freeGoods.ASI_FOC_Request_Status__c != 'Draft' && freeGoods.ASI_FOC_Request_Status__c != 'Rejected') {
                errorMessage = ' Free Gooods Request already submitted for approval or already approved. \n ';
            }
         if (errorMessage != '') {
                return errorMessage;
            } else {
                freeGoods.ASI_FOC_Sys_Submitted__c = true;
                update freeGoods;
                return 'Success';
            }
        }catch(Exception e){
                return e.getMessage() ;
        }
                                                      
    }
    
	private static List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraQuery, String extraFields) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += extraFields +' , recordtype.developername From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }
}
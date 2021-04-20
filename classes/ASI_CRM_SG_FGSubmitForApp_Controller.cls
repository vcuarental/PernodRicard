/*********************************************************************************
 * Name:ASI_CRM_SG_FGSubmitForApp_Controller
 * Description: Class to Validate Submit for approval
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/02/2015       Laputa: Conrad          Created
 * 2016-08-29       Laputa: Vincent         [VL 1.0] Update Sys_Submitted field as entry criteria of approval process
 * 2018-05-07       Laputa: Vincent         [VL 2.0] Check contract is populated
*********************************************************************************/

public with sharing class ASI_CRM_SG_FGSubmitForApp_Controller{

    public ASI_FOC_Free_Goods_Request__c freeGoods {get;set;}
	public static final String SGPROMOTIONREMARK = 'SG Promotion';

    public pageReference redirect(){
        Pagereference pageref;
        try {
        
            List<ASI_FOC_Request_Item__c> tempRequestItemsList = ((List<ASI_FOC_Request_Item__c>)queryAll(freeGoods.id, 'ASI_FOC_Request_Item__c', 'ASI_FOC_Request_Order__c', '', ', ASI_FOC_SKU__r.name '));
            
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
                /*if(totalCommittedqty > availableQty) {
                    errorMessage += 'Committed Quantity ' + totalCommittedqty + ' cannot be over than Available Quantity ' + availableQty + ' for SKU Code ' + requestItem.ASI_FOC_SKU__r.name + '.<br/> ';
                }*/
            }
            
            if(freeGoods.recordtype.developername  == 'ASI_CRM_SG_FOC' && (freeGoods.ASI_CRM_SG_Total_Amount__c == 0 || tempRequestItemsList.size() == 0)) {
                errorMessage += ' Total amount must be greater than 0 for approval.<br/> ';
            }
			
			/* [VL 2.0] BEGIN */
            if(freeGoods.recordtype.developername  == 'ASI_CRM_SG_FOC' && freeGoods.ASI_CRM_System_Remark__c != SGPROMOTIONREMARK && freeGoods.ASI_CRM_Contract__c == null) {
                errorMessage += ' Please input Contract.<br/> ';
            }
			/* [VL 2.0] END */
            
            if(freeGoods.recordtype.developername  == 'ASI_CRM_SG_POSM' && (tempRequestItemsList.size() == 0 || totalRequestQty == 0)) {
                errorMessage += ' Total request quantity must be greater than 0 for approval.<br/> ';
            }
            
            if(freeGoods.ASI_FOC_Request_Status__c != 'Draft' && freeGoods.ASI_FOC_Request_Status__c != 'Rejected') {
                errorMessage = ' Free Gooods Request already submitted for approval or already approved.<br/> ';
            }
            
            if (errorMessage != '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage + 'Click<a href="/' + freeGoods.Id +'" target="_parent">here</a>to go back to the record.'));
            } else {
                /* [VL 1.0] BEGIN */
                freeGoods.ASI_FOC_Sys_Submitted__c = true;
                update freeGoods;
                /* [VL 1.0] END */
                //pageRef = new pagereference('/p/process/Submit?retURL=%2F'+freeGoods.Id+'&id='+freeGoods.Id);
                pageRef = new pagereference('/apex/ASI_SubmitApprovalPage?id='+freeGoods.Id);
                pageRef.setRedirect(true);
            }
            
        } catch(exception e) {
            pageRef = null;   
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            return null;
        }
        
        return pageref;
    }

    public ASI_CRM_SG_FGSubmitForApp_Controller (ApexPages.StandardController stdController){
        
        ASI_FOC_Free_Goods_Request__c freeGoodsTemp = (ASI_FOC_Free_Goods_Request__c)stdController.getRecord();
        this.freeGoods = ((List<ASI_FOC_Free_Goods_Request__c>)queryAll(freeGoodsTemp.id, 'ASI_FOC_Free_Goods_Request__c', 'ID', '', '')).get(0);
    }
    
    private List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraQuery, String extraFields) {
    
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
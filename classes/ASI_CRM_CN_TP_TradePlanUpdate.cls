/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_TradePlanUpdate
 * Object: ASI_MFM_Plan__c
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-3-17
 * Modify History:
 * 2020-3-17        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_TradePlanUpdate {
    public String errorHeader {get; set;}
    public String tpHeader {get; set;}
    public List<String> tpHeaderList{get; set;}

    private static final String TPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan');
    private static final String BPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Budget_Plan');
    private static final String CNITEMGROUPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group');
    private static final String CNPLITEMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_CRM_CN_TP_Trade_Plan_Line_Item');
    
    public ASI_CRM_CN_TP_TradePlanUpdate() {
        ASI_CRM_CN_CustomSetting__c tpSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        tpHeaderList = tpSetting.ASI_CRM_CN_TP_Update_Header__c.split(',');
        tpHeader = tpSetting.ASI_CRM_CN_TP_Update_Header__c;
        // errorHeader = tpSetting.ASI_CRM_CN_TP_Table_Error_Header__c;
        
    }

    @RemoteAction
    public static Map<String, Object> checkUploadData(String input){
        Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
       Map<String, object> result = new Map<String, object>();
        
        String planLineItemId = (String)inputMap.get('recordId');
        List<ASI_MFM_Plan_Line_Item__c> planLineItemList = [SELECT Id FROM ASI_MFM_Plan_Line_Item__c WHERE Id = :planLineItemId];
        if (planLineItemList.isEmpty()) {
        	result.put('recordId', '');
        } else {
        	result.put('recordId', planLineItemList[0].Id);
        }
        return result;
    }

    @RemoteAction
    public static void saveData(String tpJson){
        System.debug(LoggingLevel.INFO, '*** tpJson: ' + tpJson);
        List<Object> tpObjList = (List<Object>)JSON.deserializeUntyped(tpJson);
        List<ASI_MFM_Plan_Line_Item__c> updateLineItems = new List<ASI_MFM_Plan_Line_Item__c>();
        for (Object obj : tpObjList) {
        	Map<String, Object> objMap = (Map<String, Object>)obj;
        	System.debug(LoggingLevel.INFO, '*** JSON.serialize(objMap): ' + JSON.serialize(objMap));
        	String recordId = (String)objMap.get('recordId');
        	String actualVol = (String)objMap.get('actualVol');
        	String thisProPaidAmt = (String)objMap.get('thisProPaidAmt');
        	String thisFixPaidAmt = (String)objMap.get('thisFixPaidAmt');
        	ASI_MFM_Plan_Line_Item__c lineItem = new ASI_MFM_Plan_Line_Item__c();
        	lineItem.Id = recordId;
        	lineItem.ASI_CRM_CN_TP_Actual_Qty__c = Decimal.valueOf(actualVol);
        	lineItem.ASI_CRM_CN_TP_Promotion_Payment_Amount__c = Decimal.valueOf(thisProPaidAmt);
        	lineItem.ASI_CRM_CN_TP_FixedCost_Payment_Amount__c = Decimal.valueOf(thisFixPaidAmt);
        	updateLineItems.add(lineItem);
        }

        if (!updateLineItems.isEmpty()) {
        	Database.update(updateLineItems, true);
        }
    }

   
}
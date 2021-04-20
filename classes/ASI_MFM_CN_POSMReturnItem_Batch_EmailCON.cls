/**************************************************************************************************
 * Name: ASI_MFM_CN_POSMReturnItem_Batch_EmailCON
 * 
 * Purpose: 
 * Requirement:POSM Rrtuen request Item Batch approval email
 * Author: LEO BLS 
 * Create Date: 2020-9-18
 * Modify History:
***************************************************************************************************/

public with sharing class ASI_MFM_CN_POSMReturnItem_Batch_EmailCON {
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public List<ASI_MFM_POSM_Return_Request_Item__c> itemList {get;set;}
    public ASI_MFM_POSM_Return_Request_Item__c itemHeader {get;set;}

    public static Final Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_Return_Batch_Approval');
    public static Final Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Return_Request_Item_Batch_Approval');

    public boolean init(){
        {
        	if (currentHeaderID == null) {
        		ASI_MFM_POSM_Return_Request_Item__c item = [SELECT Id FROM ASI_MFM_POSM_Return_Request_Item__c WHERE RecordTypeId =: ITEM_APPROVAL_ID Limit 1];
        		currentHeaderID = item.Id;
        	}
            itemHeader = new ASI_MFM_POSM_Return_Request_Item__c();
            itemHeader = [SELECT Name            		
            			, ASI_MFM_Owner__r.Name 
                        FROM ASI_MFM_POSM_Return_Request_Item__c 
                        WHERE Id =: currentHeaderID];

            itemList = new List<ASI_MFM_POSM_Return_Request_Item__c>();
            itemList = [SELECT Name
                        , ASI_MFM_Request_Order__r.Name
                        , ASI_MFM_SKU__r.Name
                        , ASI_MFM_SKU_Description__c
                        , ASI_MFM_SKU_Chinese_Description__c
                        , ASI_MFM_QTY_Issued__c
                        , ASI_MFM_VAS__c
                        FROM ASI_MFM_POSM_Return_Request_Item__c 
                        WHERE ASI_MFM_POSM_Return_Reques_Approval_Item__c = :currentHeaderID
                        Order By Name];

            return true;
        }
    }
}
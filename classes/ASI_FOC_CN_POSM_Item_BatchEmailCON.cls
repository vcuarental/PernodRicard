/**************************************************************************************************
 * Name: ASI_FOC_CN_POSM_Item_BatchEmailCON
 * 
 * Purpose: 
 * Requirement:POSM request Item Batch approval email
 * Author: LEO By BLS 
 * Create Date: 2020-9
 * Modify History:
***************************************************************************************************/

public with sharing class ASI_FOC_CN_POSM_Item_BatchEmailCON {
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public List<ASI_FOC_Request_Item__c> itemList {get;set;}
    public ASI_FOC_Request_Item__c itemHeader {get;set;}

    public static Final Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_CN_POSM_Batch_Approval');
    public static Final Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_CRM_CN_POSM_Request_Item_Batch_Approval');

    public boolean init(){
        {
        	if (currentHeaderID == null) {
        		ASI_FOC_Request_Item__c item = [SELECT Id FROM ASI_FOC_Request_Item__c WHERE RecordTypeId =: ITEM_APPROVAL_ID Limit 1];
        		currentHeaderID = item.Id;
        	}
            itemHeader = new ASI_FOC_Request_Item__c();
            itemHeader = [SELECT Name            		
                        FROM ASI_FOC_Request_Item__c 
                        WHERE Id =: currentHeaderID];

            itemList = new List<ASI_FOC_Request_Item__c>();
            itemList = [SELECT Name
                        , ASI_FOC_Request_Order__r.Name
                        , toLabel(ASI_FOC_Request_Order__r.ASI_MFM_Request_Category__c)
                        , ASI_FOC_Request_Order__r.ASI_MFM_Request_Category_Recipient__c
                        , ASI_FOC_Request_Order__r.ASI_MFM_DetailAddress__c
                        , ASI_FOC_Request_Order__r.ASI_FOC_Receiptor_Name__c
                        , ASI_FOC_Reason__c
                        , ASI_FOC_SKU__r.Name
                        , ASI_FOC_Packing_Description__c
                        , ASI_FOC_SKU_Description__c
                        , ASI_FOC_Quantity_Available_PC__c
                        , ASI_FOC_Original_Request_Quantity_PC_BT__c
                        , ASI_MFM_Mail_Info__c
                        FROM ASI_FOC_Request_Item__c 
                        WHERE ASI_MFM_Request_Item_Approval__c = :currentHeaderID
                        Order By Name];

            return true;
        }
    }
}
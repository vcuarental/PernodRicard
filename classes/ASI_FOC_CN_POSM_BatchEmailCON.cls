/**************************************************************************************************
 * Name: ASI_FOC_CN_POSM_BatchEmailCON
 * 
 * Purpose: 
 * Requirement:POSM request Batch approval email
 * Author: LEO By BLS 
 * Create Date: 2020-9
 * Modify History:
***************************************************************************************************/
public without sharing class ASI_FOC_CN_POSM_BatchEmailCON {
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public List<ASI_FOC_Free_Goods_Request__c> ReturnRequestList {get;set;}
    public Integer size {get;set;}
    public ASI_FOC_Free_Goods_Request__c ReturnRequestHeader {get;set;}

    public static Final Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_CN_POSM_Batch_Approval');
    public static Final Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_CRM_CN_POSM_Request_Item_Batch_Approval');

    public boolean init(){
       

        if (currentHeaderID == null ) {
            ASI_FOC_Free_Goods_Request__c req = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId =: ORDER_APPROVAL_ID Limit 1];
            currentHeaderID = req.Id;
        }
        ReturnRequestHeader = new ASI_FOC_Free_Goods_Request__c();
        ReturnRequestHeader = [Select Id, Name, ASI_FOC_Approver_1__r.Name,Owner.Name
        						// , ASI_MFM_Batch_Request_Total__c,ASI_MFM_Batch_Request_Success_Total__c
                        FROM ASI_FOC_Free_Goods_Request__c
                        WHERE Id = :currentHeaderID];

        ReturnRequestList = new List<ASI_FOC_Free_Goods_Request__c>();
        ReturnRequestList = [SELECT Name
        			, ASI_FOC_POSM_Request_Approval__r.Name
                    , toLabel(ASI_MFM_Request_Category__c)
                    , ASI_FOC_To_Regional_Warehouse__r.Name
                    , ASI_CRM_Outlet__r.Name
                    , ASI_FOC_Receiptor_Name__c
                    , ASI_FOC_Receiptor_Mobile__c
                    FROM ASI_FOC_Free_Goods_Request__c 
                    Where   ASI_FOC_POSM_Request_Approval__c = :currentHeaderID
                    Order By Name];
        size =  ReturnRequestList.size();           
        return true;
       
    }

}
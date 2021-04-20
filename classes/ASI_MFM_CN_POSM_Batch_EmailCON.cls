/**************************************************************************************************
 * Name: ASI_MFM_CN_POSM_Batch_EmailCON
 * 
 * Purpose: 
 * Requirement:POSM Rrtuen request Batch approval email
 * Author: LEO BLS 
 * Create Date: 2020-9-18
 * Modify History:
***************************************************************************************************/
public without sharing class ASI_MFM_CN_POSM_Batch_EmailCON {
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public List<ASI_MFM_POSM_Return_Request__c> ReturnRequestList {get;set;}
    public Integer size {get;set;}
    public ASI_MFM_POSM_Return_Request__c ReturnRequestHeader {get;set;}
    public static Final Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_Return_Batch_Approval');
    public static Final Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Return_Request_Item_Batch_Approval');
    public boolean init(){
        {   

            if (currentHeaderID == null ) {
                ASI_MFM_POSM_Return_Request__c req = [SELECT Id FROM ASI_MFM_POSM_Return_Request__c WHERE RecordTypeId =: ORDER_APPROVAL_ID Limit 1];
                currentHeaderID = req.Id;
            }
            ReturnRequestHeader = new ASI_MFM_POSM_Return_Request__c();
            ReturnRequestHeader = [Select Id, Name, ASI_MFM_Approver_1__r.Name,Owner.Name,ASI_MFM_Batch_Request_Total__c,ASI_MFM_Batch_Request_Success_Total__c
                            FROM ASI_MFM_POSM_Return_Request__c
                            WHERE Id = :currentHeaderID];

            ReturnRequestList = new List<ASI_MFM_POSM_Return_Request__c>();
            ReturnRequestList = [SELECT Name
                        ,ASI_MFM_Return_Request_Date__c,ASI_MFM_Return_Request_Time__c
                        ,ASI_MFM_Return_Request_Contact__c,ASI_MFM_Recipient_Contact__c,ASI_MFM_Address__c
                        ,ASI_MFM_Consignee__c,ASI_MFM_Consignee_Contact__c,ASI_MFM_To_Address__c,ASI_MFM_Request_Delivery_Date__c
                        ,ASI_MFM_Other_Request__c,ASI_MFM_To_Warehouse__r.ASI_FOC_Warehouse_Code__c,ASI_MFM_To_Warehouse__r.Name
                        FROM ASI_MFM_POSM_Return_Request__c 
                        Where   ASI_MFM_POSM_Return_Request_Approval__c = :currentHeaderID
                        Order By Name];
            size =  ReturnRequestList.size();           
            return true;
        }
    }

}
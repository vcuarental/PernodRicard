public class ASI_CRM_SG_Submit_for_Approval_TBCN_Ctrl {
	@AuraEnabled
    public static String getRecord(Id recordId){
        try{
        ASI_KOR_Sales_Order_Request__c sor = [Select Id,ASI_CRM_SG_Order_Date__c,ASI_CRM_Return_Date__c,ASI_KOR_Order_Status__c from ASI_KOR_Sales_Order_Request__c where Id = :recordId];
        List<ASI_KOR_Sales_Order_Transaction__c> detailRecords = [Select Id from ASI_KOR_Sales_Order_Transaction__c where ASI_KOR_Sales_Order_Request__c = :recordId];
         if (detailRecords == null || detailRecords.size() <= 0) {
             return 'No TBCN Request lines! You cannot submit for approval';
         }
        Boolean hasAttachment = false;
        List<Attachment> attchList = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :recordId];
        if(attchList != null && attchList.size()>0){
          hasAttachment = true;  
        }else{
            List<ContentDocumentLink> cdList = [SELECT ContentDocumentId, LinkedEntityId, contentDocument.title  FROM ContentDocumentLink where LinkedEntityId = :recordId and LinkedEntity.Type='ASI_KOR_Sales_Order_Request__c'];
            if(cdList!= null && cdList.size()>0){
                hasAttachment = true;
            }
        }
        if (!hasAttachment){
        	return 'Please upload supporting document before submit for approval'	;
        }else if(sor.ASI_CRM_SG_Order_Date__c < date.today() || sor.ASI_CRM_Return_Date__c < date.today() || sor.ASI_CRM_Return_Date__c < sor.ASI_CRM_SG_Order_Date__c){
            return 'No back Order Date / Return Date is allowed';
        }else if(sor.ASI_KOR_Order_Status__c == 'Draft' || sor.ASI_KOR_Order_Status__c =='Rejected' || sor.ASI_KOR_Order_Status__c == 'New'){
            update new ASI_KOR_Sales_Order_Request__c(Id = recordId, ASI_CRM_Sys_Allow_Submit_Approval__c = true);
        	return 'Success';
        }else{
            return null;
        }
        }catch(Exception e){
            return e.getMessage();
        }
    }
}
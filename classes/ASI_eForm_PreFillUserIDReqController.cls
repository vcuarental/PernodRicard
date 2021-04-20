public class ASI_eForm_PreFillUserIDReqController {
  
    public ASI_eForm_PreFillUserIDReqController(ApexPages.StandardController controller) {
 
    } 
    
    public PageReference preFill(){ 
        String oId = sObjectType.ASI_eForm_User_ID_Request__c.getKeyPrefix();
        String urlString = '/'+ oId + '/e?nooverride=1&retURL=%2F' + oId + '%2Fo';
   
        User currentUser = [select id,Department,ASI_MFM_Country__c,CompanyName, managerId from User where id =: UserInfo.getUserId()];
        
        String recordTypeParam = apexpages.currentpage().getparameters().get('RecordType');
        
        RecordType recordType = [Select Name from RecordType Where Id=:recordTypeParam];
        
        System.debug('RecordType: ' + recordType);
        
        ASI_eForm_PreFillApproversHandler handler = new ASI_eForm_PreFillApproversHandler(recordType.Name,
        ASI_eForm_PreFillApproversHandler.USER_ID_REQUEST,currentUser);
        
        handler.processUserIdRequestApprovers();
        
        User approver = handler.approvers.get(ASI_eForm_PreFillApproversHandler.APPROVER);
        User previewApprover = handler.approvers.get(ASI_eForm_PreFillApproversHandler.PREVIEW_APPROVER);
        
        System.debug('XXX Approvers: ' + handler.approvers);
     
        if(approver != null){
            ASI_eForm_Prefill_Fields__c approverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('UIRApproverField');
            String approverField = approverFieldCS.Field_Value__c;
            urlString += '&'+ approverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(approver); 
        }
        
        if(previewApprover != null){
            ASI_eForm_Prefill_Fields__c previewApproverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('UIRPreviewApproverField');
            String previewApproverField = previewApproverFieldCS.Field_Value__c;
            urlString += '&'+ previewApproverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(previewApprover); 
        }        
                      
        urlString += '&RecordType=' + recordTypeParam; 
        
        return new pageReference(urlString);
    }

}
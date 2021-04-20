public class ASI_eForm_PreFillITProcSrvcReqController {
  
    public ASI_eForm_PreFillITProcSrvcReqController(ApexPages.StandardController controller) {
 
    } 
    
    public PageReference preFill(){ 
        String oId = sObjectType.ASI_eForm_IT_Procurement_Service_Request__c.getKeyPrefix();
        String urlString = '/'+ oId + '/e?nooverride=1&retURL=%2F' + oId + '%2Fo';
   
        User currentUser = [select id,Department,ASI_MFM_Country__c,CompanyName, managerId from User where id =: UserInfo.getUserId()];
        
        String recordTypeParam = apexpages.currentpage().getparameters().get('RecordType');
        
        RecordType recordType = [Select Name from RecordType Where Id=:recordTypeParam];
        
        System.debug('RecordType: ' + recordType);
        
        ASI_eForm_PreFillApproversHandler handler = new ASI_eForm_PreFillApproversHandler(recordType.Name,
        ASI_eForm_PreFillApproversHandler.IT_PROC_SERVICE_REQUEST,currentUser);
        
        handler.processItProcServiceRequestApprovers();
        
        User approver = handler.approvers.get(ASI_eForm_PreFillApproversHandler.APPROVER);
        User previewApprover = handler.approvers.get(ASI_eForm_PreFillApproversHandler.PREVIEW_APPROVER);
        //User cio = handler.approvers.get(ASI_eForm_PreFillApproversHandler.CIO);
        User financeDirector = handler.approvers.get(ASI_eForm_PreFillApproversHandler.FINANCE_DIRECTOR);
        
        System.debug('XXX Approvers: ' + handler.approvers);
     
        if(approver != null){
            ASI_eForm_Prefill_Fields__c approverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITPSRApproverField');
            String approverField = approverFieldCS.Field_Value__c;
            urlString += '&'+ approverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(approver); 
        }
        
        if(previewApprover != null){
            ASI_eForm_Prefill_Fields__c previewApproverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITPSRPreviewApproverField');
            String previewApproverField = previewApproverFieldCS.Field_Value__c;
            urlString += '&'+ previewApproverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(previewApprover); 
        }
        
        /*
        if(cio != null){
           ASI_eForm_Prefill_Fields__c cioFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITPSRCIOField');
           String cioField = cioFieldCS.Field_Value__c;
           urlString += '&'+ cioField + '=' + cio.name; 
        }*/
        
        // [SH] 2019-01-10
        // set Finance Approver based on eform Route type
        if(financeDirector != null){
            ASI_eForm_Prefill_Fields__c financeDirectorFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITPSRFinanceDirectorField');
            String financeDirectorField = financeDirectorFieldCS.Field_Value__c;
            urlString += '&'+ financeDirectorField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(financeDirector); 
        }
                
        urlString += '&RecordType=' + recordTypeParam; 
        
        return new pageReference(urlString);
    }

}
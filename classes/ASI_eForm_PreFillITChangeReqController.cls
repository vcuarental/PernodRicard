public class ASI_eForm_PreFillITChangeReqController{
  
    public ASI_eForm_PreFillITChangeReqController(ApexPages.StandardController controller) {
 
    } 
    
    public PageReference preFill(){ 
        String oId = sObjectType.ASI_eForm_IT_Change_Request__c.getKeyPrefix();
        String urlString = '/'+ oId + '/e?nooverride=1&retURL=%2F' + oId + '%2Fo';
   
        User currentUser = [select id,Department,ASI_MFM_Country__c,CompanyName, managerId from User where id =: UserInfo.getUserId()];
        ASI_eForm_PreFillApproversHandler handler = new ASI_eForm_PreFillApproversHandler('',
        ASI_eForm_PreFillApproversHandler.IT_CHANGE_REQUEST ,currentUser);
        
        String recordTypeParam = apexpages.currentpage().getparameters().get('RecordType');
        
        handler.processItChangeRequestApprovers();
        
        User previewApprover = handler.approvers.get(ASI_eForm_PreFillApproversHandler.PREVIEW_APPROVER);
        User changeAuthorizer= handler.approvers.get(ASI_eForm_PreFillApproversHandler.CHANGE_AUTHORIZER);
        User highLevelAuthorizer= handler.approvers.get(ASI_eForm_PreFillApproversHandler.HIGH_LEVEL_AUTHORIZER);
        User furtherAuthorizer= handler.approvers.get(ASI_eForm_PreFillApproversHandler.FURTHER_AUTHORIZER);
        User CIO = handler.approvers.get(ASI_eForm_PreFillApproversHandler.CIO);
        
        ASI_eForm_Prefill_Fields__c previewApproverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITCRPreviewApproverField');
        String previewApproverField = previewApproverFieldCS.Field_Value__c;
        
        ASI_eForm_Prefill_Fields__c changeAuthorizerFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITCRChangeAuthorizerField');
        String changeAuthorizerField = changeAuthorizerFieldCS.Field_Value__c;
        
        ASI_eForm_Prefill_Fields__c highLevelAuthorizerFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITCRHighLevelAuthorizerField');
        String highLevelAuthorizerField = highLevelAuthorizerFieldCS.Field_Value__c;
        
        ASI_eForm_Prefill_Fields__c furtherAuthorizerFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITCRFurtherAuthorizerField');
        String furtherAuthorizerField = furtherAuthorizerFieldCS.Field_Value__c;
        
        ASI_eForm_Prefill_Fields__c CIOApproverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('ITCRCIOApproverField');
        String CIOApproverField = CIOApproverFieldCS.Field_Value__c;
        
        if(previewApprover != null){
            urlString += '&'+ previewApproverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(previewApprover); 
        }
        
        if(changeAuthorizer!= null){
            urlString += '&'+ changeAuthorizerField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(changeAuthorizer); 
        }
        if(highLevelAuthorizer!= null){
            urlString += '&'+ highLevelAuthorizerField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(highLevelAuthorizer); 
        }
        
        if(furtherAuthorizer!= null){
            urlString += '&'+ furtherAuthorizerField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(furtherAuthorizer); 
        }
        
        if(CIO!= null){
            urlString += '&'+ CIOApproverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(CIO); 
        }
        
        if (recordTypeParam != null && !''.equals(recordTypeParam.trim()))
        {
         urlString += '&RecordType=' + recordTypeParam; 
        }
        
        return new pageReference(urlString);
    }

}
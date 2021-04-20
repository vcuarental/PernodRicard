public class ASI_eForm_PreFillPreTripController{
  
    public ASI_eForm_PreFillPreTripController(ApexPages.StandardController controller) {
 
    } 
    
    public PageReference preFill(){ 
        String oId = sObjectType.ASI_eForm_Pre_Trip_Approval__c.getKeyPrefix();
        String urlString = '/'+ oId + '/e?nooverride=1&retURL=%2F' + oId + '%2Fo';
   
        User currentUser = [select id,Department,ASI_MFM_Country__c,CompanyName, managerId from User where id =: UserInfo.getUserId()];
        ASI_eForm_PreFillApproversHandler handler = new ASI_eForm_PreFillApproversHandler('', ASI_eForm_PreFillApproversHandler.PRE_TRIP_APPROVAL,currentUser);
        
        handler.processPreTripApprovalApprovers();
        
        User previewApprover = handler.approvers.get(ASI_eForm_PreFillApproversHandler.PREVIEW_APPROVER);
        User approver = handler.approvers.get(ASI_eForm_PreFillApproversHandler.APPROVER);
        String company = currentUser.CompanyName;
        
         
        ASI_eForm_Prefill_Fields__c previewApproverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('PTAPreviewApproverField');
        String previewApproverField = previewApproverFieldCS.Field_Value__c;
        
        ASI_eForm_Prefill_Fields__c approverFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('PTAApproverField');
        String approverField = approverFieldCS.Field_Value__c;
        
       // ASI_eForm_Prefill_Fields__c travellerCompanyFieldCS = ASI_eForm_Prefill_Fields__c.getInstance('PTATravellerCompanyField');
        //String travellerCompanyField = travellerCompanyFieldCS.Field_Value__c; 
        
        if(previewApprover != null){
            urlString += '&'+ previewApproverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(previewApprover); 
        }
        
        if(approver != null){
            urlString += '&'+ approverField + '=' + ASI_eForm_PreFillApproversHandler.parseInvalidStringNames(approver); 
        }
        
        /*if (company != null)
            urlString += '&'+ travellerCompanyField + '=' + company;*/
            
        String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');

        Map<String, id> RecTypeList= new Map<String,id>();
        for(Recordtype r : Global_recordTypeCache.getRtList('ASI_eForm_Pre_Trip_Approval__c')){
            RecTypeList.put(r.developername,r.id);
        }
                            
        if(RecTypeList.containsKey('ASI_eForm_SG_Pre_Trip_Approval') && ((String)RecTypeList.get('ASI_eForm_SG_Pre_Trip_Approval')).substring(0,15) == Recordtypeid){
             string field_id = ASI_eForm_Prefill_Fields__c.getInstance('Employee_Traveller').Field_Value__c;   
             urlString += '&' + field_id + '_lkid=' + UserInfo.getUserId() + '&' + field_id + '=' +UserInfo.getName();            
        }
            
        
        return new pageReference(urlString);
    }

}
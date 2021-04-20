public without sharing class ASI_TnE_KR_UpdateCustomSubmitController{
    
    public ASI_TnE_KR_UpdateCustomSubmitController(){
    
    }
    
    public PageReference refresh(){
        string id = apexpages.currentpage().getparameters().get('id');
        System.debug('------ id ------ : ' + id);
        if(id!=null && id!=''){
            ASI_TnE_ClaimHeader__c tne = [Select id, ASI_TnE_KR_Is_Custom_Submit__c, recordTypeid from ASI_TnE_ClaimHeader__c where id = :id LIMIT 1];
            
            if(Global_RecordTypeCache.getRt(tne.recordTypeid).developerName.contains('ASI_TnE_KR_TnE') ){
                tne.ASI_TnE_KR_Is_Custom_Submit__c = true;
                if(!Test.isRunningTest())
                    update tne;                         
            }
        }
        
        PageReference pageRef = new PageReference('/apex/ASI_SubmitApprovalPage?id=' + id);
            return pageRef;
    }
}
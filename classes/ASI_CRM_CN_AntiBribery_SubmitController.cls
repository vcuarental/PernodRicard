public class ASI_CRM_CN_AntiBribery_SubmitController {

    ASI_CRM_Anti_Bribery__c header;
    Map<id,recordType> mapRT = new Map<id,recordType>([SELECT id,DeveloperName FROM RecordType WHERE sObjectType='ASI_CRM_Anti_Bribery__c']);
    public ASI_CRM_CN_AntiBribery_SubmitController(ApexPages.StandardController stdController){
        header = (ASI_CRM_Anti_Bribery__c) stdController.getRecord();
    }
    
    public PageReference submitForApproval(){

        ASI_CRM_Anti_Bribery__c obj = [SELECT id, ASI_CRM_FixApproval__c, ASI_CRM_DynamicApproval__c FROM ASI_CRM_Anti_Bribery__c WHERE id = : header.id];
        
        if(mapRT.get(header.RecordTypeId).DeveloperName!='ASI_CRM_CN_Receiving_Cash' && (obj.ASI_CRM_DynamicApproval__c==true || obj.ASI_CRM_FixApproval__c==true)){
            header.ASI_CRM_Approval_Checkbox__c = true;
            update header;
            //Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        	//req.setObjectId(header.id);
        	//Approval.ProcessResult result = Approval.process(req);
        	return new pageReference('/apex/ASI_SubmitApprovalPage?id=' + header.id);
            
        }else{
            header.ASI_CRM_Status__c = 'Archived';
            
            try{
                update header;
                return new pageReference('/'+ header.id);
            }catch(dmlException dmle){
                
                return Null;
            }
        }
    }
    public PageReference cancel(){
        return new pageReference('/'+ header.id);
    }
}
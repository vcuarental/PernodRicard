public class ASI_CRM_CN_HeavyLocalContract_TriggerCls {
    
    
    public static void routineAfterInsert(list<ASI_TH_CRM_Contract__c> trigger_new) {
        List<ASI_CRM_Approval_Comment__c> LNewContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
        
        for (ASI_TH_CRM_Contract__c contract:trigger_new) {
            LNewContractComment_Insert.add(new ASI_CRM_Approval_Comment__c(ASI_CRM_Contract__c = contract.id, recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')));
        }
        
        if(LNewContractComment_Insert !=null && LNewContractComment_Insert.size() > 0){
            insert LNewContractComment_Insert;
        } 
        
    }
    
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_Contract__c> trigger_new, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        //Only for one local contract header update
        Boolean DateChanged= false;
        Boolean ChildDateOverlap= false;
        ASI_TH_CRM_Contract__c CurrentContract = new ASI_TH_CRM_Contract__c();
        for(ASI_TH_CRM_Contract__c obj : trigger_new){
            if(trigger_oldMap.get(obj.id).ASI_CRM_CN_PO_Start_Date__c != obj.ASI_CRM_CN_PO_Start_Date__c  || trigger_oldMap.get(obj.id).ASI_CRM_CN_PO_End_Date__c != obj.ASI_CRM_CN_PO_End_Date__c){
                DateChanged=true;
                CurrentContract = obj ;
            }
        }
        
        if(DateChanged &&  !ASI_MFM_ByPass_Setting.ByPassClass('ASI_CRM_CN_HeavyLocalContract_TriggerCls.routineBeforeUpdate','CN')){
            List<ASI_TH_CRM_Contract__c> ChildContractList = [select id,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_End_Date__c from 
                                                              ASI_TH_CRM_Contract__c  
                                                              where ASI_CRM_CN_Status__c!='Archived' and ASI_CRM_CN_Status__c!='FY landing Archive' 
                                                              and ASI_CRM_CN_Group_Contract__c =:CurrentContract.Id];
            
            for(ASI_TH_CRM_Contract__c childContract : ChildContractList){
                if( CurrentContract.ASI_CRM_CN_PO_Start_Date__c>childContract.ASI_CRM_CN_PO_Start_Date__c || CurrentContract.ASI_CRM_CN_PO_End_Date__c<childContract.ASI_CRM_CN_PO_End_Date__c  ){
                    ChildDateOverlap=true;
                }
            }
        }
        
        if(ChildDateOverlap){
            for(ASI_TH_CRM_Contract__c obj : trigger_new){
                obj.adderror('Cannot change PO Start/End Date. ');
            }
        }
        
    }    
}
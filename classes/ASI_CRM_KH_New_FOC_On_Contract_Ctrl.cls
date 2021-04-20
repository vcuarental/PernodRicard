public class ASI_CRM_KH_New_FOC_On_Contract_Ctrl {
	@AuraEnabled
    public static wrapperCls getRecord(String recordId){
        ASI_TH_CRM_Contract__c contractRecord = [Select Id, ASI_TH_CRM_Contract_Status__c,ASI_CRM_SG_OutletId__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
    	
        return new wrapperCls(contractRecord,Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_KH_FOC_Request'));
    }
    
    public class wrapperCls{
        @AuraEnabled public ASI_TH_CRM_Contract__c contractRec{get;set;}
        @AuraEnabled public String focKHRTypeId {get;set;}
        public wrapperCls(ASI_TH_CRM_Contract__c contractRec, String focKHRTypeId){
            this.contractRec= contractRec;
            this.focKHRTypeId =focKHRTypeId;
        }
    }
}
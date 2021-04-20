public class ASI_CRM_MY_Change_Draft_FOC_Light_ctrl {
	@AuraEnabled
    public static ASI_FOC_Free_Goods_Request__c getRecord(Id recordId){
        return [Select Id,ASI_CRM_Status__c from ASI_FOC_Free_Goods_Request__c where Id = :recordId limit 1];
    }
    
    @AuraEnabled
    public static string updatToDraft(Id recordId){
        try{
        	ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
        	foc.Id = recordId;
        	foc.ASI_CRM_Status__c  = 'Draft';
            update foc;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
}
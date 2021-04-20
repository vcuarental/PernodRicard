public class ASI_CRM_MY_Submit_FOC_Light_Ctrl {
	@AuraEnabled
    public static ASI_FOC_Free_Goods_Request__c validateRecord(Id recordId){
        ASI_FOC_Free_Goods_Request__c foc = [Select Id,ASI_CRM_MY_JDE_SO_Type__c,ASI_CRM_Status__c from ASI_FOC_Free_Goods_Request__c where Id = :recordId limit 1];
        return foc;
    }
    
    @AuraEnabled
    public static String updateRecord(String recordId){
        try{
			ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
            foc.Id = recordId;
			foc.ASI_CRM_Status__c ='Sent';
            update foc;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
}
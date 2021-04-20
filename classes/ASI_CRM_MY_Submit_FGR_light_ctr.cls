public class ASI_CRM_MY_Submit_FGR_light_ctr {
	@AuraEnabled
    public static ASI_FOC_Free_Goods_Request__c getRecord(String recordId){
        ASI_FOC_Free_Goods_Request__c fgr = [Select id, ASI_CRM_Status__c,ASI_CRM_MY_JDE_SO_Type__c from ASI_FOC_Free_Goods_Request__c where id = : recordId limit 1];
        return fgr;
        }
    
    @AuraEnabled
    
    public static String updateFGR(String recordId){
        ASI_FOC_Free_Goods_Request__c fgr = new ASI_FOC_Free_Goods_Request__c(Id = recordId, ASI_CRM_Status__c='Sent');
        try{
            update fgr;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
}
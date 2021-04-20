public class ASI_CRM_FOC_Cancel_ctrl {
	@AuraEnabled
    public static ASI_FOC_Free_Goods_Request__c getRecord(String recordId){
        return [Select Id,ASI_CRM_Status__c,ASI_CRM_Auto_Generation__c from ASI_FOC_Free_Goods_Request__c where Id = : recordId limit 1];
    }
    
    @AuraEnabled
    public static String updateStatus(String recordId, String status){
        ASI_FOC_Free_Goods_Request__c fgr = new ASI_FOC_Free_Goods_Request__c();
        fgr.Id = recordId;
        if(status == 'Draft'){
            fgr.ASI_CRM_Status__c = 'Cancelled';
        }else{
            fgr.ASI_CRM_Status__c = 'Submit for Cancel';
        }
        try{
            update fgr;
                return 'Success';
                }catch(exception e){
                    return e.getMessage();
                }
    }
    
    @AuraEnabled
    public static String checkAccess(){
        if(ASI_CRM_MY_WebService.isGroupMember_WS(UserInfo.getUserId(),'ASI_CRM_MY_Cancel_Request_User')){
            return 'true';
        }else{
            return 'false';
        }
    }
    
    @AuraEnabled
    public static string updateStatus2(String recordId){
        ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c ();
foc.Id = recordId;
foc.ASI_CRM_Status__c ='Cancelled';
        try{
            update foc;
            return 'Success';
        }catch(exception e){
            return e.getMessage();
        }
    }
}
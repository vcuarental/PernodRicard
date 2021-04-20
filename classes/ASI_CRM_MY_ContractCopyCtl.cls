public with sharing class ASI_CRM_MY_ContractCopyCtl{

    public string pid;
    public ASI_TH_CRM_Contract__c Con {get; set;}
    private ASI_CRM_MY_ContractCommon clsContract;
    public Boolean isKH {get;set;}
    public boolean isTestError;
        public class customTestException extends Exception {}
    //public ASI_CRM_MY_ContractCopyCtl(ApexPages.StandardController controller) {
        
    //}
    
    public ASI_CRM_MY_ContractCopyCtl(ApexPages.StandardSetController controller){
        
       
        pid = apexpages.currentPage().getParameters().get('id');
        
        List <ASI_TH_CRM_Contract__c> lstCon = [
            SELECT id,
                   ASI_CRM_CN_Outlet_WS__c,
                   Ownerid,
                   Name,
                   RecordTypeid,
            	   RecordType.DeveloperName,
                   ASI_TH_CRM_Start_Date__c,
                   ASI_TH_CRM_Promotion_Type__c,
                   ASI_TH_CRM_End_Date__c,
                   ASI_CRM_Version__c,
                   ASI_TH_CRM_Contract_Status__c,
                   ASI_CRM_CN_Currency__c,
                   ASI_CRM_CN_Exchange_Rate__c
            FROM ASI_TH_CRM_Contract__c
            WHERE id = :pid
        ];
        
        Con = lstCon[0];
        isKH = con.RecordType.DeveloperName.contains('KH');
         clsContract = new ASI_CRM_MY_ContractCommon(isKH ? 'KH' : 'MY');
        Con.Ownerid = UserInfo.getUserId();
        system.debug(Con);
    }
    
    public PageReference save() {
        PageReference p;
        System.Savepoint sp = database.setSavepoint();
        try {
            id idRes = clsContract.copySingleContract(pid, Con.ASI_CRM_CN_Outlet_WS__c, Con.Ownerid, Con.ASI_TH_CRM_Promotion_Type__c, Con.ASI_TH_CRM_Start_Date__c, Con.ASI_TH_CRM_End_Date__c);
            p = new PageReference('/' + ((idRes == null) ? pid : idRes));
            if(test.isRunningTest() && isTestError){
                isTestError = false;
                throw new customTestException();
                
            }
        } catch (Exception e) {
        
            System.debug('Upsert Error: ' + e);
            String strError = e.getMessage();    
            //String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
//            System.debug('Flag- Saving Error Info: getTypeName: ' + e.getTypeName() + ' getDmlType: '+e.getDmlType(0));
            system.debug('-------------Error------------' + strError);
            if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            }else if(e.getTypeName() == 'System.DmlException' && (e.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY || e.getDmlType(0) == System.Statuscode.INSUFFICIENT_ACCESS_OR_READONLY)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
            }else{    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
                
            database.rollback(sp);
        }
        return p;
    }
}
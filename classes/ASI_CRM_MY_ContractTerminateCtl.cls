public with sharing class ASI_CRM_MY_ContractTerminateCtl{
    
    public string pid;
    public ASI_TH_CRM_Contract__c Con {get; set;}
    public date olddate;
    private ASI_CRM_MY_ContractCommon clsContract;
    public Boolean isKH {get;set;}
    
    //public ASI_CRM_MY_ContractTerminateCtl(ApexPages.StandardController controller){
    //}
    
    public ASI_CRM_MY_ContractTerminateCtl(ApexPages.StandardSetController controller){
        
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
         isKH = con.RecordType.DeveloperName.contains('_KH_');
         clsContract = new ASI_CRM_MY_ContractCommon(isKH ? 'KH' : 'MY');
        olddate = lstCon[0].ASI_TH_CRM_End_Date__c;
        system.debug(Con);
    }
    
    public void forTestClass(){
        Con.ASI_TH_CRM_End_Date__c = date.newinstance(2015, 1, 1);
    }
    
    public PageReference save() {
        PageReference p;
        System.Savepoint sp = database.setSavepoint();
        try {
            system.debug('olddate : ' + olddate + ' Con.ASI_TH_CRM_End_Date__c : ' + Con.ASI_TH_CRM_End_Date__c);   
            if(olddate > Con.ASI_TH_CRM_End_Date__c){
                String strErrMsg = clsContract.terminateSingleContract(pid, Con.ASI_TH_CRM_End_Date__c);
                if (strErrMsg != '') {
                    database.rollback(sp);
                    Con.ASI_TH_CRM_End_Date__c.addError('Testing');
                } else {
                    p = new PageReference ('/' + pid);
                    p.setRedirect(true);
                }
            }else{
                Con.ASI_TH_CRM_End_Date__c.addError('The end date MUST be smaller than ' + string.valueOf(olddate));
            }
        } catch (Exception e) {
            
            System.debug('Upsert Error: ' + e);
            String strError = e.getMessage();    
            //String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            System.debug('Flag- Saving Error Info: getTypeName: ' + e.getTypeName() + ' getDmlType: '+e.getDmlType(0));
            system.debug('-------------Error------------' + strError);
            if(e.getTypeName() == 'System.DmlException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                String s = e.getDmlMessage(0); 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, s));
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
public class EUR_CRM_ContractAfterApprovedEditPageExt {
    public Boolean isFIContract{get;set;}
    public Boolean isDEContract{get;set;}
    public Boolean hasToBeSigned {get;set;}
    private EUR_CRM_Contract__c contractObj;
    private EUR_CRM_Contract__c contractObjTmp;

    public EUR_CRM_ContractAfterApprovedEditPageExt(ApexPages.StandardController standardController){

        hasToBeSigned = false;
        
        if(!Test.isRunningTest()){standardController.addFields(new List<String>{'EUR_CRM_Customer_Approved_Date__c','Recordtype.developername'});}
        
        //contractObj = (EUR_CRM_Contract__c )standardController.getRecord();

        contractObj = (EUR_CRM_Contract__c )standardController.getRecord();

        contractObjTmp = [SELECT id,EUR_CRM_Customer_Approved_Date__c, EUR_CRM_Status__c, EUR_CRM_Active__c, 
                       EUR_CRM_Contract_Signed__c, EUR_CRM_Contract_Sub_Type__c , EUR_CRM_DE_Actual_Contract_Total__c,
                       Recordtype.DeveloperName 
                       From EUR_CRM_Contract__c Where ID = :contractObj.id];
                       
        String rt = contractObjTmp.Recordtype.developername;

        if(rt == 'EUR_FI_Chain_Contract' || rt == 'EUR_FI_Independent_Contract'){
            isFIContract = true;
        } else {
            isFIContract = false;
        }


        if(rt == 'EUR_DE_Contract'){
            isDEContract = true;
        }else{
            isDEContract = false;
        }

        if(isFIContract){
            if(contractObj.EUR_CRM_Customer_Approved_Date__c == null){
                contractObj.EUR_CRM_Customer_Approved_Date__c = system.today();
            }
            contractObj.EUR_CRM_Status__c = 'Approved-Pending Activation';
            contractObj.EUR_CRM_Active__c = true;
            contractObj.EUR_CRM_Contract_Signed__c = true;
        }

        if(isDEContract){
            if(contractObj.EUR_CRM_Contract_Sub_Type__c != null){
                if( !(contractObjTmp.EUR_CRM_Contract_Sub_Type__c.contains('Basic')) || (contractObjTmp.EUR_CRM_Contract_Sub_Type__c.contains('Basic') && contractObjTmp.EUR_CRM_DE_Actual_Contract_Total__c > 3500) ){
                    hasToBeSigned = true;
                }
            }
            else{
                //Flagship
                hasToBeSigned = true;
            }
        }
    }
    
    public PageReference save() {
        //if(!contractObj.EUR_CRM_Contract_Signed__c && hasToBeSigned) {
        
        
        if(!contractObj.EUR_CRM_Contract_Signed__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Non Basic accounts, and Basic Accounts with a total of is more than 3,500, have to be signed'));
            return null;
        } else {
            upsert contractObj;
            return cancel();
        }
    }
    
    public PageReference saveFIContract(){
        try{
            //EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', new List<EUR_CRM_Contract__c>{contractObj})
            upsert contractObj;
        }catch(DMLException e){
            system.debug(e); 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.EUR_CRM_SaveError)); 
        }

        PageReference pageRef = new PageReference('/' + contractObj.id); 
        pageRef.setRedirect(true); 
        return pageRef;
    }
    
    public PageReference cancel(){            
        PageReference pageRef = new PageReference('/' + contractObj.id); 
        pageRef.setRedirect(true); 
        return pageRef;    
    }
}
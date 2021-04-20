@isTest
public class EUR_CRM_DE_Test_AttachContractPDFContent{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;

    public static void dataInsert1(){
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;  
		System.Debug('@@@account:' + accountEU);
        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, EUR_CRM_DE_TestClassUtilityHelper.DE_CONTRACT_RECORD_TYPE, accountEU.Id, date.today(), date.today().addDays(30))[0];
        contract.EUR_CRM_Contract_Sub_Type__c = 'Basic Contract';
        contract.EUR_CRM_Active__c = false;
        insert contract;

    }
    static testmethod void testDoPost(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
            system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
                
                test.startTest();
                dataInsert1();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();

                req.requestURI = 'https://XXXX.salesforce.com/services/apexrest/attachContractPDFContent/';
                req.httpMethod = 'POST';
                RestContext.request = req;
                RestContext.response = res;
                EUR_CRM_DE_AttachContractPDFContent.attachContractPDFContent(contract.id,'Basic Contract','EUR_DE_Contract_Soft_Copy.pdf');     
                test.stopTest();

        }  
    }   
    

    
}
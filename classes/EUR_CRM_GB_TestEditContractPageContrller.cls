@isTest
public class EUR_CRM_GB_TestEditContractPageContrller {

    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static EUR_CRM_Contract__c contact;
    public static void dataInsert1(){
        //Create account
        EUR_CRM_DE_TestClassUtilityHelper.initData();
        accountEU = EUR_CRM_DE_TestClassUtilityHelper.euAccount;

        Contact c = new Contact(firstname='Test fname', lastname='Test Lastname',EUR_CRM_Account__c=accountEU.Id);
        insert c;

        //Create Contract
        contract = EUR_CRM_TestClassUtilityHelper.createContracts(1, 'GB Contract', accountEU.Id, date.today(), date.today().addDays(30))[0];
        contract.EUR_CRM_Status__c = 'Proposal Approved';
        contract.EUR_CRM_Contact__c = c.Id;
        insert contract;

        ApexPages.StandardController stdController = new ApexPages.StandardController(contract);
        EUR_CRM_GB_EditContractPageContrller editContractPageContrller = new EUR_CRM_GB_EditContractPageContrller(stdController);

        editContractPageContrller.redirect();

    }    
    static testMethod void test1(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntrade();
        
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){

            test.startTest();
                dataInsert1();
            test.stopTest();
        }   
    }
}
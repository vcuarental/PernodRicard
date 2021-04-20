@isTest(seeAllData=false)
public class EUR_CRM_DE_Test_AttachContractPDF{
    private static EUR_CRM_Account__c accountEU;
    private static EUR_CRM_Contract__c contract;
    private static List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>();
    
    static testmethod void testUpdate(){
        User regionalUser = [select Id from User where UserRole.DeveloperName = :EUR_CRM_DE_TestClassUtilityHelper.NATIONAL_ON_TRADE_MANAGER_ROLE limit 1];
        User salesRepUser = [select Id from User where UserRole.DeveloperName = :EUR_CRM_DE_TestClassUtilityHelper.SR_ON_TRADE_ROLE limit 1];

        EUR_CRM_Region__c region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', regionalUser.id,  EUR_CRM_DE_TestClassUtilityHelper.DE_REGION_RECORD_TYPE);
        region.EUR_CRM_Channel__c = 'ON TRADE';
        update region;
        EUR_CRM_Territory__c territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', salesRepUser.id,region.id, EUR_CRM_DE_TestClassUtilityHelper.DE_TERRITORY_RECORD_TYPE);
        EUR_CRM_Postal_Code_Territory_Mapping__c postalmapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('postalmap' , EUR_CRM_DE_TestClassUtilityHelper.TEST_POSTAL , territory.id, EUR_CRM_DE_TestClassUtilityHelper.DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('testtaxonomy', regionalUser.id, EUR_CRM_DE_TestClassUtilityHelper.DE_CUSTOMER_TAXONOMY_RECORD_TYPE);

//        system.runAs(regionalUser){
            Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract__c'+ 'EUR_DE_Contract');

            accountEU = new EUR_CRM_Account__c(
                EUR_CRM_Postal_Code__c = '12345',
                recordtypeid=Global_RecordTypeCache.getRtId('EUR_CRM_Account__c'+ 'EUR_DE_OFF_STD'),
                name = 'testname',
                EUR_CRM_Territory__c = territory.Id,
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_JB_Customer_Taxonomy__c =customerTaxonomy.Id );

            insert accountEU;

            Test.startTest();

            //Create Contract
            EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c();
            contract.RecordTypeId = recordtypeId;
            contract.EUR_CRM_Account__c = accountEU.Id;
            contract.EUR_CRM_Start_Date__c = date.today();
            contract.EUR_CRM_End_Date__c = date.today().addDays(30);
            contract.EUR_CRM_Contract_Sub_Type__c = 'Basic Contract';
            contract.EUR_CRM_Active__c = false;
            insert contract;

            contract.EUR_CRM_Active__c = true;
            contract.EUR_CRM_Contract_Type__c = 'Standard Contract';
            contract.EUR_CRM_Status__c = 'Approved';
            update contract;

            List<EUR_CRM_Contract__c> contractList= new List<EUR_CRM_Contract__c>();
            contractList.add(contract);
            EUR_CRM_DE_AttachContractPDF.attachPDF(contract.Id,UserInfo.getSessionId());
            EUR_CRM_DE_AttachContractPDF.retrieveContracts(contract.Id);
            EUR_CRM_DE_AttachContractPDF.formatContractIds(contractList);
            test.stopTest();
//        }
        
    }
    
}
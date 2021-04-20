/**
    Test class for the EUR_NIM_SearchServiceController Apex class
    
    @author Minakshi Waghulde
    
    @copyright PARX
*/
@IsTest
public class EUR_NIM_SearchServiceController_Test 
{
    @isTest static void test_search()
    {
        EUR_CRM_Account__c acc = EUR_COMMON_TestUtils.createAccount('EUR IDL On Trade Account');
        EUR_CRM_Account__c acc2 = EUR_COMMON_TestUtils.createAccount('EUR IDL On Trade Account', 'account test2');
        Contact conAcc = EUR_COMMON_TestUtils.createContact(acc);
        Contact conAcc2 = EUR_COMMON_TestUtils.createContact(acc2);

        List<EUR_NIM_Service.AccountContactResult> resultList = new List<EUR_NIM_Service.AccountContactResult>();

        Test.startTest();
        //Search by combination of Account and Contact
        resultList = EUR_NIM_SearchServiceController.searchByAccountContact(acc.Name, acc.EUR_CRM_Customer_No_ERP__c,
        acc.EUR_CRM_Street__c, acc.EUR_CRM_Postal_Code__c, acc.EUR_CRM_City__c, conAcc2.Phone, conAcc2.FirstName, conAcc2.LastName);
        system.debug('resultList1: ' + resultList.size());
		system.assertEquals(2, resultList.size());
        
        resultList.clear();
        //Search by combination of Account and Contact
        resultList = EUR_NIM_SearchServiceController.searchByAccountContact(acc2.Name, acc2.EUR_CRM_Customer_No_ERP__c,
        acc2.EUR_CRM_Street__c, acc2.EUR_CRM_Postal_Code__c, acc2.EUR_CRM_City__c, conAcc.Phone, conAcc.FirstName, conAcc.LastName);
        system.debug('resultList2: ' + resultList.size());
		system.assertEquals(2, resultList.size());
        
        resultList.clear();

        //Search by only Account
        resultList = EUR_NIM_SearchServiceController.searchByAccountContact(acc.Name, acc.EUR_CRM_Customer_No_ERP__c,
            acc.EUR_CRM_Street__c, acc.EUR_CRM_Postal_Code__c, acc.EUR_CRM_City__c, '', '', '');
        system.debug('resultList3: ' + resultList.size());
		system.assertEquals(1, resultList.size());
        
        resultList.clear();
        //Search by only Contact
        resultList = EUR_NIM_SearchServiceController.searchByAccountContact('', '', '', '', '', conAcc2.Phone, conAcc2.FirstName, conAcc2.LastName);
        system.debug('resultList4: ' + resultList.size());
        system.assertEquals(2, resultList.size());
        Test.stopTest();

        
    }
}
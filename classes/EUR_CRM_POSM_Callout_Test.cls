@isTest
public class EUR_CRM_POSM_Callout_Test {

    static User eurZaUser;

    //Creating the context user
    static void setUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name= 'EUR ZA Standard On Trade User'];
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurZaUser = new User(Alias = 'standt', Email='POSM_Callout_Test@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='POSM_Callout_TestlastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@SalesOrderCalloutTest.com');
        insert eurZaUser;
    }

    public testmethod static void testCalloutFunctionality(){
        setUser();
        System.runAs(eurZaUser){

            //Create Test Data for Account
            List<EUR_CRM_Account__c> accountList = EUR_CRM_ZA_TestClassHelper.createEUAccount(1, 'testAccount', 'EUR_ZA_On_Trade_Direct');
            insert accountList;

            //Create Test data for Sales Order
            List<EUR_CRM_POSM_Order__c> posmOrderList = EUR_CRM_ZA_TestClassHelper.createPOSMOrder(1, accountList[0]);
        
            for(EUR_CRM_POSM_Order__c objPosm : posmOrderList){
                objPosm.EUR_CRM_Order_Date__c = Date.today();
                objPosm.EUR_CRM_Order_Status__c = 'In Process';
            }
            insert posmOrderList;


            //Create Test data for Sales Order Item    
            List<EUR_CRM_POSM_Order_Item__c> posmOrderItemList = EUR_CRM_ZA_TestClassHelper.createPOSMOrderItems(2);

            for(EUR_CRM_POSM_Order_Item__c posmLineItem : posmOrderItemList){
            posmLineItem.EUR_CRM_POSM_Order__c = posmOrderList[0].Id;
            }
            insert posmOrderItemList;

            test.startTest();
                //  Test Trigger and Trigger class
                posmOrderList[0].EUR_CRM_No_of_POSM_Order_Items__c = 2;
                update posmOrderList;
                // Test callout Queue
                EUR_CRM_POSMCalloutQueueable queue = new EUR_CRM_POSMCalloutQueueable(posmOrderList[0].Id);
                ID jobId = System.enqueueJob(queue);
                // Test Callout Helper
                EUR_CRM_POSM_CalloutHelper helper = new EUR_CRM_POSM_CalloutHelper();
                test.setMock(HttpCalloutMock.class, new EUR_CRM_SO_CalloutMock());
                helper.callService(posmOrderList[0].Id);

                // Test the xmlWriter
                EUR_CRM_POSM_XmlWriter writer = new EUR_CRM_POSM_XmlWriter();
                String strXmlString = writer.generateXmlForPOSMOrder(posmOrderList[0].Id);
                System.assertNotEquals(NULL, strXmlString);

            test.stopTest();
        }
    }
}
/*
Test:
1. ASI_CRM_KR_AcctCustomerPage	   <ASI_CRM_KR_AcctCustomerPage_Test1>
*/
@istest

public class ASI_CRM_KR_AcctCustomerPage_TestClass {
     static testMethod void ASI_CRM_KR_AcctCustomerPage_Test1() {
         
        //Update User Information 
        user TestingUser = [select ASI_MFM_Country__c,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        TestingUser.ASI_MFM_Country__c = 'KR';
        TestingUser.CompanyName = 'Pernod Ricard Korea';
        update TestingUser;
        
        System.runAs(TestingUser){
            
            
            //Insert Account: Venue recordtype
            Account Venue = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),
                                        Name='Venue Testing Account',
                                        ASI_KOR_Wholesaler_Channel__c = 'TOT'
                                       );       
            insert Venue;
            
            Test.startTest();  
            //ApexPages.standardSetController sc = new ApexPages.standardSetController(Venue);
            PageReference AcctPage = Page.ASI_CRM_KR_AcctCustomer_Page;
            Test.setCurrentPageReference(AcctPage);
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Venue);
            ASI_CRM_KR_AcctCustomerPage Ctrl  = new ASI_CRM_KR_AcctCustomerPage(stdController);
            
            Ctrl.save();
            Ctrl.eidtPage();
            Ctrl.cancel();
            
            Test.stopTest();
        }
         
     }
}
/*
Test:
1.	ASI_CRM_KR_PVADisplayController   <PVADisplayController_Test>
2.  ASI_CRM_KR_PVA_BeforeDelete   ASI_CRM_KR_PVA_TriggerClass
3.ASI_CRM_KR_PVAUploadController
*/

@istest
public class ASI_CRM_KR_PVA_TestClass {
    
    static testMethod void PVAUploadTest() {
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_KOR_User_Branch_Code__c='530';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        System.runAs(u){ 
            Test.startTest();
            ASI_CRM_KR_PVAUploadController con = new ASI_CRM_KR_PVAUploadController();
            con.init();
            Test.stopTest();
        }
    }
    
    
    
    //Test trigger ASI_CRM_KR_PVA_BeforeDelete and class: ASI_CRM_KR_PVA_TriggerClass 
     static testMethod void PVA_DeleteTriggerClass() {
         Test.startTest();
         ASI_CRM_KR_PVA__c pva = new ASI_CRM_KR_PVA__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_KR_PVA__cASI_CRM_KR_PVA'));
         insert pva;
         
         Account Venue = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'), Name='Venue Testing Account', ASI_KOR_Wholesaler_Channel__c = 'TOT' );       
         insert Venue;
         
         ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'), Name='Venue Testing',ASI_CRM_Account__c=Venue.id);
         insert customer;
         
         ASI_CRM_KR_A_P_Guideline__c AnPguideline = new ASI_CRM_KR_A_P_Guideline__c(ASI_CRM_KR_Account_Code__c=Venue.id,ASI_CRM_KR_PVA__c=pva.id,ASI_CRM_KR_Customer__c=customer.id);
         insert AnPguideline;
         
         pva.ASI_CRM_KR_Check__c=true;
         update pva;
         
         delete pva;
         
         Test.stopTest();
     }
    
    
    static testMethod void PVADisplayController_Test_1() {
        
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
            
            //Insert Customer: Venue recordtype
            ASI_CRM_AccountsAdditionalField__c Customer = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'), 
                                                                                                 ASI_CRM_Account__c = Venue.id,
                                                                                                 ASI_CRM_Outlet_Image__c = 'Leading'
                                                                                                 );
            insert Customer;
            
            Test.startTest();
                PageReference PVADisplayPage = Page.ASI_CRM_KR_PVADisplayPage;
                Test.setCurrentPageReference(PVADisplayPage);
                ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Venue);
                ASI_CRM_KR_PVADisplayController PVADisplayCtrl  = new ASI_CRM_KR_PVADisplayController(stdController);
                PVADisplayCtrl.init();
            
            Test.stopTest();
            
        }
    }
    
    static testMethod void PVADisplayController_Test_2() {
        
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
                PageReference PVADisplayPage = Page.ASI_CRM_KR_PVADisplayPage;
                Test.setCurrentPageReference(PVADisplayPage);
                ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(Venue);
                ASI_CRM_KR_PVADisplayController PVADisplayCtrl  = new ASI_CRM_KR_PVADisplayController(stdController);
                PVADisplayCtrl.init();
            
            Test.stopTest();
            
        }
    }
}
@isTest
public class ASI_CRM_SG_Complete_Contract_Light_test {
     @testSetup    
    Public static void testData(){
          Profile p1 = [Select Id from profile where Name = 'System Administrator' limit 1];
        User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p1.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com.ctr');
         insert u1;
        
    }
    
    public static testMethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id from ASI_TH_CRM_Contract__c limit 1];       
        test.startTest();
            ASI_CRM_SG_Complete_Contract_Light_Ctrl.validateComplete(contract.Id);
         contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
        update contract;
        ASI_CRM_SG_Complete_Contract_Light_Ctrl.validateComplete(contract.Id);
            String userId = Userinfo.getUserId();
        User u1 = [Select Id from user where UserName='CaseAR@mail.com.ctr' limit 1];
        contract.ownerId = u1.Id;
        
        update contract;
         ASI_CRM_SG_Complete_Contract_Light_Ctrl.validateComplete(contract.Id);
       
        test.stopTest();
    }
}
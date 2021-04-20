@isTest
public class ASI_CRM_CN_Function_Test {

    static testMethod void ASI_CRM_CN_Function_TEST() {
        
        update new User(Id=UserInfo.getUserId(), BypassTriggers__c='TEST');
        
        test.startTest();
        
        ASI_CRM_CN_Function.CRMException ex = new ASI_CRM_CN_Function.CRMException();
        
        ASI_CRM_CN_Function.getSystemAdminUser();
        ASI_CRM_CN_Function.getUser(UserInfo.getUserId());
        ASI_CRM_CN_Function.getUserList();
        ASI_CRM_CN_Function.getFiscalYear(date.newInstance(system.today().year(), 1, 1));
        ASI_CRM_CN_Function.getFiscalYear(date.newInstance(system.today().year(), 7, 1));
        set<string> ss = ASI_CRM_CN_Function.BypassedTriggers;
        AsI_CRM_CN_Function.IsBypassTrigger('TEST');
        
        test.stopTest(); 
        
    }
    
}
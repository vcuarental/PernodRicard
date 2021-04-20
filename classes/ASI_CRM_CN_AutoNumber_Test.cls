@isTest
public class ASI_CRM_CN_AutoNumber_Test {
    
    static testMethod void ASI_CRM_CN_AutoNumberAssignment_TEST() {
        
        insert new ASI_CRM_CN_RunningNumber__c(ASI_CRM_CN_Running_Number__c=0, ASI_CRM_CN_Prefix__c='TEST1');
        
        test.startTest();
        
        ASI_CRM_CN_AutoNumberAssignment an1 = new ASI_CRM_CN_AutoNumberAssignment('TEST1');        
        an1.nextAutoNumStr();
        an1.nextAutoNum();
        an1.writeToDB();
        ASI_CRM_CN_AutoNumberAssignment an2 = new ASI_CRM_CN_AutoNumberAssignment('TEST2');
        
        test.stopTest();
        
    }
    
}
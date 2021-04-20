@isTest
public class ASI_CRM_MY_Calculated_Test {
	static testMethod void Offtake_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
         
        System.runAs(userA){
            
            Test.startTest();
            ASI_CRM_MY_Calculated calculated_ctrl = new ASI_CRM_MY_Calculated();
            calculated_ctrl.executeCalculatedFOC_Schedule();
            Test.stopTest();
        }
        
    }
}
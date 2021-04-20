/*Filename:    ASI_CRM_KH_Contract_TEST.cls
* 
*
*
* History
* -----------------------------------------------------------------------------
* 2020-10-02        Wilken Lee        [WL 1.0] Add checking by market
*/
@isTest
public class ASI_CRM_KH_Contract_TEST {
    static testMethod void insertContract_TEST() {
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_KH_Contract');

        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        //Group testGroup = new Group();
        //testGroup.Name = 'ASI_CRM_MY_Contract_Final';
        //testGroup.DeveloperName = 'ASI_CRM_MY_Contract_Final';
        //INSERT testGroup;
        
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Contract_Final' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            
            /*[WL 1.0] END*/
            //ASI_CRM_MY_TestClassHelper.createRunningNumbers(); //WL 1.0
            ASI_CRM_Running_Number__c contractRunningNum = new ASI_CRM_Running_Number__c(ASI_CRM_Module__c = 'ASI_CRM_KH_Contract', ASI_CRM_Prefix__c = '0', ASI_CRM_Number_of_Digit__c = 7, ASI_CRM_Running_Number__c = 0, ASI_CRM_Description__c = 'KH Contract', RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Running_Number__cASI_CRM_KH_Running_Number'));
            insert contractRunningNum;
            /*[WL 1.0] END*/
        
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_KH_Customer');
            
            ASI_TH_CRM_Contract__c contract = 
                new ASI_TH_CRM_Contract__c(
                    Name = 'Auto-generated Number', 
                    ASI_TH_CRM_Start_Date__c = date.newinstance(1997, 7, 1),
                    ASI_TH_CRM_End_Date__c = date.newinstance(2015, 2, 1),
                    ASI_TH_CRM_Contract_Status__c = 'Draft',
                    ASI_TH_CRM_Promotion_Type__c = 'Contract',
                    ASI_CRM_CN_Outlet_WS__c = customer1.id,
                    ASI_CRM_Version__c = '1',
                    ASI_CRM_Obsolete_Version__c = FALSE,
                    RecordTypeId = idRTContractNormal
                );
            test.startTest();
            insert contract;
            ASI_CRM_KH_New_FOC_On_Contract_Ctrl.getRecord(contract.Id);
            delete contract;
            test.stopTest();
            
        }
    }
}
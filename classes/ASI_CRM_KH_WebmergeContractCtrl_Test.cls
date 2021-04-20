@isTest
public class ASI_CRM_KH_WebmergeContractCtrl_Test {
    public static testMethod void test1(){

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
                    webm__Webmerge_Mapping__c wbm = new webm__Webmerge_Mapping__c(name = 'ASI CRM KH Contract',webm__Salesforce_Object_Name__c= 'webm__Salesforce_Object_Name__c');
        insert wbm;
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        
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
             insert contract;
            test.startTest();
            	ApexPages.StandardController sc = new ApexPages.StandardController(contract);
            	ASI_CRM_KH_WebmergeContractCtrl ctrl = new ASI_CRM_KH_WebmergeContractCtrl(sc);
            test.stopTest();
        }
    }
}
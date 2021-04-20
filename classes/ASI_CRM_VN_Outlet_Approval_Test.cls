@isTest(SeeAllData=false)
public class ASI_CRM_VN_Outlet_Approval_Test {
	@testSetup
    public static void setupTestData(){
        
        //VK - Customer Data Setup Initialization
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;   
        
        Id CustRecordTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName()
                                                                                   .get('Outlet (VN)').getRecordTypeId();
        
        Id prosRecordTypeId = Schema.SObjectType.ASI_CRM_Pros_Segmentation__c.getRecordTypeInfosByName()
                                                                                   .get('ASI CRM VN PROS Segmentation').getRecordTypeId();
        
        Id prosCriteriaRecordTypeId = Schema.SObjectType.ASI_CRM_Criteria_Set__c.getRecordTypeInfosByName()
                                                                                   .get('VN Image Level Criteria').getRecordTypeId();
        
        Id prosThresholdRecordTypeId = Schema.SObjectType.ASI_CRM_Criteria_Threshold__c.getRecordTypeInfosByName()
                                                                                   .get('VN Number Input').getRecordTypeId();
        
        Id prosImageRecordTypeId = Schema.SObjectType.ASI_CRM_Pros_Image_Level__c.getRecordTypeInfosByName()
                                                                                   .get('ASI CRM VN ProsImageLevel').getRecordTypeId();
        
        //VK - Create test data (Account)
        Account acc = new Account(Name='Test Account');
        insert acc;
        System.debug('------------------------------------------'+acc.id);
        
        // VK - Create test data (Customer)
        ASI_CRM_AccountsAdditionalField__c cust = new ASI_CRM_AccountsAdditionalField__c(
            Name = 'Testing Outlet', ASI_CRM_VN_Region__c = 'Central', ASI_CRM_Account__c=acc.id,RecordTypeid =CustRecordTypeId);
        insert cust;  
        System.debug('------------------------------------------'+cust.id);
        
        
        // VK - Create test data (PROS)
        ASI_CRM_Pros_Segmentation__c pros = new ASI_CRM_Pros_Segmentation__c(ASI_CRM_SG_Customer__c = cust.id, RecordTypeId = prosRecordTypeId);
        insert pros;
        System.debug('------------------------------------------'+pros.id);
        
        //VK - Create test data (PROS Criteria Set)
        ASI_CRM_Criteria_Set__c pros_criteria_set = new ASI_CRM_Criteria_Set__c(RecordTypeId = prosCriteriaRecordTypeId);
        insert pros_criteria_set;
        System.debug('------------------------------------------'+pros_criteria_set.id);
        
        //VK - Create test data (PROS Threshold)
        ASI_CRM_Criteria_Threshold__c pros_threhsold = new ASI_CRM_Criteria_Threshold__c(ASI_CRM_SG_Criteria_Set__c = pros_criteria_set.id,ASI_CRM_SG_Question__c = 'Test', RecordTypeId = prosThresholdRecordTypeId);
        insert pros_threhsold;
        System.debug('------------------------------------------'+pros_threhsold.id);
        
        //VK - Create test data (PROS Image)
        ASI_CRM_Pros_Image_Level__c pros_img_lvl = new ASI_CRM_Pros_Image_Level__c(ASI_CRM_SG_Pros_Segmentation__c = pros.id, ASI_CRM_SG_Criteria_Threshold__c = pros_threhsold.id, ASI_CRM_SG_Answer__c = 'Test Answer', ASI_CRM_Score__c = 10, ASI_CRM_SG_Weight__c = 10, RecordTypeId = prosImageRecordTypeId);
        insert pros_img_lvl;
        System.debug('------------------------------------------'+pros_img_lvl.id);
        
    }
    
    static testMethod void GetPROSImage(){
        Profile p = [select id from profile where name='System Administrator'];
        UserRole ur=new UserRole(Name='Test UserRole');
        insert ur;
        System.debug('-----------------------------'+ur.id);
        User u = new User(alias = 'systemA', email='systemadmin@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', 
                          languagelocalekey='en_US', localesidkey='en_US', 
                          profileid = p.Id,isactive = true ,
                          timezonesidkey='America/Los_Angeles',
                          username='systemadmin@updaterspregiontest.com',userroleID=ur.id);
        
        System.runAs(u) {
            Test.startTest();
            
            List<ASI_CRM_AccountsAdditionalField__c> custlist = [SELECT id, name FROM ASI_CRM_AccountsAdditionalField__c WHERE Name = 'Testing Outlet' LIMIT 1];
            
            if (custlist.size() > 0) {
                for (ASI_CRM_AccountsAdditionalField__c idxcust : custlist) {
                    ASI_CRM_VN_Outlet_Approval_Controller ctrl = new ASI_CRM_VN_Outlet_Approval_Controller();
                    ctrl.customerId = idxcust.Id;
                    ctrl.getProsImage();
                }
            }
            
            Test.stopTest();  
        }

    }
}
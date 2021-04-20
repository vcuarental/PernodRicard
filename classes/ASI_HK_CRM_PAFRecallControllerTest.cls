@isTest
public without sharing class ASI_HK_CRM_PAFRecallControllerTest {

    public static final String DEF_VALUE_PROFILE_NAME = 'Standard User';
    public static final ID DEF_VALUE_PROFILE_ID;
    public static final String DEF_VALUE_ROLE_NAME = 'CEO';
    public static final ID DEF_VALUE_ROLE_ID;
    public static final String DEF_VALUE_EMAIL_DOMAIN = '@X_DOMAIN_X.com';
    public static final String DEF_VALUE_EMAIL_ENCODE_KEY = 'UTF-8';
    public static final String DEF_VALUE_LOCALE = 'en_US';
    public static final String DEF_VALUE_LANG = 'en_US';
    public static final String DEF_VALUE_TIMEZONE = 'Asia/Hong_Kong';

    static {
        if (DEF_VALUE_PROFILE_NAME != null) {
            List<Profile> defProfileList = [SELECT Id FROM Profile WHERE Name = :DEF_VALUE_PROFILE_NAME];
            if (defProfileList.size() > 0) {
                DEF_VALUE_PROFILE_ID = defProfileList.get(0).Id;
            }
        }
        if (DEF_VALUE_ROLE_NAME != null) {
            List<UserRole> defRoleList = [SELECT Id FROM UserRole WHERE Name = :DEF_VALUE_ROLE_NAME];
            if (defRoleList.size() > 0) {
                DEF_VALUE_ROLE_ID = defRoleList.get(0).Id;
            }
        }
    }

    
    static testMethod void testPAFRecall() {
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testPAFRecall@HKCRM.com');
        insert u1;
        
        
        User u2 = new User(Alias = 'standt', Email='standarduser2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testPAFRecall2@HKCRM.com',
        ManagerId = u1.id);

        
        System.runAs(u2){         
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        ASI_HK_CRM_BrandGenerator BrandGenerator = new ASI_HK_CRM_BrandGenerator(); 
        ASI_HK_CRM_SubBrandGenerator subBrandGenerator = new ASI_HK_CRM_SubBrandGenerator();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        System.debug('abc1'+acctCredit.id);
        
        Account acctPotential = acctGenerator.generateAccount('ASI_HK_CRM_Potential_Account');    //Credit Account
        insert acctPotential;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');        
        //paf.ASI_HK_CRM_Adjusted_End_Date__c= Date.today().addDays(1);
        //paf.ASI_HK_CRM_Adjusted_Start_Date__c= Date.today();
        //paf.ASI_HK_CRM_PAF_Start_Date__c = Date.today().addDays(-1);
		
		paf.recordTypeID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form');
		paf.ASI_HK_CRM_PAF_Status__c = 'Draft';
        Insert paf;
        
        ASI_MFM_Brand__c Brand = brandGenerator.generateBrand(); 
		Brand.ASI_TH_CRM_Active__c = true;
        Insert Brand;
        
        ASI_MFM_Sub_brand__c subBrand = subBrandGenerator.generateSubBrand(Brand);
        Insert subBrand;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        Insert sku;        
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        sku2.ASI_MFM_Sub_brand__c = subBrand.id;
        Insert sku2;
        
        List<ASI_MFM_SKU_Code__c> skuList = [select id, name from ASI_MFM_SKU_Code__c where ASI_MFM_Sub_brand__c <> null];
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        Insert mech1;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        insert pafline;
        
        //click button be4 submit to run error handling code
        PageReference testPage = Page.ASI_HK_CRM_PAFApprovalRecallPage;
        Map<String, String> pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(paf);    
        ASI_HK_CRM_PAFApprovalRecallController testController = new ASI_HK_CRM_PAFApprovalRecallController(stdController);
        PageReference initRedirectPage = testController.doRecall();
        
        //submit the PAF
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(paf.Id);
        //req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        Approval.ProcessResult result1 = Approval.process(req1); 
        List<Id> newWorkItemIds = result1.getNewWorkitemIds();
        

        
        //Click recall again
        testPage = Page.ASI_HK_CRM_PAFApprovalRecallPage;
        pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        stdController = new ApexPages.StandardController(paf);    
        testController = new ASI_HK_CRM_PAFApprovalRecallController(stdController);
        initRedirectPage = testController.doRecall();
        }
    
        Test.stopTest();
    }
    
    
    
}
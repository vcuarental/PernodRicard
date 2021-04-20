@isTest
public with sharing class ASI_HK_CRM_PAFFinalRejectCONTest {

    static testMethod void testSalesOrderRecall() {
        
        Test.startTest();
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
        Insert paf;
        
        ASI_MFM_Brand__c Brand = brandGenerator.generateBrand(); 
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
        
        //click button at wrong stage to test exception handling
        PageReference testPage = Page.ASI_HK_CRM_PAFApprovalFinalRejectPage;
        Map<String, String> pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(paf);    
        ASI_HK_CRM_PAFApprovalFinalRejectCON testController = new ASI_HK_CRM_PAFApprovalFinalRejectCON(stdController);
        PageReference initRedirectPage = testController.doFinalReject();
        
      
        //set PAF to correct status
        paf.ASI_HK_CRM_PAF_Status__c='FM Approved';
        update paf;

        //Click again
        testPage = Page.ASI_HK_CRM_PAFApprovalFinalRejectPage;
        pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        stdController = new ApexPages.StandardController(paf);    
        testController = new ASI_HK_CRM_PAFApprovalFinalRejectCON(stdController);
        initRedirectPage = testController.doFinalReject();
        
    
        Test.stopTest();
    }
    
    
    
}
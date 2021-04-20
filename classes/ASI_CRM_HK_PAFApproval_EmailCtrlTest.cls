@isTest
private class ASI_CRM_HK_PAFApproval_EmailCtrlTest {

    static testMethod void PAFApproval_EmailCtrlTest(){     
       Test.startTest();
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        ASI_HK_CRM_BrandGenerator BrandGenerator = new ASI_HK_CRM_BrandGenerator(); 
        ASI_HK_CRM_SubBrandGenerator subBrandGenerator = new ASI_HK_CRM_SubBrandGenerator();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        //Account acctCredit = new Account();
        //acctCredit.Name = 'HK1';
        //acctCredit.recordTypeId = '012M00000000O3gIAE';
        acctCredit.recordTypeId = ASI_HK_CRM_AccountGenerator.getRecordTypeByDevName(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT).id;
        insert acctCredit;


//        System.debug('abc1'+acctCredit.id);
        
        Account acctPotential = acctGenerator.generateAccount('ASI_HK_CRM_Potential_Account');    //Credit Account
        insert acctPotential;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');        
        Insert paf;
        
        ASI_MFM_Brand__c Brand = brandGenerator.generateBrand(); 
        Insert Brand;
        
        ASI_MFM_Sub_brand__c subBrand = subBrandGenerator.generateSubBrand(Brand);
        Insert subBrand;
        
        List<ASI_MFM_SKU_Code__c> skuList2 = new List<ASI_MFM_SKU_Code__c>();  
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        skuList2.add(sku);        
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        sku2.ASI_MFM_Sub_brand__c = subBrand.id;
        skuList2.add(sku2);
        insert skuList2;
        
        List<ASI_MFM_SKU_Code__c> skuList = [select id, name from ASI_MFM_SKU_Code__c where ASI_MFM_Sub_brand__c <> null];
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        Insert mech1;
        
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> paflineList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();  
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        paflineList.add(pafline);
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline_foc = paflineGenerator.generatePreApprovalFormItem(paf,sku,'ASI_HK_CRM_PAF_Item_FOC');
        pafline_foc.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline_foc.ASI_HK_CRM_Price__c = 200;
        paflineList.add(pafline_foc);
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline_mechanic = paflineGenerator.generatePreApprovalFormItem(paf,sku,'ASI_HK_CRM_PAF_Item_FOC');
        pafline_mechanic.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline_mechanic.ASI_HK_CRM_Price__c = 200;
        pafline_mechanic.ASI_HK_CRM_Mechanic__c = mech1.id;
        pafline_mechanic.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 100;
        pafline_mechanic.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 10;
        paflineList.add(pafline_mechanic);

        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline_withSubBrand = paflineGenerator.generatePreApprovalFormItem(paf,sku2,'ASI_HK_CRM_PAF_Item_FOC');
        pafline_withSubBrand.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline_withSubBrand.ASI_HK_CRM_Price__c = 200;
        pafline_withSubBrand.ASI_HK_CRM_Mechanic__c = mech1.id;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 100;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 10;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 100;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 10;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c = 100;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c = 10;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c = 100;
        pafline_withSubBrand.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c = 10;
        paflineList.add(pafline_withSubBrand);
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline_rtVariable = paflineGenerator.generatePreApprovalFormItem(paf,sku,'ASI_HK_CRM_PAF_Item_Variable');
        pafline_rtVariable.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline_rtVariable.ASI_HK_CRM_Price__c = 200;
        pafline_rtVariable.ASI_HK_CRM_Mechanic__c = mech1.id;
        pafline_rtVariable.ASI_HK_CRM_Rebate_Disc_Percent__c = 20;
        pafline_rtVariable.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c = 20;
        pafline_rtVariable.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 100;
        pafline_rtVariable.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 10;
        paflineList.add(pafline_rtVariable);
        
        insert paflineList; 
        
        ASI_CRM_HK_PAFApproval_EmailController paf_email_ctrlr = new ASI_CRM_HK_PAFApproval_EmailController();
        paf_email_ctrlr.currentHeaderID = paf.Id;
        paf_email_ctrlr.init();
        
        /*
        ApexPages.StandardController stdConroller = new ApexPages.StandardController(paf);
        PageReference testPage = Page.ASI_HK_CRM_PAFCustomViewPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', paf.id);
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_PAF_CustomView pcv = new ASI_HK_CRM_PAF_CustomView(stdConroller);                               
 		*/
        Test.stopTest(); 
    }
}
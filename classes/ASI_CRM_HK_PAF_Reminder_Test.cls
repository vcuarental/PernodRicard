@isTest
private class ASI_CRM_HK_PAF_Reminder_Test {
    
    static testMethod void RemindPendingApproval_Test()
    {
        
        
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        ASI_HK_CRM_BrandGenerator BrandGenerator = new ASI_HK_CRM_BrandGenerator(); 
        ASI_HK_CRM_SubBrandGenerator subBrandGenerator = new ASI_HK_CRM_SubBrandGenerator();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit.recordTypeId = ASI_HK_CRM_AccountGenerator.getRecordTypeByDevName(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT).id;
        insert acctCredit;
        
        
        
        Account acctPotential = acctGenerator.generateAccount('ASI_HK_CRM_Potential_Account');    //Credit Account
        insert acctPotential;
        
        
        User admin = [SELECT Id FROM user WHERE Profile.Name like '%System Administrator%' AND isActive = true limit 1];   
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        if(currentUser.Managerid ==null ){
            currentUser.Managerid = admin.id;
            update currentUser;
        }
        
        
      
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form');
        paf.ownerID= currentUser.Id;
        Insert paf;
        
        ASI_MFM_Brand__c Brand = brandGenerator.generateBrand(); 
        Insert Brand;
        
        ASI_MFM_Sub_brand__c subBrand = subBrandGenerator.generateSubBrand(Brand);
        Insert subBrand;
        
        List<ASI_MFM_SKU_Code__c> skuList2 = new List<ASI_MFM_SKU_Code__c>();  
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        sku.ASI_FOC_Active__c=true;
        skuList2.add(sku);        
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        sku2.ASI_MFM_Sub_brand__c = subBrand.id;
        skuList2.add(sku2);
        insert skuList2;
        
        List<ASI_MFM_SKU_Code__c> skuList = [select id, name from ASI_MFM_SKU_Code__c where ASI_MFM_Sub_brand__c <> null];
        List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechList = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech1.ASI_HK_CRM_Code__c = 'A01';
        mech1.ASI_CRM_Short_Name__c = 's';
        mech1.ASI_CRM_HK_Active__c = true;
        mechList.add(mech1);
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech2 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech2.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech2.ASI_HK_CRM_Code__c = 'A02';
        mech2.ASI_CRM_Short_Name__c = 's';
        mech2.ASI_CRM_HK_Active__c = true;
        mechList.add(mech2);
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech3 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech3.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech3.ASI_HK_CRM_Code__c = 'A17';
        mech3.ASI_CRM_Short_Name__c = 's';
        mech3.ASI_CRM_HK_Active__c = true;
        mechList.add(mech3);
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech4 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech4.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech4.ASI_HK_CRM_Code__c = 'B03';
        mech4.ASI_CRM_Short_Name__c = 's';
        mech4.ASI_CRM_HK_Active__c = true;
        mechList.add(mech4);
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech5 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech5.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech5.ASI_HK_CRM_Code__c = 'B08';
        mech5.ASI_CRM_Short_Name__c = 's';
        mech5.ASI_CRM_HK_Active__c = true;
        mechList.add(mech5);
        
        Insert mechList;
        
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
        
        update pafline_withSubBrand;
               
        // Create an approval request for the opportunity
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(paf.Id); 
        Approval.ProcessResult processResult = Approval.process(req1);
        //Valid values are: Approved, Rejected, Removed or Pending.
        System.assertEquals('Pending', processResult.getInstanceStatus());      
        
        Test.startTest();
        
        ASI_CRM_HK_PAF_Reminder_Batch batchObj = new ASI_CRM_HK_PAF_Reminder_Batch();
        DataBase.executeBatch(batchObj);
        
        
        Test.stopTest(); 
    }
}
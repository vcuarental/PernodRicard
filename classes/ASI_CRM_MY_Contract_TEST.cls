@isTest(seealldata=false)
/****************************************
Test Classes:
 1. ASI_CRM_MY_ContractBuilderCtl
 2. ASI_CRM_MY_ContractCommon
 3. ASI_CRM_MY_ContractCopyCtl
 4. ASI_CRM_MY_ContractDBC
 5. ASI_CRM_MY_ContractOther_TriggerCls
 6. ASI_CRM_MY_ContractPP_TriggerCls
 7. ASI_CRM_MY_ContractSalesStaff_TriggerCls
 8. ASI_CRM_MY_ContractSummaryCtl
 9. ASI_CRM_MY_ContractTarget_TriggerCls
10. ASI_CRM_MY_ContractTerminateCtl
11. ASI_CRM_MY_Contract_TriggerClass
12. ASI_CRM_MY_ContractVolume_TriggerCls
13. ASI_CRM_MY_DBC_Ctl 
****************************************/
public class ASI_CRM_MY_Contract_TEST{

    static testMethod void insertContract_TEST() {
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');

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
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            
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
            
            //contract.date.newinstance(2015, 1, 1);
            
            //Press the copy button
            ASI_TH_CRM_Contract__c[] newCon = [SELECT ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id LIMIT 1];
            
            Test.startTest();
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(newCon);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContractCopyCtl controllerCopy = new ASI_CRM_MY_ContractCopyCtl(standardSetCtl);
            controllerCopy.save();
            
            //Press the terminate button
            ASI_CRM_MY_ContractTerminateCtl controllerTerm = new ASI_CRM_MY_ContractTerminateCtl(standardSetCtl);
            controllerTerm.save();
            controllerTerm.forTestClass();
            controllerTerm.save();
            Test.stopTest(); 
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT id, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id and ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            update con;
            
            con.ASI_TH_CRM_End_Date__c = date.newinstance(2015, 1, 1);
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            sku1.Name = 'sku2';
            update sku1;
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            ASI_CRM_ContractTarget__c ct = new ASI_CRM_ContractTarget__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget'));
            insert ct;
            
            ASI_CRM_ContractSalesStaffIncentive__c ss = new ASI_CRM_ContractSalesStaffIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_MY_SalesStaffIncentive'));
            insert ss;
            
            ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MY_VolumeIncentive'));
            insert vi;   
            
            update ct;
            update ss;
            update vi;
            
            delete con;
        }
    }
    
    static testMethod void insertContract_TEST2() {
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');

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
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            
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
            
            //contract.date.newinstance(2015, 1, 1);
            
            //Press the copy button
            ASI_TH_CRM_Contract__c[] newCon = [SELECT ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id LIMIT 1];
            
            Test.startTest();
          
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(newCon);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContractCopyCtl controllerCopy = new ASI_CRM_MY_ContractCopyCtl(standardSetCtl);
            controllerCopy.save();
            
            //Press the terminate button
            ASI_CRM_MY_ContractTerminateCtl controllerTerm = new ASI_CRM_MY_ContractTerminateCtl(standardSetCtl);
            controllerTerm.save();
            controllerTerm.forTestClass();
            controllerTerm.save();
            
            Test.stopTest();
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT id, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id and ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', ASI_CRM_Type__c = 'Type', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive'));
            insert oi;
            
            ASI_CRM_PromoterPlacement__c pp = new ASI_CRM_PromoterPlacement__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PromoterPlacement__cASI_CRM_MY_PromoterPlacement'));
            insert pp;
            
            update oi;
            update pp;
           
            delete con;
             
        }
    }
    
    static testMethod void insertContract_TEST3() {
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');

        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        //userA.BypassVR__c = TRUE;
        //userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        //update userA;
        
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
            
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
       
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
                  
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Press the copy button
            ASI_TH_CRM_Contract__c[] newCon = [SELECT ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id LIMIT 1];
      
            newCon[0].ASI_TH_CRM_Contract_Status__c = 'Final';
            update newCon;
            
            
            newCon[0].ASI_TH_CRM_Contract_Status__c = 'Draft';
            update newCon;
            
      Test.startTest();
            
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(newCon);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContractCopyCtl controllerCopy = new ASI_CRM_MY_ContractCopyCtl(standardSetCtl);
            controllerCopy.save();
            
            //Press the terminate button
            ASI_CRM_MY_ContractTerminateCtl controllerTerm = new ASI_CRM_MY_ContractTerminateCtl(standardSetCtl);
            controllerTerm.save();
            controllerTerm.forTestClass();
            controllerTerm.save();
            
            Test.stopTest(); 
        }
    }
    
    static testMethod void contractBuilder_TEST() {
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
        
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        
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
        
        //Create SKU
        ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
        ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
        //ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2');
        //Create AC code - Contract Setup Code
        ASI_CRM_MY_TestClassHelper.createContractSetupCode();
        
        ASI_TH_CRM_Contract__c con = [SELECT id, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c, RecordTypeId FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id and ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];
        
        
        // Create contract target
        ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 10);
        
        // Create contract volume incentive 
        ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
        
        // Create Contract Sales & Staff Incentive
        ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
        
        // Create Contract Other Incentive
        //ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1);
    
        Test.startTest();
        ApexPages.StandardController standardSCtl = new ApexPages.StandardController(con);
        ApexPages.currentpage().getparameters().put('id', con.id);
        ASI_CRM_MY_ContractBuilderCtl controllerBuilder = new ASI_CRM_MY_ContractBuilderCtl(standardSCtl);
        //controllerBuilder.generateRandomString();
        controllerBuilder.getSubBrandSelectOptions();
        controllerBuilder.skuNameFilter = 'sku1';
        controllerBuilder.retrieveSKUbySubBrand();
        controllerBuilder.skuNameFilter = 'sku1';
        controllerBuilder.subBrandSelected = 'TEST';
        controllerBuilder.retrieveSKUbySubBrand();
        controllerBuilder.selectContractSKUForChangeSS();
        controllerBuilder.cancelContractSKUChangeSS();
        controllerBuilder.changeContractCrossBrandSKUSS();
        controllerBuilder.cloneContractSKUOther();
        controllerBuilder.retrieveSKUbySubBrandSS();
        controllerBuilder.addMerchandisingContract();
        
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', (String)sku1.id);
        controllerBuilder.addContractProductItem();
        controllerBuilder.saveContract();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', (String)sku1.id);
        controllerBuilder.removeContractSKU();
        
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SKU_ID', (String)sku1.id);
        controllerBuilder.addContractProductItem();
        controllerBuilder.saveContract();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SKU_ID', (String)sku1.id);
        controllerBuilder.removeContractSKU();
        
        controllerBuilder.skuNameFilterOther = 'sku1';
        controllerBuilder.retrieveSKUbySubBrandOther();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID_OTHER', (String)sku1.id);
        controllerBuilder.addContractProductItemOther();
        
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID_OTHER', (String)sku1.id);
        controllerBuilder.removeContractSKUOther();
        
        controllerBuilder.skuNameFilterPP = 'sku1';
        controllerBuilder.retrieveSKUbySubBrandPP();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID_PromoterPlacements', (String)sku1.id);
        controllerBuilder.addContractProductItemPromoterPlacements();
        
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID_PromoterPlacements', (String)sku1.id);
        controllerBuilder.removeContractSKUPromoterPlacements();
        
        controllerBuilder.saveContract();
       //  Map<String, ASI_MFM_SKU_Code__c> tempMap = new Map<String, ASI_MFM_SKU_Code__c>({'PARAM_CONTRACT_SOURCE_ITEM_ID_PromoterPlacements',})
       System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', (String)sku1.id);
        controllerBuilder.allSKUMap.put((String)sku1.id,sku1);
        controllerBuilder.addContractProductItem();
             Test.stopTest();
    }
    
    static testMethod void contractSummary_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
        
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            
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
            
            //contract.date.newinstance(2015, 1, 1);
            
            //Press the copy button
            ASI_TH_CRM_Contract__c[] newCon = [SELECT ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id LIMIT 1];
            
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(newCon);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContractCopyCtl controllerCopy = new ASI_CRM_MY_ContractCopyCtl(standardSetCtl);
            controllerCopy.save();
            
            //Press the terminate button
            ASI_CRM_MY_ContractTerminateCtl controllerTerm = new ASI_CRM_MY_ContractTerminateCtl(standardSetCtl);
            controllerTerm.save();
            controllerTerm.forTestClass();
            controllerTerm.save();
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT id, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id and ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            update con;
            
            con.ASI_TH_CRM_End_Date__c = date.newinstance(2015, 1, 1);
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            ASI_CRM_ContractTarget__c ct = new ASI_CRM_ContractTarget__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget'));
            insert ct;
            
            ASI_CRM_ContractSalesStaffIncentive__c ss = new ASI_CRM_ContractSalesStaffIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_MY_SalesStaffIncentive'));
            insert ss;
            
            ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MY_VolumeIncentive'));
            insert vi;
            
            ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', ASI_CRM_Type__c = 'Type', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive'));
            insert oi;
            
            ASI_CRM_PromoterPlacement__c pp = new ASI_CRM_PromoterPlacement__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PromoterPlacement__cASI_CRM_MY_PromoterPlacement'));
            insert pp;
            
            Test.startTest();
            ApexPages.StandardController standardSCtl = new ApexPages.StandardController(Con);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContractSummaryCtl controllerSummary = new ASI_CRM_MY_ContractSummaryCtl(standardSCtl);
            controllerSummary.getSSIncentive();
            
            ASI_CRM_MY_DBC_Ctl controllerDBC = new ASI_CRM_MY_DBC_Ctl(standardSCtl);
            //controllerDBC.genEstROI(contract.id);
            
            ApexPages.currentpage().getparameters().put('Type', 'DBCa');
            ASI_CRM_MY_DBC_Ctl controllerDBCA = new ASI_CRM_MY_DBC_Ctl(standardSCtl);
            ASI_CRM_MY_ContractCopyCtl controllerCopy1 = new ASI_CRM_MY_ContractCopyCtl(standardSetCtl);
            controllerCopy1.isTestError = true;
            controllerCopy1.save();
            Test.stopTest();
        }
    }
    
    
    static testMethod void contractReport_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
          
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            integer y = today.year();
            integer m = today.month();
          
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
      
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                            id, 
                                            ASI_CRM_Terminate__c, 
                                            ASI_CRM_Obsolete_Version__c, 
                                            ASI_TH_CRM_End_Date__c, 
                                            ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 10);
            
            // Create contract volume incentive 
            ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
            
            // Create Contract Sales & Staff Incentive
            ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
            
            // Create Contract Other Incentive
            ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1);
            
            // Create Promoter Placement
            ASI_CRM_PromoterPlacement__c pp = ASI_CRM_MY_TestClassHelper.createPromoterPlacement(con, sku1);
            
            Test.startTest();
            ApexPages.StandardController standardSCtl = new ApexPages.StandardController(Con);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContractSummaryCtl controllerSummary = new ASI_CRM_MY_ContractSummaryCtl(standardSCtl);
            controllerSummary.getSSIncentive();
            
            
            ApexPages.currentpage().getparameters().put('Type', 'DBCe');
            ASI_CRM_MY_DBC_Ctl controllerDBCe = new ASI_CRM_MY_DBC_Ctl(standardSCtl);
            //controllerDBC.genEstROI(contract.id);
            
            
            //ApexPages.currentpage().getparameters().put('Type', 'DBCa');
            ASI_CRM_MY_DBC_Ctl controllerDBCA = new ASI_CRM_MY_DBC_Ctl(standardSCtl);
            Test.stopTest();
            
        }
    }
    
    
    static testMethod void contractComparisonReport_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
          
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            integer y = today.year();
            integer m = today.month();
          
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
      
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                            id, 
                                            ASI_CRM_Terminate__c, 
                                            ASI_CRM_Obsolete_Version__c, 
                                            ASI_TH_CRM_End_Date__c, 
                                            ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 10);
            
            // Create contract volume incentive 
            ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
            
            // Create Contract Sales & Staff Incentive
            ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
            
            // Create Contract Other Incentive
            ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1);
            
            // Create Promoter Placement
            ASI_CRM_PromoterPlacement__c pp = ASI_CRM_MY_TestClassHelper.createPromoterPlacement(con, sku1);
            
            Test.startTest();
            
            ApexPages.StandardController standardSCtl = new ApexPages.StandardController(Con);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_DBCComparison_Ctl controllerDBCComparison = new ASI_CRM_MY_DBCComparison_Ctl(standardSCtl);
            Test.stopTest();
        }
    }
    
    static testMethod void contractContributionPerCase_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
          
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            integer y = today.year();
            integer m = today.month();
          
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
      
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                            id, 
                                            ASI_CRM_Terminate__c, 
                                            ASI_CRM_Obsolete_Version__c, 
                                            ASI_TH_CRM_End_Date__c, 
                                            ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            ASI_MFM_SKU_Code__c sku3 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 10);
            ASI_CRM_ContractTarget__c ct2 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku2, 100);
            ASI_CRM_ContractTarget__c ct3 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku3, 0);
                        
            // Create Contract Sales & Staff Incentive
            ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
            ASI_CRM_ContractSalesStaffIncentive__c  ss2 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku2);
            ASI_CRM_ContractSalesStaffIncentive__c  ss3 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku3);
            
            // Create contract volume incentive 
            ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
            ASI_CRM_ContractVolumeIncentive__c vi2 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku2);
            ASI_CRM_ContractVolumeIncentive__c vi3 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku3);
            
            // Create Contract Other Incentive
            ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1, 'Events Sponsors');
            ASI_CRM_ContractOtherIncentive__c oi2 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku2, 'Up Front');
            ASI_CRM_ContractOtherIncentive__c oi3 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku3, 'Anniversary');
            
            // Create Promoter Placement
            ASI_CRM_PromoterPlacement__c pp = ASI_CRM_MY_TestClassHelper.createPromoterPlacement(con, sku1);
            
            Test.startTest();
             
            ApexPages.StandardController standardSCtl = new ApexPages.StandardController(Con);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContributionPerCase_Ctl contributionPerCase = new ASI_CRM_MY_ContributionPerCase_Ctl(standardSCtl);
            
            Test.stopTest();
        }
    }
    
    
    static testMethod void contractPrint_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
          
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            integer y = today.year();
            integer m = today.month();
          
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
      
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            
            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT 
                                            id, 
                                            ASI_CRM_Terminate__c, 
                                            ASI_CRM_Obsolete_Version__c, 
                                            ASI_TH_CRM_End_Date__c, 
                                            ASI_TH_CRM_Contract_Status__c 
                                          FROM ASI_TH_CRM_Contract__c 
                                          WHERE id = :contract.id 
                                          and ASI_TH_CRM_Contract_Status__c = 'Draft' 
                                          LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            ASI_MFM_SKU_Code__c sku3 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 10);
            ASI_CRM_ContractTarget__c ct2 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku2, 100);
            ASI_CRM_ContractTarget__c ct3 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku3, 0);
                        
            // Create Contract Sales & Staff Incentive
            ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
            ASI_CRM_ContractSalesStaffIncentive__c  ss2 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku2);
            ASI_CRM_ContractSalesStaffIncentive__c  ss3 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku3);
            
            // Create contract volume incentive 
            ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
            ASI_CRM_ContractVolumeIncentive__c vi2 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku2);
            ASI_CRM_ContractVolumeIncentive__c vi3 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku3);
            
            // Create Contract Other Incentive
            ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1, 'Events Sponsors');
            ASI_CRM_ContractOtherIncentive__c oi2 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku2, 'Up Front');
            ASI_CRM_ContractOtherIncentive__c oi3 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku3, 'Anniversary');
            
            // Create Promoter Placement
            ASI_CRM_PromoterPlacement__c pp = ASI_CRM_MY_TestClassHelper.createPromoterPlacement(con, sku1);
            
            Test.startTest();
            ApexPages.StandardController standardSCtl = new ApexPages.StandardController(Con);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MY_ContractPrintSetupCtrl contractPrint = new ASI_CRM_MY_ContractPrintSetupCtrl(standardSCtl);
            contractPrint.getUpfrontAmt();
            contractPrint.downloadContract();
            contractPrint.returnToContract();
            contractPrint.saveUpdates();
            
            ASI_CRM_MY_ContractPrintOutCtrl contractPrintOutCtrl = new ASI_CRM_MY_ContractPrintOutCtrl();
            Test.stopTest();
                
        }
    }
    
    static testMethod void insertContractWithoutByPass_Test(){
         User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
     //   userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
          
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
 
            integer y = today.year();
            integer m = today.month();
          
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
      
            customer1.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customer1;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customer1, today);
            update contract;
            delete contract;
        }
    }
}
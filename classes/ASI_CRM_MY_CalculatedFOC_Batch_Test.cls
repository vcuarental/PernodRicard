@isTest
public class ASI_CRM_MY_CalculatedFOC_Batch_Test {
    static testMethod void suggestedFOC_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Contract_Final' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        
        Group gp2 = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Offtake_Adjustment' LIMIT 1];
        GroupMember Gm2 = new GroupMember();
        GM2.GroupId = gp2.id;
        GM2.UserOrGroupId = userA.Id;
        
        GMList.add(GM2);
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
            
            ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
            Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
            Integer intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;
            
            integer y = today.year();
            integer m = today.month();
            
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            //ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            ASI_CRM_AccountsAdditionalField__c customerParent = ASI_CRM_MY_TestClassHelper.createParentCustomer('customerParent', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createChildrenCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet', customerParent);
            
            customerParent.ASI_CRM_CN_Inactive_Flag__c = FALSE;
            update customerParent;
            
            ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customerParent, today, true);
            
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
            //update con;
            
            con.ASI_CRM_Terminate__c = false;
            con.ASI_CRM_Obsolete_Version__c = false;
            //update con;
            
            con.RecordTypeid = idRT_ContractFinal;
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_MY_TestClassHelper.createSKU('sku2', productCategory);
            ASI_MFM_SKU_Code__c sku3 = ASI_CRM_MY_TestClassHelper.createSKU('sku3', productCategory);
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            ASI_CRM_SKU_Group__c skuGroup = ASI_CRM_MY_TestClassHelper.createSKUGroup(sku1);
            //sku1.ASI_CRM_SKU_Group__c = skuGroup.Id;
            sku1.ASI_CRM_SKU_Group_Code__c = 'BLE130';
            sku1.ASI_MFM_SKU_Code__c = 'BLE130';
            update sku1;
            
            
            Date perviousDate = today.addMonths(-1);
            String strPY = String.valueOf(perviousDate.year());
            String strPM = String.valueOf(perviousDate.month());
            strPM = strPM.length() == 1 ? '0' + strPM : strPM;
            
            // create calculated foc header             
            ASI_CRM_Calculated_FOC__c foc = ASI_CRM_MY_TestClassHelper.createCalculatedFOC(customer1, con, strPY, strPM, userA);
            
            // create calculated foc line   
            ASI_CRM_Calculated_FOC_Line__c focLine = ASI_CRM_MY_TestClassHelper.createCalculatedFOCLine(foc, sku1);
            
            // create calculated payment 
            ASI_CRM_Calculated_Payment__c calPayment = ASI_CRM_MY_TestClassHelper.createCalculatedPayment(customer1, con, strPY, strPM, userA, 'Other Incentive');
            
            // create calculated payment line   
            ASI_CRM_Calculated_Payment_Item__c calPaymentLine = ASI_CRM_MY_TestClassHelper.createCalculatedPaymentLine(calPayment, sku1);
            
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 20);
            ASI_CRM_ContractTarget__c ct2 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku2, 100);
            ASI_CRM_ContractTarget__c ct3 = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku3, 0);
            
            // Create contract volume incentive 
            ASI_CRM_ContractVolumeIncentive__c vi = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku1);
            ASI_CRM_ContractVolumeIncentive__c vi2 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku2);
            ASI_CRM_ContractVolumeIncentive__c vi3 = ASI_CRM_MY_TestClassHelper.createContractVolumeIncentive(con, sku3);
            
            // Create Contract Sales & Staff Incentive
            ASI_CRM_ContractSalesStaffIncentive__c  ss = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku1);
            ASI_CRM_ContractSalesStaffIncentive__c  ss2 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku2);
            ASI_CRM_ContractSalesStaffIncentive__c  ss3 = ASI_CRM_MY_TestClassHelper.createContractSalesStaffIncentive(con, sku3);
            
            
            // Create Contract Other Incentive
            ASI_CRM_ContractOtherIncentive__c oi = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku1);
            ASI_CRM_ContractOtherIncentive__c oi2 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku2);
            ASI_CRM_ContractOtherIncentive__c oi3 = ASI_CRM_MY_TestClassHelper.createContractOtherVolumeIncentive(con, sku3);
            
            //ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            
            //ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1');
            
            
            // Create Actual Offtake Header
            ASI_CRM_ActualOfftakeHeader__c Offtake_H = ASI_CRM_MY_TestClassHelper.createActualOfftakeHeader(customer1, today);
            
            
            // Create Actual Offtake 
            ASI_TH_CRM_Actual_Offtake__c Offtake_L = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku1, customerParent, today, 'INV01', 100);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L2 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku2, customerParent, today, 'INV02', 600);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L3 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku3, customerParent, today, 'INV03', 100);
            
            
            ASI_CRM_MY_CalculatedFOC_Schedule schCtl = new ASI_CRM_MY_CalculatedFOC_Schedule();
            schCtl.genFOC();
            
            ASI_CRM_MY_CalculatedPayment_Schedule payment_sch = new ASI_CRM_MY_CalculatedPayment_Schedule();
            payment_sch.genCalculatedPayment();
            
            ASI_CRM_MY_SKUGroupUpdate_Schedule skuGroupUpdate_sch = new ASI_CRM_MY_SKUGroupUpdate_Schedule();
            String sch = '0 0 * * * ?'; 
            system.schedule('SKUGroupUpdateTest', sch, skuGroupUpdate_sch); 
            
            
            //ASI_CRM_MY_SKU_TriggerClass sku_triggerClass = new ASI_CRM_MY_SKU_TriggerClass();
            //sku_triggerClass.l_NewMappedSKU.add(sku1);
        }
    }
}
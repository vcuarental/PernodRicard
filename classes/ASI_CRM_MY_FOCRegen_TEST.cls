@isTest
public class ASI_CRM_MY_FOCRegen_TEST {

    static testMethod void focRegen_TEST() {
        
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
            
            
            Date perviousDate = today.addMonths(-3);
            String strPY = String.valueOf(perviousDate.year());
            String strPM = String.valueOf(perviousDate.month());
            strPM = strPM.length() == 1 ? '0' + strPM : strPM;
            
            
            // Create Actual Offtake Header
            ASI_CRM_ActualOfftakeHeader__c Offtake_H = ASI_CRM_MY_TestClassHelper.createActualOfftakeHeader2(customer1, perviousDate);
            system.debug('@@@Offtake_H: '+Offtake_H);
            
            // Create Actual Offtake 
            ASI_TH_CRM_Actual_Offtake__c Offtake_L = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku1, customer1, perviousDate, 'INV01', 400);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L2 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku2, customer1, perviousDate, 'INV02', 100);
            ASI_TH_CRM_Actual_Offtake__c Offtake_L3 = ASI_CRM_MY_TestClassHelper.createActualOfftake(Offtake_H, sku3, customer1, perviousDate, 'INV03', 100);
            
            
            // Create contract target
            ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(con, sku1, 10);
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
            
            Test.startTest();
            ASI_CRM_MY_FOCRegen_Ctl focRegrn = new ASI_CRM_MY_FOCRegen_Ctl();
            focRegrn.AOH1 = Offtake_H;
            system.debug('@@@strPY: '+strPY);
            system.debug('@@@strPM: '+strPM);
            focRegrn.strYear = strPY;
            focRegrn.strMonth = strPM;
            focRegrn.doChange();
            focRegrn.doRegenFOC();
            
            focRegrn.doUnlockCalculatePayment();
            focRegrn.doRegenCalculatedPayment();
            Test.stopTest();
        }
    }
}
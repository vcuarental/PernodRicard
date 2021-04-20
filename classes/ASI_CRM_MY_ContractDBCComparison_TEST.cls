@isTest
public class ASI_CRM_MY_ContractDBCComparison_TEST {
	
    static testMethod void contractDBCComparison_TEST() {
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
    
}
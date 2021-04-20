/*********************************************************************************
 * Name:ASI_CRM_SG_AssignContractToOfftake_Test
 * Description: Test class for ASI_CRM_SG_AssignContractToOfftake_Batch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-12-29       Laputa: Hugo Cheung     Created
 * 2017-08-02       Wilken Lee			    [WL 1.0] Modified to increase coverage for P3 offtake to contract linkage enhancement
*********************************************************************************/
@isTest
public class ASI_CRM_SG_AssignContractToOfftake_Test {

	private static final String OFFTAKE_RECORD_TYPE = 'ASI_CRM_SG_Actual_offtake';

	@TestSetup
	public static void setupTestData() {
		ASI_CRM_SG_TestClassHelper.createDataSettings();
		List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
		List<ASI_MFM_SKU_Code__c> skuList       = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList);

		ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true, 'Testing');
		ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(false, customerData.customer, 'isApproved');
		insert contractData.contract;

		ASI_CRM_SG_TestClassHelper.createPaymentSchedule(contractData.contract);

		List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
		List<ASI_TH_CRM_Actual_Offtake__c> offtakeList     = new List<ASI_TH_CRM_Actual_Offtake__c>();
		for(ASI_MFM_SKU_Code__c sku : skuList) {
			ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractData.contract, sku);
			ASI_CRM_SG_TestClassHelper.offtakeData offtakeData               = new ASI_CRM_SG_TestClassHelper.offtakeData(false, OFFTAKE_RECORD_TYPE, null, customerData.customer.Id, sku.Id);
			contractTargetList.add(contractTargetData.contractTarget);
			offtakeList.add(offtakeData.offtake);
		}
		insert contractTargetList;
		insert offtakeList;
        system.debug([SELECT Id, ASI_CRM_Contract__c, ASI_TH_CRM_Actual_Offtake_External_ID__c FROM ASI_TH_CRM_Actual_Offtake__c]);

	}

	static testMethod void testAssignContractToOfftake() {
		Test.startTest();
        	Database.executeBatch(new ASI_CRM_SG_AssignContractToOfftake_Batch());
        Test.stopTest();

		List<ASI_TH_CRM_Actual_Offtake__c> offtakeList = [SELECT Id, ASI_CRM_Contract__c FROM ASI_TH_CRM_Actual_Offtake__c];
		ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];

		for(ASI_TH_CRM_Actual_Offtake__c offtake : offtakeList) {
			System.assertEquals(offtake.ASI_CRM_Contract__c, contract.Id);
		}

	}

	//Refer to UAT Test Case "A19 Offtake Linkage Test Case Summary.xlsx" for test case
	static testMethod void testAssignContractToOfftakeP3() {
		//PROS Test Data
		ASI_CRM_Group_Outlet_Type__c grpOutletType = new ASI_CRM_Group_Outlet_Type__c(ASI_CRM_SG_Group_Outlet_Name__c= 'Offtrade', recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Group_Outlet_Type__cASI_CRM_SG_Group_Outlet_Type'));
		insert grpOutletType;
		
		//Outlet Test Data
		List<ASI_CRM_AccountsAdditionalField__c> custList = new List<ASI_CRM_AccountsAdditionalField__c>();
		ASI_CRM_AccountsAdditionalField__c cust1 = new ASI_CRM_AccountsAdditionalField__c(Name='GUO HUI KTV PTE LTD (17523)', ASI_CRM_MY_CustomerCode__c = '17523', ASI_CRM_Active__c = true, ASI_CRM_Business_Registration_Number__c = 'TestNum10' , ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'));
		ASI_CRM_AccountsAdditionalField__c cust2 = new ASI_CRM_AccountsAdditionalField__c(Name='LEISURE COURT KTV LOUNGE (K2) (17505)', ASI_CRM_MY_CustomerCode__c = '17505', ASI_CRM_Active__c = true, ASI_CRM_Business_Registration_Number__c = 'TestNum11' , ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'));
		ASI_CRM_AccountsAdditionalField__c cust3 = new ASI_CRM_AccountsAdditionalField__c(Name='VENUS JAPANESE KARAOKE PUB (31347)', ASI_CRM_MY_CustomerCode__c = '31347', ASI_CRM_Active__c = true, ASI_CRM_Business_Registration_Number__c = 'TestNum12' , ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'));
		ASI_CRM_AccountsAdditionalField__c cust4 = new ASI_CRM_AccountsAdditionalField__c(Name='New Test Customer', ASI_CRM_MY_CustomerCode__c = '30000', ASI_CRM_Active__c = true, ASI_CRM_Business_Registration_Number__c = 'TestNum12' , ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'));
		
		custList.add(cust1);
		custList.add(cust2);
		custList.add(cust3);
		custList.add(cust4);
		insert custList;
				
		//Contract Test Data
		List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
		ASI_TH_CRM_Contract__c contractA = new ASI_TH_CRM_Contract__c(ASI_CRM_CN_Outlet_WS__c = cust1.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved', ASI_TH_CRM_Start_Date__c = System.Today(), ASI_TH_CRM_End_Date__c = System.Today().addDays(30) , recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'), ASI_CRM_Type__c = 'Key Account');
		ASI_TH_CRM_Contract__c contractB = new ASI_TH_CRM_Contract__c(ASI_CRM_CN_Outlet_WS__c = cust1.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved', ASI_CRM_Ad_hoc_Contract__c = true, ASI_TH_CRM_Start_Date__c = System.Today(), ASI_TH_CRM_End_Date__c = System.Today().addDays(30) , recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'), ASI_CRM_Type__c = 'Key Account');
		ASI_TH_CRM_Contract__c contractC = new ASI_TH_CRM_Contract__c(ASI_CRM_CN_Outlet_WS__c = cust2.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved', ASI_TH_CRM_Start_Date__c = System.Today().addDays(-1), ASI_TH_CRM_End_Date__c = System.Today().addDays(30) , recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'), ASI_CRM_Type__c = 'Key Account');
		ASI_TH_CRM_Contract__c contractD = new ASI_TH_CRM_Contract__c(ASI_CRM_CN_Outlet_WS__c = cust2.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved', ASI_TH_CRM_Start_Date__c = System.Today(), ASI_TH_CRM_End_Date__c = System.Today().addDays(30) , recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'), ASI_CRM_Type__c = 'Key Account');
		ASI_TH_CRM_Contract__c contractE = new ASI_TH_CRM_Contract__c(ASI_CRM_CN_Outlet_WS__c = cust3.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved', ASI_TH_CRM_Start_Date__c = System.Today().addDays(-1), ASI_TH_CRM_End_Date__c = System.Today().addDays(30) , recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'), ASI_CRM_Type__c = 'Key Account');
		
		contractList.add(contractA);
		contractList.add(contractB);
		contractList.add(contractC);
		contractList.add(contractD);
		contractList.add(contractE);
		insert contractList;

		//Insert separately to allow a later createdDate than ContractE
		ASI_TH_CRM_Contract__c contractF = new ASI_TH_CRM_Contract__c(ASI_CRM_CN_Outlet_WS__c = cust3.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved', ASI_TH_CRM_Start_Date__c = System.Today().addDays(-1), ASI_TH_CRM_End_Date__c = System.Today().addDays(30) , recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'), ASI_CRM_Type__c = 'Key Account');
		insert contractF;

		//Normal scenario for one contract matched
		ASI_TH_CRM_Contract__c contractG = new ASI_TH_CRM_Contract__c(ASI_CRM_CN_Outlet_WS__c = cust4.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved', ASI_TH_CRM_Start_Date__c = System.Today().addDays(-1), ASI_TH_CRM_End_Date__c = System.Today().addDays(30) , recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'), ASI_CRM_Type__c = 'Key Account');
		insert contractG;

		
		//Sub-Brand Test Data
		List<ASI_MFM_Sub_brand__c> sbList = new List<ASI_MFM_Sub_brand__c>();
		ASI_MFM_Sub_brand__c sb1 = new ASI_MFM_Sub_brand__c(Name = 'Martell Cordon Bleu-ML2', ASI_MFM_Sub_brand_Code__c = 'ML2', recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
		ASI_MFM_Sub_brand__c sb2 = new ASI_MFM_Sub_brand__c(Name = 'Wyndham-BWE', ASI_MFM_Sub_brand_Code__c = 'BWE', recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand'));
		
		sbList.add(sb1);
		sbList.add(sb2);
		insert sbList;
		
		//SKU Test Data
		List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
		ASI_MFM_SKU_Code__c sku1 = new ASI_MFM_SKU_Code__c(Name = 'Martell Cordon Bleu 12x70cl Qt.-010401', ASI_MFM_SKU_Code__c = '010401', ASI_MFM_Sub_brand__c = sb1.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'));
		ASI_MFM_SKU_Code__c sku2 = new ASI_MFM_SKU_Code__c(Name = 'B333 Pinot Noir 09 12x75-WE4029', ASI_MFM_SKU_Code__c = 'WE4029', ASI_MFM_Sub_brand__c = sb2.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'));
		ASI_MFM_SKU_Code__c sku3 = new ASI_MFM_SKU_Code__c(Name = 'Martell CB New', ASI_MFM_SKU_Code__c = '010402', ASI_MFM_Sub_brand__c = sb1.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'));
		
		skuList.add(sku1);
		skuList.add(sku2);
		skuList.add(sku3);
		insert skuList;
		
		//SKU Mapping Test Data
		ASI_CRM_SKU_Mapping__c skuMapping = new ASI_CRM_SKU_Mapping__c(ASI_CRM_SKU__c = sku1.Id, ASI_CRM_New_SKU__c = sku3.Id, recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_SKU_Mapping__cSG_SKU_Mapping'));
		insert skuMapping;
		
		Test.startTest();
		//Contract Target Test Data
		List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
		ASI_CRM_SG_TestClassHelper.contractTargetData contTarget1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractA, sku1);
		ASI_CRM_SG_TestClassHelper.contractTargetData contTarget2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractB, sku1);
		ASI_CRM_SG_TestClassHelper.contractTargetData contTarget3 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC, sku1);
		ASI_CRM_SG_TestClassHelper.contractTargetData contTarget4 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractD, sku1);
		ASI_CRM_SG_TestClassHelper.contractTargetData contTarget5 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractE, sku1);
		ASI_CRM_SG_TestClassHelper.contractTargetData contTarget6 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractF, sku1);
		ASI_CRM_SG_TestClassHelper.contractTargetData contTarget7 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractG, sku1);
		
		List<ASI_CRM_ContractTarget__c> targetList = new List<ASI_CRM_ContractTarget__c>();
		targetList.add(contTarget1.contractTarget);
		targetList.add(contTarget2.contractTarget);
		targetList.add(contTarget3.contractTarget);
		targetList.add(contTarget4.contractTarget);
		targetList.add(contTarget5.contractTarget);
		targetList.add(contTarget6.contractTarget);
		targetList.add(contTarget7.contractTarget);
		insert targetList;		
		
		//Actual Offtake Test Data
		List<ASI_TH_CRM_Actual_Offtake__c> offtakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();
		ASI_TH_CRM_Actual_Offtake__c offtake1 = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_Actual_Offtake_External_ID__c = 'ABCDE_Offtake1' , ASI_CRM_SG_Customer__c = cust1.Id, ASI_CRM_SKU__c = sku1.Id, ASI_TH_CRM_Sub_brand__c = sb1.Id, ASI_TH_CRM_Offtake_G_L_Date__c = System.Today(), ASI_TH_CRM_Quantity__c = 12, recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'));
		ASI_TH_CRM_Actual_Offtake__c offtake2 = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_Actual_Offtake_External_ID__c = 'ABCDE_Offtake2' , ASI_CRM_SG_Customer__c = cust1.Id, ASI_CRM_SKU__c = sku2.Id, ASI_TH_CRM_Sub_brand__c = sb2.Id, ASI_TH_CRM_Offtake_G_L_Date__c = System.Today(), ASI_TH_CRM_Quantity__c = 12, recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'));
		ASI_TH_CRM_Actual_Offtake__c offtake3 = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_Actual_Offtake_External_ID__c = 'ABCDE_Offtake3' , ASI_CRM_SG_Customer__c = cust2.Id, ASI_CRM_SKU__c = sku1.Id, ASI_TH_CRM_Sub_brand__c = sb1.Id, ASI_TH_CRM_Offtake_G_L_Date__c = System.Today(), ASI_TH_CRM_Quantity__c = 12, recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'));
		ASI_TH_CRM_Actual_Offtake__c offtake4 = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_Actual_Offtake_External_ID__c = 'ABCDE_Offtake4' , ASI_CRM_SG_Customer__c = cust2.Id, ASI_CRM_SKU__c = sku2.Id, ASI_TH_CRM_Sub_brand__c = sb2.Id, ASI_TH_CRM_Offtake_G_L_Date__c = System.Today(), ASI_TH_CRM_Quantity__c = 12, recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'));
		ASI_TH_CRM_Actual_Offtake__c offtake5 = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_Actual_Offtake_External_ID__c = 'ABCDE_Offtake5' , ASI_CRM_SG_Customer__c = cust3.Id, ASI_CRM_SKU__c = sku1.Id, ASI_TH_CRM_Sub_brand__c = sb1.Id, ASI_TH_CRM_Offtake_G_L_Date__c = System.Today(), ASI_TH_CRM_Quantity__c = 12, recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'));
		ASI_TH_CRM_Actual_Offtake__c offtake6 = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_Actual_Offtake_External_ID__c = 'ABCDE_Offtake6' , ASI_CRM_SG_Customer__c = cust3.Id, ASI_CRM_SKU__c = sku2.Id, ASI_TH_CRM_Sub_brand__c = sb2.Id, ASI_TH_CRM_Offtake_G_L_Date__c = System.Today(), ASI_TH_CRM_Quantity__c = 12, recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'));
		ASI_TH_CRM_Actual_Offtake__c offtake7 = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_Actual_Offtake_External_ID__c = 'ABCDE_Offtake7' , ASI_CRM_SG_Customer__c = cust4.Id, ASI_CRM_SKU__c = sku2.Id, ASI_TH_CRM_Sub_brand__c = sb2.Id, ASI_TH_CRM_Offtake_G_L_Date__c = System.Today(), ASI_TH_CRM_Quantity__c = 12, recordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'));
		
		offtakeList.add(offtake1);
		offtakeList.add(offtake2);
		offtakeList.add(offtake3);
		offtakeList.add(offtake4);
		offtakeList.add(offtake5);
		offtakeList.add(offtake6);
		offtakeList.add(offtake7);
		insert offtakeList;
		
		
			Database.executeBatch(new ASI_CRM_SG_AssignContractToOfftake_Batch());
			
			Database.executeBatch(new ASI_CRM_SG_AssignContractToOfftake_Batch(cust1.Id));
			
			//ASI_CRM_SG_AssignContractToOfftake_Batch batchClass = new ASI_CRM_SG_AssignContractToOfftake_Batch();
			//batchClass.validateOfftakeMatchTargetSkuAndSB(offtake1, contTarget1.contractTarget);
        Test.stopTest();
	}
}
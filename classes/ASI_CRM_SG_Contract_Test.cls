/*********************************************************************************
 * Name:ASI_CRM_SG_Contract_Test
 * Description: Test all related code to the object Contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/02/2015       Laputa: Conrad          Created
 * 03/08/2016       Laputa: Hugo Cheung     Updated. Add test setup function. 
 * 2018-02-28	    Wilken Lee				[WL 1.0] Increase coverage for Build Contract Controller
*********************************************************************************/
@isTest
public class ASI_CRM_SG_Contract_Test {
    
    @TestSetup
    public static void setupTestData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        
        
        ASI_CRM_SG_TestClassHelper.customerData customerC1 = new ASI_CRM_SG_TestClassHelper.customerData(false, 'Customer1');
        ASI_CRM_SG_TestClassHelper.customerData customerC2 = new ASI_CRM_SG_TestClassHelper.customerData(false, 'Customer2');

        List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        customerList.add(customerC1.customer);
        customerList.add(customerC2.customer);
        insert customerList;

        ASI_CRM_SG_TestClassHelper.customerData customerC3 = new ASI_CRM_SG_TestClassHelper.customerData(true, customerC2.customer);

        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(false);
        ASI_CRM_SG_TestClassHelper.contractData contractC2 = new ASI_CRM_SG_TestClassHelper.contractData(false, customerC1.customer);
        ASI_CRM_SG_TestClassHelper.contractData contractC3 = new ASI_CRM_SG_TestClassHelper.contractData(false, customerC2.customer);

        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        contractList.add(contractC1.contract);
        contractList.add(contractC2.contract);
        contractList.add(contractC3.contract);
        insert contractList;

        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC1.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC2.contract, skuList.get(2));

        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC3 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC3.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC4 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC3.contract, skuList.get(2));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC5 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC3.contract, skuList.get(3), 100);
		/*[WL 1.0] BEGIN*/
		ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC6 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC3.contract, skuList.get(3), 9, null);
		ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC7 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC3.contract, skuList.get(3), 11, null);
		contractTargetC7.contractTarget.ASI_CRM_Sequence_No__c = 1;
        /*[WL 1.0] END*/
		
        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        contractTargetList.add(contractTargetC1.contractTarget);
        contractTargetList.add(contractTargetC2.contractTarget);
        contractTargetList.add(contractTargetC3.contractTarget);
        contractTargetList.add(contractTargetC4.contractTarget);
        contractTargetList.add(contractTargetC5.contractTarget);
		contractTargetList.add(contractTargetC6.contractTarget);
		contractTargetList.add(contractTargetC7.contractTarget);
        insert contractTargetList;
    }

    public static testmethod void testTrigger () {
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE Name = 'Customer1' LIMIT 1];
        List<ASI_CRM_ContractTarget__c> contractTargetList = [SELECT Id FROM ASI_CRM_ContractTarget__c WHERE ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name <> 'Customer2'];

        try {
            ASI_CRM_SG_TestClassHelper.contractData contractC3 = new ASI_CRM_SG_TestClassHelper.contractData(true, customer);
        } catch (exception ex) {
            //Catch the validation error for overlapping contract with the same customer date
        }
        
        delete contractTargetList;
    }
    
    public static testmethod void testBuildContractController () {
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE Name = 'Customer2' LIMIT 1];
        ASI_CRM_AccountsAdditionalField__c customer2 = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_CN_Parent_Outlet__r.Name = 'Customer2' LIMIT 1];

        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c WHERE ASI_CRM_CN_Outlet_WS__c =: customer.Id];

        ASI_MFM_SKU_Code__c sku = [SELECT Id, ASI_MFM_Sub_brand__c FROM ASI_MFM_SKU_Code__c WHERE Name = 'Test Sku 1'];

        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = ASI_CRM_SG_TestClassHelper.createPaymentSchedule(contract);
        
        test.starttest();
        PageReference pageRef = Page.ASI_CRM_SG_BuildContractPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', contract.id);
        ApexPages.currentPage().getParameters().put('IS_EDIT', 'TRUE');
        
        Test.setCurrentPageReference(new PageReference('Page.ASI_CRM_SG_BuildContractPage')); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        
        ASI_CRM_SG_BuildContractController buildContractCon = new ASI_CRM_SG_BuildContractController(sc);
        
		/*[WL 1.0 BEGIN]*/
		Id contractID = buildContractCon.contractId;
		String lineItemTablePrefix = ASI_CRM_SG_BuildContractController.CONTRACT_LINE_ITEM_TABLE_PREFIX;
		Map<String, Schema.SObjectField> fieldMap = buildContractCon.contractTargetFieldMap;
		String newRecordPrefix = ASI_CRM_SG_BuildContractController.CONTRACT_LINE_ITEM_NEWRECORD_PREFIX;
		Integer counter = buildContractCon.CONTRACT_LINE_ITEM_NEWRECORD_COUNTER;
		String requestPaymentId = buildContractCon.REQUESTEDPAYMENTID_VF;
		
		System.currentPageReference().getParameters().put('PARAM_CONTRACT_SUBBRAND_ID', (String)sku.ASI_MFM_Sub_brand__c);
		System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_TYPE', 'isSubBrand');
		buildContractCon.subBrandSelected = (String)sku.ASI_MFM_Sub_brand__c;
		buildContractCon.allSKUMap.put(sku.id, sku);
		/*[WL 1.0 END]*/
		
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', (String)sku.id);
        buildContractCon.retrieveSKUbySubBrand();
		buildContractCon.addContractProductItem();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_ID', 'zzzzzCONTRACTNEWZ0');
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SKU_ID', (String)sku.id);
        buildContractCon.removeContractSKU();
        buildContractCon.addCashSponsorship();
        buildContractCon.addContractSponsorship();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', (String)customer2.id);
        buildContractCon.addContractOutlet();
        buildContractCon.removeCashSponsorship();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_CUSTOMER_ID', (String)customer2.id);
        buildContractCon.removeContractOutlet();
        System.currentPageReference().getParameters().put('PARAM_PAYMENT_ID', 'zzzzzzPAYMENTSCHEDULENEWZ1');
        buildContractCon.removeContractSponsorship();
        buildContractCon.saveContract();
        buildContractCon.updateSubBrandPick();
        List<SelectOption> options = buildContractCon.getCategorySelectOptions();
        System.currentPageReference().getParameters().put('prevScheduleId', paymentScheduleList.get(0).Id);
        System.currentPageReference().getParameters().put('scheduleId', paymentScheduleList.get(1).Id);
        buildContractCon.requestPayment();
        System.currentPageReference().getParameters().put('prevScheduleId', null);
        System.currentPageReference().getParameters().put('scheduleId', paymentScheduleList.get(2).Id);
        buildContractCon.requestPayment();
        buildContractCon.cancel();
        
        test.stoptest();
    }
    
    public static testmethod void testProposalTrigger () {
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE Name = 'Customer1' LIMIT 1];
        ASI_CRM_SG_TestClassHelper.contractData contractD1 = new ASI_CRM_SG_TestClassHelper.contractData(false, customer);
        ASI_CRM_SG_TestClassHelper.contractData contractD2 = new ASI_CRM_SG_TestClassHelper.contractData(false, customer);

        contractD1.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        contractD2.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');

        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        contractList.add(contractD1.contract);
        contractList.add(contractD2.contract);
        
        test.startTest();
        insert contractList;
		 test.stopTest();
        
    }
    
    public static testmethod void testProposalUpdateTrigger () {
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE Name = 'Customer1' LIMIT 1];
        ASI_CRM_SG_TestClassHelper.contractData contractD1 = new ASI_CRM_SG_TestClassHelper.contractData(true, customer);
        ASI_CRM_SG_TestClassHelper.contractData contractD2 = new ASI_CRM_SG_TestClassHelper.contractData(true, customer);

        contractD1.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        contractD2.contract.recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        contractD1.contract.ASI_CRM_Revising__c  = true;
        contractD2.contract.ASI_CRM_Revising__c  = true;

        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        contractList.add(contractD1.contract);
        contractList.add(contractD2.contract);
        
        test.startTest();
        update contractList;
		 test.stopTest();
        
    }
    
}
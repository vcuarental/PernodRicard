/*********************************************************************************
 * Name: ASI_CRM_VN_CSRequestTest
 * Description: Test class for all CS request
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created          
 * 2018-11-28		Vincent Lam				IM004301
 * 2018-01-04       Andy Zhang              Create valid contract expenditure
*/
@isTest
public class ASI_CRM_VN_CSRequestTest {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;
        
        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;
         
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
    	insert onTradeCustomer;
       
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        insert actualOfftake;
        
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        insert contract;

        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;
        
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure.ASI_CRM_VN_Item__c                        = 'Lump Sum';
        contractExpenditure.ASI_CRM_VN_Payment_Times__c               = '3';
        contractExpenditure.ASI_CRM_VN_Achieved_Target_for_2nd_Pmt__c = 10;
        contractExpenditure.ASI_CRM_VN_Achieved_Target_for_3rd_Pmt__c = 40;
		// IM004301
        contractExpenditure.ASI_CRM_Achieved_Target_for_1st_Pmt__c = 5;
        contractExpenditure.ASI_CRM_VN_Amount__c = 1000;
        contractExpenditure.ASI_CRM_VN_Quantity__c = 1;
        contractExpenditure.ASI_CRM_Amount_for_1st_Payment__c = 200;
        contractExpenditure.ASI_CRM_Amount_for_2nd_Payment__c = 300;
        contractExpenditure.ASI_CRM_Amount_for_3rd_Payment__c = 500;
		
        insert contractExpenditure;
    }
    
    public static testMethod void testCSRequest() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        ASI_GiftBox_Request_Header__c csRequest = ASI_CRM_VN_TestClassHelper.createCSRequest(contract.Id);
        insert csRequest;
        
        csRequest.ASI_GiftBox_Status__c = 'Approved';
        update csRequest;
        
        delete csRequest;
    }
}
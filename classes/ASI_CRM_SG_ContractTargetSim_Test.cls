/*********************************************************************************
 * Name: ASI_CRM_SG_ContractTargetSim_Test
 * Description: Test Class for ASI_CRM_SG_ContractTargetSim_Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 16/05/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_SG_ContractTargetSim_Test {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        
        ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData wholesales = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        
        for(integer i = 0 ; i < 1 ; i++) {
        	ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(false, customerData.customer);
            contractData.contract.ASI_TH_CRM_Start_Date__c = Date.today();
            contractData.contract.ASI_TH_CRM_End_Date__c = Date.today().addMonths(12);
            contractList.add(contractData.contract);
        }
        insert contractList;
        
        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
        for(ASI_TH_CRM_Contract__c contract : contractList) {
        	ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contract, skuList.get(0));
            contractTargetList.add(contractTargetData.contractTarget);
            paymentScheduleList.addAll(ASI_CRM_SG_TestClassHelper.createPaymentSchedule(contract));
        }
        insert contractTargetList;
    }
    
    public static testMethod void testController() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        
        PageReference pageRef = Page.ASI_CRM_SG_ContractTargetSim_Page;
        Test.setCurrentPage(pageRef);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(contract);
		ApexPages.currentPage().getParameters().put('id', contract.id);
        ASI_CRM_SG_ContractTargetSim_Controller controller = new ASI_CRM_SG_ContractTargetSim_Controller(stdController);
        
        //Get JSON String
        String contractTargetListJson          = controller.contractTargetListJson;
        String cashPaymentScheduleListJson     = controller.cashPaymentScheduleListJson;
        String contractPaymentScheduleListJson = controller.contractPaymentScheduleListJson;
        String subBrandNameListJson            = controller.subBrandNameListJson;
        String skuPriceWrapperListJson         = controller.skuPriceWrapperListJson;
        String exceptionListJson               = controller.exceptionListJson;
        
        List<ASI_CRM_ContractTarget__c>  contractTargetList = (List<ASI_CRM_ContractTarget__c>) fromJsonString(contractTargetListJson, List<ASI_CRM_ContractTarget__c>.class);
        Set<Id> skuIdSet = new Set<Id>();
        for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
        	skuIdSet.add(contractTarget.ASI_CRM_SKU__c);
        }
        
		ApexPages.currentPage().getParameters().put('skuName', 'Test Sku 2');
        ApexPages.currentPage().getParameters().put('filterOutSKUIdListJson', toJsonString(skuIdSet));
        controller.searchSKU();
        
		ApexPages.currentPage().getParameters().put('contractTargetListJson', contractTargetListJson);
        controller.calculateROI();
        
		ApexPages.currentPage().getParameters().put('updateContractTargetListJson', contractTargetListJson);
		ApexPages.currentPage().getParameters().put('deleteContractTargetListJson', toJsonString(new List<Id>()));
		ApexPages.currentPage().getParameters().put('updatePaymentScheduleListJson', toJsonString(new List<ASI_CRM_Payment_Schedule__c>()));
		ApexPages.currentPage().getParameters().put('deletePaymentScheduleListJson', toJsonString(new List<Id>()));
		ApexPages.currentPage().getParameters().put('updateContractOutletListJson', toJsonString(new List<ASI_CRM_Contract_Outlets__c>()));
		ApexPages.currentPage().getParameters().put('deleteContractOutletListJson', toJsonString(new List<Id>()));
        controller.saveSimulation();
        
        controller.reviseContract();
        controller.deleteSimulation();
        controller.getInflationRate();
        controller.getDistributionRate();
        controller.cancel();
        
    }
    
    private static String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }
    
    private static Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }
}
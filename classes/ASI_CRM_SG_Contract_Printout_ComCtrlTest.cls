/*********************************************************************************
 * Name: ASI_CRM_SG_Contract_Printout_ComCtrlTest
 * Description: Test class for ASI_CRM_SG_Contract_Printout_ComCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/05/2017       Hugo Cheung             Created         
 * 28/11/2017       Jeffrey Cheung          Update coverage
*/
@isTest
public class ASI_CRM_SG_Contract_Printout_ComCtrlTest {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        
        ASI_CRM_SG_TestClassHelper.customerData customerData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.wholesalesCustomerData wholesales = new ASI_CRM_SG_TestClassHelper.wholesalesCustomerData(true);
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        
        for(integer i = 0 ; i < 2 ; i++) {
        	ASI_CRM_SG_TestClassHelper.contractData contractData = new ASI_CRM_SG_TestClassHelper.contractData(false, customerData.customer);
            contractData.contract.ASI_TH_CRM_Start_Date__c = Date.today();
            contractData.contract.ASI_TH_CRM_End_Date__c = Date.today().addMonths(12);
            contractData.contract.ASI_CRM_Contract_Exist_Before_RTM__c = true;
            contractList.add(contractData.contract);
        }
        insert contractList;
        
        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            for(ASI_MFM_SKU_Code__c sku : skuList) {
                ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contract, sku);
                contractTargetData.contractTarget.ASI_CRM_SG_Sales_Incentive__c = 100;
                contractTargetData.contractTarget.ASI_CRM_SG_Events_Free_Bottles__c = 4;
                contractTargetData.contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c = 5;
                contractTargetData.contractTarget.ASI_CRM_SG_Management_Incentives__c = 20;
                contractTargetData.contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c = 3;
                contractTargetList.add(contractTargetData.contractTarget);
            }
        }
        insert contractTargetList;
        
        for(ASI_TH_CRM_Contract__c contract : contractList) {
        	List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = ASI_CRM_SG_TestClassHelper.createPaymentSchedule(contract);
        }
        
    }
    
    static testMethod void testPDFComponentController() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        
        ASI_CRM_SG_Contract_Printout_ComCtrl contractPrintoutCom = new ASI_CRM_SG_Contract_Printout_ComCtrl();
        contractPrintoutCom.contractId = contract.Id;
        contractPrintoutCom.isEditable = true;
        contractPrintoutCom.isExternal = true;
        Boolean isInit = contractPrintoutCom.isPageInit;
        ASI_CRM_SG_Contract_Printout_ComCtrl.saveTemplate(
            'back', 
            contract.Id, 
            '', 
            '', 
            '', 
            '', 
            toJsonString(new List<String>()), 
            toJsonString(new List<String>()), 
            toJsonString(new List<String>()), 
            toJsonString(new List<String>()), 
            toJsonString(new List<String>()), 
            toJsonString(new List<String>()));
        ASI_CRM_SG_Contract_Printout_ComCtrl.savePDFtoContract(contract.Id);
    }
    
    static testMethod void testPDFController() {        
    	ASI_CRM_SG_Contract_Printout_Controller pdfController = new ASI_CRM_SG_Contract_Printout_Controller();
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
    
    static testMethod void numberToWordTest(){
        ASI_CRM_SG_Contract_Printout_ComCtrl controller = new ASI_CRM_SG_Contract_Printout_ComCtrl();
        String result;
        
        result = controller.numberToWord(1);
        System.assertEquals('one', result);
        result = controller.numberToWord(21);
        System.assertEquals('twenty-one', result);
        result = controller.numberToWord(50);
        System.assertEquals('fifty', result);

    }
    
}
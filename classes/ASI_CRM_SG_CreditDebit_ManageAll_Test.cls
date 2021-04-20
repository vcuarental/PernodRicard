/*********************************************************************************
 * Name: ASI_CRM_SG_CreditDebit_ManageAll_Test
 * Description: Test Class for ASI_CRM_SG_CreditDebit_ManageAll_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 16/05/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_SG_CreditDebit_ManageAll_Test {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        
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
        for(ASI_TH_CRM_Contract__c contract : contractList) {
        	ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetData = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contract, skuList.get(0));
            contractTargetList.add(contractTargetData.contractTarget);
        }
        insert contractTargetList;
        
     	ASI_CRM_SG_TestClassHelper.creditDebitNoteData creditDebitNoteData = new ASI_CRM_SG_TestClassHelper.creditDebitNoteData(true, contractList.get(0), customerData.customer, wholesales.customer);
        
        List<ASI_CRM_Credit_Debit_Note_Line_Item__c> creditDebitNoteLineItemList = new List<ASI_CRM_Credit_Debit_Note_Line_Item__c>();
        for(ASI_MFM_Sub_brand__c subBrand : subBrandList) {
            ASI_CRM_SG_TestClassHelper.creditDebitNoteLineItemData creditDebitNoteLineItemData = new ASI_CRM_SG_TestClassHelper.creditDebitNoteLineItemData(false, creditDebitNoteData.creditDebitNote, subBrand);
            creditDebitNoteLineItemList.add(creditDebitNoteLineItemData.creditDebitNoteLineItem);
        }
        insert creditDebitNoteLineItemList;
    }
    
    public static testMethod void testController() {
        ASI_CRM_Credit_Debit_Note__c creditDebitNote = [SELECT Id FROM ASI_CRM_Credit_Debit_Note__c LIMIT 1];
        
        PageReference pageRef = Page.ASI_CRM_SG_CreditDebit_ManageAll;
        Test.setCurrentPage(pageRef);
        
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(creditDebitNote);
		ApexPages.currentPage().getParameters().put('id', creditDebitNote.id);
        ASI_CRM_SG_CreditDebit_ManageAll_Ctrl controller = new ASI_CRM_SG_CreditDebit_ManageAll_Ctrl(stdController);
        
     	String lineItemListJson = controller.lineItemListJson;
        String searchSubBrandListJson = controller.searchSubBrandListJson;
        String exceptionListJson = controller.exceptionListJson;
        
        List<ASI_CRM_Credit_Debit_Note_Line_Item__c> creditDebitNoteLineItemList = (List<ASI_CRM_Credit_Debit_Note_Line_Item__c>) fromJsonString(lineItemListJson, List<ASI_CRM_Credit_Debit_Note_Line_Item__c>.class);
        for(ASI_CRM_Credit_Debit_Note_Line_Item__c creditDebitNoteLineItem : creditDebitNoteLineItemList) {
        	creditDebitNoteLineItem.ASI_CRM_Actual_Amount__c = -1;
        }
        lineItemListJson = toJsonString(creditDebitNoteLineItemList);
        
		List<Id> removeIdList = new List<Id>();
		removeIdList.add(creditDebitNoteLineItemList.get(0).id);
		
        ApexPages.currentPage().getParameters().put('updatelineItemListJson', lineItemListJson);
        ApexPages.currentPage().getParameters().put('deletelineItemListJson', toJsonString(removeIdList));
        controller.saveRecord();
        controller.cancel();
    }
    
    public static testMethod void testDeleteTrigger() {
        ASI_CRM_Credit_Debit_Note__c creditDebitNote = [SELECT Id FROM ASI_CRM_Credit_Debit_Note__c LIMIT 1];
        creditDebitNote.ASI_CRM_Status__c = 'Draft';
        update creditDebitNote;
        delete creditDebitNote;
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
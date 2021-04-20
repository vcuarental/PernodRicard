@isTest
public class ASI_CRM_PurchaseCont_ReportPageCtrlTest{
    
    @isTest(SeeAllData='true')
    static void testMethod1(){
        
        ASI_CRM_Purchase_Contract_ReportPageCtrl result = new ASI_CRM_Purchase_Contract_ReportPageCtrl();
        result.initializeRecordTypePickList();
        result.searchPurchaseContractReport();
        result.clonePurchaseContracts();
    }

}
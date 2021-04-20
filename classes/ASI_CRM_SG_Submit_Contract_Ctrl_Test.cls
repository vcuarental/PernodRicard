@isTest
public class ASI_CRM_SG_Submit_Contract_Ctrl_Test {
    public static TestMethod void test1(){
        ASI_CRM_SG_Archive_Contract_Ctrl_Test.createTestContractData();
         ASI_TH_CRM_Contract__c contract = [Select Id from ASI_TH_CRM_Contract__c limit 1]; 
        ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
        system.debug('@#debug'+sku1);
        SKU1.ASI_CRM_Preset__c = true;
        update SKU1;
       
        test.startTest();
        ASI_CRM_SG_Submit_Contract_Ctrl.submitValidate(contract.Id);
         ASI_CRM_ContractTarget__c ct = ASI_CRM_MY_TestClassHelper.createContractTarget(contract, sku1, 10);
        ASI_CRM_SG_Submit_Contract_Ctrl.preSubmitValidate(null);
        ASI_CRM_SG_Submit_Contract_Ctrl.preSubmitValidate(contract.Id);
        ct.ASI_CRM_Minimum_Sales_Cases__c = 2;
        ct.ASI_CRM_TargetCase__c = 3;
        update ct;
        ASI_MFM_Brand__c subbrand = [Select Id,ASI_CRM_Key_Account_Brand__c from ASI_MFM_Brand__c limit 1];
        subbrand.ASI_CRM_Key_Account_Brand__c = true;
        update subbrand;
        ASI_CRM_SG_Submit_Contract_Ctrl.preSubmitValidate(contract.Id);
        ASI_CRM_SG_Submit_Contract_Ctrl.submitValidate(contract.Id);
		contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
		update contract;    
        ASI_CRM_SG_Submit_Contract_Ctrl.submitValidate(contract.Id);
        string paymentRTid =  Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'); 
       List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
        ASI_CRM_Payment_Schedule__c paymentSchedule1 = new ASI_CRM_Payment_Schedule__c (
                                                                                               ASI_CRM_Percentof_achieved_Sales_Target__c = '20',
                                                                                               ASI_CRM_Contract__c = contract.Id,
                                                                                               ASI_CRM_Type__c = 'Cash Sponsorship',
                                                                                               ASI_CRM_Sponsorship__c = 10,
                                                                                                recordtypeid = paymentRTid
                                                                                       );
        paymentScheduleList.add(paymentSchedule1);
         ASI_CRM_Payment_Schedule__c paymentSchedule2 = new ASI_CRM_Payment_Schedule__c (
                                                                                               ASI_CRM_Percentof_achieved_Sales_Target__c = '20',
                                                                                               ASI_CRM_Contract__c = contract.Id,
                                                                                               ASI_CRM_Type__c = 'Contract Sponsorship',
                                                                                               ASI_CRM_Sponsorship__c = 20,
                                                                                                recordtypeid = paymentRTid
                                                                                       );
        paymentScheduleList.add(paymentSchedule2);
        insert paymentScheduleList;
         ASI_CRM_SG_Submit_Contract_Ctrl.submitValidate(contract.Id);
        contract.ASI_CRM_Type__c ='Key Account';
        contract.ASI_CRM_Contract_Exist_Before_RTM__c = false;
        update contract;
        ASI_CRM_SG_Submit_Contract_Ctrl.submitValidate(contract.Id);
        test.stopTest();
    }
}
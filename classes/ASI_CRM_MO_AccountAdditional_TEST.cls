@isTest
public class ASI_CRM_MO_AccountAdditional_TEST{

    static testMethod void ASI_CRM_MO_AccountAdditional_Triger_TEST() {
        ASI_CRM_AccountsAdditionalField__c customerMO = new ASI_CRM_AccountsAdditionalField__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet'));
        insert customerMO;
        customerMO.ASI_TH_CRM_OutletType__c = ASI_CRM_MO_TestClassHelper.createOutletType().id;
        update customerMO;
    }
}
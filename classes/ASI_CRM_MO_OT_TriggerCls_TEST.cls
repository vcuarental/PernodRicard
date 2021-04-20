@isTest
public class ASI_CRM_MO_OT_TriggerCls_TEST{

    static testMethod void ASI_CRM_MO_OT_TriggerCls_TEST() {
        ASI_CRM_MO_TestClassHelper.createRunningNumbers();
        Account acc1 = ASI_CRM_MO_TestClassHelper.createAccount('acc1');
        Id RTID_MO = Global_RecordTypeCache.getRTId('ASI_CRM_Fix_Approval_Route__cMO_Fix_Approval_Route');
        
        List<ASI_CRM_Fix_Approval_Route__c> lstAR = new List<ASI_CRM_Fix_Approval_Route__c>();
        lstAR.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Contract 1st Part', ASI_CRM_CN_Region_Area_Channel__c = 'Macau', ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approval_Limit_1__c = -20, RecordTypeId = RTID_MO));
        lstAR.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Contract 2nd Part', ASI_CRM_CN_Region_Area_Channel__c = 'Macau', ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approval_Limit_1__c = -30, RecordTypeId = RTID_MO));
        insert lstAR;
        ASI_TH_CRM_Contract__c contract = 
                new ASI_TH_CRM_Contract__c(
                    Name = 'Auto-generated Number',
                    ASI_TH_CRM_Outlet__c = acc1.id,
                    ASI_TH_CRM_Start_Date__c = date.newinstance(1997, 7, 1),
                    ASI_TH_CRM_End_Date__c = date.newinstance(2015, 6, 1),
                    ASI_TH_CRM_Contract_Status__c = 'Draft',
                    ASI_CRM_CN_Exchange_Rate__c = 1,
                    ASI_TH_CRM_Promotion_Type__c = 'Contract',
                    RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract')
                );
            
        insert contract;

        ASI_CRM_Investment_Payment__c ip = ASI_CRM_MO_TestClassHelper.createInvestmentPayment();
        ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MO_TestClassHelper.createSKU('sku1');
        
        ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c(ASI_CRM_Contract__c = contract.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Incentive_Point_Per_Bottle__c = 12, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MO_Volume_Incentive'));
        insert vi;   
        
        ASI_CRM_Contract_Cost__c ct = new ASI_CRM_Contract_Cost__c(Name = 'Auto', ASI_CRM_CN_Contract__c = contract.id, ASI_CRM_Investment_Payment__c = ip.id, ASI_CRM_CN_Cost_Type__c = 'Fixed', ASI_CRM_Investment_Value__c = 12, ASI_CRM_Payment_Schedule__c = 'all', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Cost__cASI_CRM_MO_Contract_Cost'));
        insert ct;   
        
        contract.ASI_TH_CRM_Contract_Status__c = 'Final';
        contract.ASI_CRM_Obsolete_Version__c = false;
        update contract;
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c ot = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c = acc1.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Quantity_Bottle__c = 1, ASI_TH_CRM_Date__c = date.newinstance(2014, 6, 1), recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MO_WSOfftakeDetail'));
        insert ot;
    }
}
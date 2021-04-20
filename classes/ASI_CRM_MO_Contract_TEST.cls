@isTest
public class ASI_CRM_MO_Contract_TEST{

    static testMethod void ASI_CRM_MO_Contract_TEST() {
        ASI_CRM_MO_TestClassHelper.createRunningNumbers();
        
        Map<String, Set<id>> map1 = new Map<String, Set<id>>();
        map1 = ASI_CRM_MO_Function.getMOGroup();
        
        boolean bol;
        bol = ASI_CRM_MO_Function.isGroupMember(userinfo.getuserid(), 'test', map1);
        
        Account acc1 = ASI_CRM_MO_TestClassHelper.createAccount('acc1');
        Id RTID_MO = Global_RecordTypeCache.getRTId('ASI_CRM_Fix_Approval_Route__cMO_Fix_Approval_Route');
        
        List<ASI_CRM_Fix_Approval_Route__c> lstAR = new List<ASI_CRM_Fix_Approval_Route__c>();
        lstAR.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Contract 1st Part', ASI_CRM_CN_Region_Area_Channel__c = 'Macau', ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approval_Limit_1__c = -20, RecordTypeId = RTID_MO));
        lstAR.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'Contract 2nd Part', ASI_CRM_CN_Region_Area_Channel__c = 'Macau', ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approval_Limit_1__c = -30, RecordTypeId = RTID_MO));
        insert lstAR;
        ASI_TH_CRM_Contract__c contract = 
                new ASI_TH_CRM_Contract__c(
                    Name = 'Auto-generated Number', 
                    ASI_TH_CRM_Start_Date__c = date.newinstance(1997, 7, 1),
                    ASI_TH_CRM_End_Date__c = date.newinstance(2015, 6, 1),
                    ASI_TH_CRM_Contract_Status__c = 'Draft',
                    ASI_CRM_CN_Exchange_Rate__c = 1,
                    ASI_TH_CRM_Promotion_Type__c = 'Contract',
                    RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract')
                );
            
        insert contract;
        
        //Press the copy button
            ASI_TH_CRM_Contract__c[] newCon = [SELECT ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id LIMIT 1];
            
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(newCon);
            ApexPages.currentpage().getparameters().put('id', contract.id);
            ASI_CRM_MO_ContractCopyCtl controllerCopy = new ASI_CRM_MO_ContractCopyCtl(standardSetCtl);
            controllerCopy.save();
        
        contract.ASI_TH_CRM_End_Date__c = date.newinstance(2015, 7, 1);
        update contract;
        
        ASI_CRM_Investment_Payment__c ip = ASI_CRM_MO_TestClassHelper.createInvestmentPayment();
        ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MO_TestClassHelper.createSKU('sku1');
        
        ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c(ASI_CRM_Contract__c = contract.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Incentive_Point_Per_Bottle__c = 12, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MO_Volume_Incentive'));
        insert vi;   
        
        ASI_CRM_Contract_Cost__c ct = new ASI_CRM_Contract_Cost__c(Name = 'Auto', ASI_CRM_CN_Contract__c = contract.id, ASI_CRM_Investment_Payment__c = ip.id, ASI_CRM_CN_Cost_Type__c = 'Fixed', ASI_CRM_Investment_Value__c = 12, ASI_CRM_Payment_Schedule__c = 'all', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Cost__cASI_CRM_MO_Contract_Cost'));
        insert ct;   
        ct.ASI_CRM_Investment_Value__c = 10;
        update ct;
        contract.ASI_TH_CRM_Contract_Status__c = 'Final';
        update contract;
        
        contract.ASI_TH_CRM_End_Date__c = date.newinstance(2015, 7, 1);
        update contract;
        
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 0, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 1, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 2, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 3, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 4, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 5, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 6, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 7, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 8, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 9, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setApproverByCount(contract, 10, UserInfo.getUserId());
        
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 0, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 1, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 2, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 3, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 4, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 5, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 6, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 7, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 8, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 9, UserInfo.getUserId());
        ASI_CRM_MO_Contract_TriggerClass.setReturnApproverByCount(contract, 10, UserInfo.getUserId());
        
        
        ASI_TH_CRM_Contract__c contrac2t = 
                new ASI_TH_CRM_Contract__c(
                    Name = 'Auto-generated Number', 
                    ASI_TH_CRM_Start_Date__c = date.newinstance(1997, 7, 1),
                    ASI_TH_CRM_End_Date__c = date.newinstance(2015, 6, 1),
                    ASI_TH_CRM_Contract_Status__c = 'Draft',
                    ASI_CRM_CN_Exchange_Rate__c = 1,
                    ASI_TH_CRM_Promotion_Type__c = 'Contract',
                    RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract')
                );
            
        insert contrac2t;
        delete contrac2t;
        
    }
}
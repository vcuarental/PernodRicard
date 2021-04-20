@isTest
public class ASI_CRM_MY_PRLineItemMassEditCtl_TEST{
    
    static testMethod void paymentRequestMassEdit_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        System.runAs(userA){
        
            Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            ASI_CRM_MY_TestClassHelper.createRunningNumbers();
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
            
            ASI_TH_CRM_Contract__c contract = 
                new ASI_TH_CRM_Contract__c(
                    Name = 'Auto-generated Number', 
                    ASI_TH_CRM_Start_Date__c = date.newinstance(1997, 7, 1),
                    ASI_TH_CRM_End_Date__c = date.newinstance(2015, 2, 1),
                    ASI_TH_CRM_Contract_Status__c = 'Draft',
                    ASI_TH_CRM_Promotion_Type__c = 'Contract',
                    ASI_CRM_CN_Outlet_WS__c = customer1.id,
                    ASI_CRM_Version__c = '1',
                    ASI_CRM_Obsolete_Version__c = FALSE,
                    RecordTypeId = idRTContractNormal
                );
            
            insert contract;

            //Change the contract to Final status
            ASI_TH_CRM_Contract__c con = [SELECT id, ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c FROM ASI_TH_CRM_Contract__c WHERE id = :contract.id and ASI_TH_CRM_Contract_Status__c = 'Draft' LIMIT 1];
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            update con;
            
            con.ASI_TH_CRM_End_Date__c = date.newinstance(2015, 1, 1);
            update con;
            
            //Create SKU
            ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
          
            //Create AC code - Contract Setup Code
            ASI_CRM_MY_TestClassHelper.createContractSetupCode();
            
            ASI_CRM_ContractTarget__c ct = new ASI_CRM_ContractTarget__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_MY_ContractTarget'));
            insert ct;
            
            ASI_CRM_ContractSalesStaffIncentive__c ss = new ASI_CRM_ContractSalesStaffIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractSalesStaffIncentive__cASI_CRM_MY_SalesStaffIncentive'));
            insert ss;
            
            ASI_CRM_ContractVolumeIncentive__c vi = new ASI_CRM_ContractVolumeIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractVolumeIncentive__cASI_CRM_MY_VolumeIncentive'));
            insert vi;
            
            ASI_CRM_ContractOtherIncentive__c oi = new ASI_CRM_ContractOtherIncentive__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Description__c = 'VOL', ASI_CRM_FOC__c = 11, ASI_CRM_SetupCode__c = 'VOLC', ASI_CRM_Type__c = 'Type', recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractOtherIncentive__cASI_CRM_MY_ContractOtherIncentive'));
            insert oi;
            
            ASI_CRM_PromoterPlacement__c pp = new ASI_CRM_PromoterPlacement__c(ASI_CRM_Contract__c = con.id, ASI_CRM_SKU__c = sku1.id, recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_PromoterPlacement__cASI_CRM_MY_PromoterPlacement'));
            insert pp;
            
            con.ASI_TH_CRM_Contract_Status__c = 'Final';
            update con;
            
            ASI_TH_CRM_PaymentRequest__c pr = new ASI_TH_CRM_PaymentRequest__c(Name = 'Auto-generated Number', ASI_CRM_CN_OutletWS__c = customer1.id, ASI_TH_CRM_Contract__c = con.id, ASI_CRM_ForAccountOf__c = 'TEST', ASI_CRM_CN_Description__c = 'TEST', recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request'));
            insert pr; 
            
            ASI_TH_CRM_PaymentRequestLineItem__c prl = new ASI_TH_CRM_PaymentRequestLineItem__c();
            prl.ASI_TH_CRM_Payment_Request__c = pr.Id;
            prl.ASI_CRM_SKU__c = sku1.Id;
            prl.ASI_CRM_CN_Actual_Vol__c = 60;
            prl.ASI_CRM_SetupCode__c = 'VOLC';
            prl.ASI_TH_CRM_Amount__c = 24600;
            prl.ASI_CRM_Remark__c = '201802';
            insert prl;
            
            ASI_TH_CRM_PaymentRequest__c[] paymentReq = [SELECT id FROM ASI_TH_CRM_PaymentRequest__c LIMIT 1];
            
            ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(paymentReq);
            ApexPages.currentpage().getparameters().put('id', pr.id);
            ASI_CRM_MY_PRLineItemMassEditCtl PRMassEdit = new ASI_CRM_MY_PRLineItemMassEditCtl(standardSetCtl);
            PRMassEdit.ADDNEW();
            PRMassEdit.CLONESELECTED();
            PRMassEdit.DELETESELECTED();
            PRMassEdit.BEGINNING();
            PRMassEdit.PREVIOUS();
            PRMassEdit.NEXT();
            PRMassEdit.END();
            PRMassEdit.SAVE();
            PRMassEdit.ADDNEW();
            PRMassEdit.addItem();
            PRMassEdit.SAVE();
            
        }
    }
}
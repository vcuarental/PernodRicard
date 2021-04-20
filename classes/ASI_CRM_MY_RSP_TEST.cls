@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_RSPCopyCtl
 2. ASI_CRM_MY_RSPMassEditCtl
****************************************/
public class ASI_CRM_MY_RSP_TEST{
 
    static testMethod void RSP_TEST() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        
        ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1');
        
        ASI_CRM_RSPHeader__c RSP_H = new ASI_CRM_RSPHeader__c(ASI_CRM_Customer__c = customer1.id, ASI_CRM_Date__c = date.newinstance(2015,1,1), recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_RSPHeader__cASI_CRM_MY_RSPHeader'));
        insert RSP_H; 
            
        ASI_TH_CRM_RSP__c RSP_L = new ASI_TH_CRM_RSP__c(ASI_CRM_RSPHeader__c = RSP_H.id, ASI_CRM_SKU__c = sku1.id, ASI_CRM_Price_to_Consumer__c = 200, recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_RSP__cASI_CRM_MY_RSP'));
        insert RSP_L;
        
        ASI_CRM_RSPHeader__c[] RSPP = [SELECT id FROM ASI_CRM_RSPHeader__c LIMIT 1];
        
        ApexPages.StandardSetController standardSetCtl = new ApexPages.StandardSetController(RSPP);
        ApexPages.currentpage().getparameters().put('id', RSP_H.id);
        ASI_CRM_MY_RSPCopyCtl controllerCopy = new ASI_CRM_MY_RSPCopyCtl(standardSetCtl);
        controllerCopy.ADDNEW();
        controllerCopy.CLONESELECTED();
        controllerCopy.DELETESELECTED();
        controllerCopy.BEGINNING();
        controllerCopy.PREVIOUS();
        controllerCopy.NEXT();
        controllerCopy.END();
        controllerCopy.checkHeaderDuplication();
        controllerCopy.ADDNEW();
        controllerCopy.SAVE();
        
        ASI_CRM_MY_RSPMassEditCtl controllerEdit = new ASI_CRM_MY_RSPMassEditCtl(standardSetCtl);
        controllerEdit.ADDNEW();
        controllerEdit.CLONESELECTED();
        controllerEdit.DELETESELECTED();
        controllerEdit.BEGINNING();
        controllerEdit.PREVIOUS();
        controllerEdit.NEXT();
        controllerEdit.END();
        controllerEdit.ADDNEW();
        controllerEdit.SAVE();

        delete RSP_H;
    }
}
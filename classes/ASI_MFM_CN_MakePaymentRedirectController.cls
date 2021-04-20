public with sharing class ASI_MFM_CN_MakePaymentRedirectController {

    private ASI_MFM_PO__c po;
    
    public ASI_MFM_CN_MakePaymentRedirectController(ApexPages.StandardController controller) {

        po = (ASI_MFM_PO__c)controller.getRecord();
        
    }
    
    public PageReference redirect() {
    
        string FieldId_BU = '';
        string FieldId_Supplier = '';
        string FieldId_Currency = '';
        string FieldId_BudgetOwner = '';
    
        List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
        for (ASI_MFM_Field_ID_Mappings__c Setting : Settings) {
            if(Setting.ASI_MFM_Object_Name__c == 'ASI_MFM_Payment__c')
            {
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_BU__c')
                    FieldId_BU = Setting.ASI_MFM_Field_ID__c;
                    
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Supplier_Name__c')
                    FieldId_Supplier = Setting.ASI_MFM_Field_ID__c;
                    
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Currency__c')
                    FieldId_Currency = Setting.ASI_MFM_Field_ID__c;
                    
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Budget_Owner__c')
                    FieldId_BudgetOwner = Setting.ASI_MFM_Field_ID__c;
            }
        }
        
        // Axel@Introv      2014-12-11      For PRCN MFM #120 Debug in production
        System.debug('### PRCN MFM Issue #120 ###');
        System.debug('01. RecordType = ' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment')).subString(0,15));
        System.debug('02. CF' + FieldId_BU + '=' + po.ASI_MFM_BU_Code__r.Name);
        System.debug('03. CF' + FieldId_BU + '_lkid=' + po.ASI_MFM_BU_Code__c);
        System.debug('04. CF' + FieldId_Supplier + '=' + po.ASI_MFM_Supplier_Name__r.Name);
        System.debug('05. CF' + FieldId_Supplier + '_lkid=' + po.ASI_MFM_Supplier_Name__c);
        System.debug('06. ' + FieldId_Currency + '=' + po.ASI_MFM_Currency__c);
        System.debug('07. CF' + FieldId_BudgetOwner + '=' +  po.ASI_MFM_Budget_Owner__r.Name);
        System.debug('08. CF' + FieldId_BudgetOwner + '_lkid=' +  po.ASI_MFM_Budget_Owner__c);
        System.debug('09. retURL=%2F' + po.Id);
        System.debug('### PRCN MFM Issue #120 ###');
        // end - For PRCN MFM #120 Debug in production
        
        return new PageReference('/' + ASI_MFM_Payment__c.SObjectType.getDescribe().getKeyPrefix() + 
                                 '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment')).subString(0,15) +
                                 '&CF' + FieldId_BU + '=' + po.ASI_MFM_BU_Code__r.Name + '&CF' + FieldId_BU + '_lkid=' + po.ASI_MFM_BU_Code__c +
                                 '&CF' + FieldId_Supplier + '=' + po.ASI_MFM_Supplier_Name__r.Name + '&CF' + FieldId_Supplier + '_lkid=' + po.ASI_MFM_Supplier_Name__c +
                                 '&' + FieldId_Currency + '=' + po.ASI_MFM_Currency__c +
                                 '&CF' + FieldId_BudgetOwner + '=' + po.ASI_MFM_Budget_Owner__r.Name + '&CF' + FieldId_BudgetOwner + '_lkid=' + po.ASI_MFM_Budget_Owner__c +
                                 '&retURL=%2F' + po.Id);
    }
    
}
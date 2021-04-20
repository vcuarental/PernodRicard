public with sharing class ASI_CRM_CN_NewCallLogRedirectController {

    private ASI_CRM_AccountsAdditionalField__c objAccAddt;
    
    public ASI_CRM_CN_NewCallLogRedirectController(ApexPages.StandardController controller) {

        objAccAddt = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
    }
    
    public PageReference redirect() {
    
        String FieldId_ACC  = '';
        String strTemp = '';
        
        Id idAcc = objAccAddt.Id;
        Id idCallLogRT;
        
        List<ASI_CRM_AccountsAdditionalField__c> lstTemp = [
            SELECT ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c,
//                ASI_CRM_Account__r.Name
                    Name
            FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE Id = :idAcc
        ];
        
        if (objAccAddt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'))
            idCallLogRT = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Log__cASI_CRM_CallLog_CN_WS');
                        
        if (objAccAddt.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')) {
            //strTemp = objAccAddt.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c;
            
            idCallLogRT = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Log__cASI_CRM_CallLog_CN_ON');
            idCallLogRT = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Log__cASI_CRM_CallLog_CN_OFF');

            strTemp = lstTemp[0].ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c;
            
            if (strTemp == 'On')
                idCallLogRT = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Log__cASI_CRM_CallLog_CN_ON');
                
            if (strTemp == 'Off')
                idCallLogRT = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Log__cASI_CRM_CallLog_CN_OFF');
        }


        List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
        for (ASI_MFM_Field_ID_Mappings__c Setting : Settings) {
            if(Setting.ASI_MFM_Object_Name__c == 'ASI_CRM_Call_Log__c')
            {
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_CRM_AccountsAdditionalField__c')
                    FieldId_ACC = Setting.ASI_MFM_Field_ID__c;
            }
        }
        
        
        return new PageReference('/' + ASI_CRM_Call_Log__c.SObjectType.getDescribe().getKeyPrefix() + '/e'
//            + '?CF' + FieldId_ACC + '=' + lstTemp[0].ASI_CRM_Account__r.Name
            + '?CF' + FieldId_ACC + '=' + lstTemp[0].Name
            + '&CF' + FieldId_ACC  + '_lkid=' + objAccAddt.Id
            + '&retURL=%2F' + objAccAddt.Id
            + '&RecordType=' + idCallLogRT  //objAccAddt.RecordTypeId
            //+ '&ent=01IM00000000wy2' // Call Log SFDC Object ID
        );
        /*
        return new PageReference('/' + ASI_MFM_Payment__c.SObjectType.getDescribe().getKeyPrefix() + 
                                 '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CN_Payment')).subString(0,15) +
                                 '&CF' + FieldId_BU + '=' + po.ASI_MFM_BU_Code__r.Name + '&CF' + FieldId_BU + '_lkid=' + po.ASI_MFM_BU_Code__c +
                                 '&CF' + FieldId_Supplier + '=' + po.ASI_MFM_Supplier_Name__r.Name + '&CF' + FieldId_Supplier + '_lkid=' + po.ASI_MFM_Supplier_Name__c +
                                 '&' + FieldId_Currency + '=' + po.ASI_MFM_Currency__c +
                                 '&CF' + FieldId_BudgetOwner + '=' + po.ASI_MFM_Budget_Owner__r.Name + '&CF' + FieldId_BudgetOwner + '_lkid=' + po.ASI_MFM_Budget_Owner__c +
                                 '&retURL=%2F' + po.Id);
        */
        //https:/ /pernod-ricard--asisb5conf.cs7.my.salesforce.com
        // /a9N/
        // e?CF00NM0000000u6Jc=03VIP%E4%B8%83%E5%AE%9D%E5%BA%97+%28ONSHA3629%29
        // &CF00NM0000000u6Jc_lkid=a8bM00000008RIc
        // &retURL=%2Fa8bM00000008RIc
        // &RecordType=012M00000000VoU
        // &ent=01IM00000000wy2
    }
    
}
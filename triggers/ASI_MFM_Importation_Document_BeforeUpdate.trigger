trigger ASI_MFM_Importation_Document_BeforeUpdate on ASI_MFM_Importation_Document__c (before Update) {

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MFM_CN_Importation_Document')){
        
        ASI_MFM_CN_ImportationDoc_TriggerCls.beforeUpdateFunction(trigger.new, trigger.oldMap);
    }
}
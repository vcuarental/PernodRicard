public with sharing class ASI_CRM_TW_PAFAssignAutoNumber{
    public static void executeTriggerAction(list<ASI_HK_CRM_Pre_Approval_Form__c> trigger_new) {
        List<ASI_CRM_TW_Running_Number__c> listRunningNumber = ([SELECT ASI_CRM_TW_Prefix__c, ASI_CRM_TW_Running_Number__c 
                                                                FROM ASI_CRM_TW_Running_Number__c 
                                                                WHERE ASI_CRM_Type__c = 'PAF' 
                                                                AND recordTypeid =: Global_RecordTypeCache.getRTId('ASI_CRM_TW_Running_Number__cASI_CRM_TW_RunningNumber')]);
        Map<String, ASI_CRM_TW_Running_Number__c> mapRunningNumber = new Map<String, ASI_CRM_TW_Running_Number__c>();
        Map<id, ASI_CRM_CN_Channel__c> mapChannel = new Map<id, ASI_CRM_CN_Channel__c>();
        
        for(ASI_CRM_CN_Channel__c ch : [SELECT id, ASI_CRM_Code_for_PAF__c FROM ASI_CRM_CN_Channel__c 
                                        WHERE recordTypeid =: Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel')]){
            mapChannel.put(ch.id, ch);
        }
        
        for(ASI_CRM_TW_Running_Number__c rn : listRunningNumber){
            mapRunningNumber.put(rn.ASI_CRM_TW_Prefix__c, rn);  
        }
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            String strYear = string.valueof((paf.ASI_HK_CRM_PAF_Start_Date__c).Year()).right(2);
            String strChPAFCode = mapChannel.get(paf.ASI_CRM_Channel__c).ASI_CRM_Code_for_PAF__c;
            String autoNumStr;
            
            if(mapRunningNumber != null && mapRunningNumber.get(strYear+strChPAFCode) != null){
                ASI_CRM_TW_Running_Number__c objRunningNumber = mapRunningNumber.get(strYear+strChPAFCode);
                objRunningNumber.ASI_CRM_TW_Running_Number__c++;
                mapRunningNumber.put(strYear+strChPAFCode, objRunningNumber);
                
                autoNumStr = string.valueof(mapRunningNumber.get(strYear+strChPAFCode).ASI_CRM_TW_Running_Number__c);
                paf.Name = 'PAF-'+strYear+strChPAFCode+autoNumStr.leftPad(5).replace(' ', '0');
            }
            else{
                ASI_CRM_TW_Running_Number__c objNewRunningNumber = new ASI_CRM_TW_Running_Number__c(
                    recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_TW_Running_Number__cASI_CRM_TW_RunningNumber'),
                    ASI_CRM_Type__c = 'PAF', 
                    ASI_CRM_TW_Prefix__c = strYear+strChPAFCode,
                    ASI_CRM_TW_Running_Number__c = 1
                );
                mapRunningNumber.put(strYear+strChPAFCode, objNewRunningNumber);
                
                paf.Name = 'PAF-'+strYear+strChPAFCode+'00001';
            }
        }
        
        /*String autoNumStr;
        
        if(listRunningNumber != NULL && listRunningNumber.size() >0){
            autoNumStr = String.valueof(listRunningNumber[0].ASI_CRM_TW_Running_Number__c);
        }
        else{
            ASI_CRM_TW_Running_Number__c objNewRunningNumber = new ASI_CRM_TW_Running_Number__c(
                recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_TW_Running_Number__cASI_CRM_TW_RunningNumber'),
                ASI_CRM_Type__c = 'PAF', 
                ASI_CRM_TW_Prefix__c = '',
                ASI_CRM_TW_Running_Number__c = 1
            );
            insert objNewRunningNumber;
            listRunningNumber.add(objNewRunningNumber);
        }
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : trigger_new){
            autoNumStr = String.valueof(listRunningNumber[0].ASI_CRM_TW_Running_Number__c);
            listRunningNumber[0].ASI_CRM_TW_Running_Number__c++;

            autoNumStr = autoNumStr.leftPad(8).replace(' ', '0');
            paf.Name = listRunningNumber[0].ASI_CRM_TW_Prefix__c+'-'+autoNumStr;
        }*/
        upsert mapRunningNumber.values();
    }
}
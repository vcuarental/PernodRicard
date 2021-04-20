trigger ASI_Luxury_Account_Account_AfterUpdate on Account (after update) {
    
    // Checking to avoid firing HK_CRM account trigger irrelevant to its recordtype
    //if (ASI_HK_CRM_Util.isLuxAcct(trigger.new))
    

    // Added by Introv @ 20140508, prevent default RT = null
    if (trigger.new[0].RecordTypeId != null) {
    //Modified by Wilken Lee on 20140318, reduce usage of SOQL limit on Account triggers
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_First_Contact') 
            ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_Second_Contact')
                ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_Potential')
                    ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked')
                        ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_Regional_Second_Contact')
                            ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_Regional_Second_Contact_Le_Cercle_Locked')
                                ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_First_Contact')
                                    ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_Potential')
                                        ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_Second_Contact_Le_Cercle_Locked')
                                            ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_MY_Second_Contact')
                                                || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_TW')
                                                    || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury_Account_JP')
                                                        || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_LUX_SG')
                                                            || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_BRD')
        ) {
            ASI_Luxury_Account_Account_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
        }
    }


    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
  
    // Filter recordtype based on LUX record types
    if (trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_LUX_SG'))) {
        triggerClasses.add(new ASI_LUX_Converted_Lux());
    }
  
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }


}
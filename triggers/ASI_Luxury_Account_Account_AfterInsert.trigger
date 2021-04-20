trigger ASI_Luxury_Account_Account_AfterInsert on Account (after insert) {
    
    // Checking to avoid firing HK_CRM account trigger irrelevant to its recordtype
    //if (ASI_HK_CRM_Util.isLuxAcct(trigger.new))
    
    // Added by Introv @ 20150408, to prevent default RT = NULL
    if (trigger.new[0].recordTypeid != null) {
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
            ASI_Luxury_Account_Account_TriggerClass.routineAfterInsert(trigger.new);
        }
    }

}
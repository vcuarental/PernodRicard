/* Filename:    ASI_MFM_CN_Plan_TriggerClass .cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Plan Trigger Class for CN Plan, Some of the CN logic are still in general trigger class
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-09-15   michael.yip@introv.com      Created
 * 
 */

public without sharing class ASI_MFM_CN_Plan_TriggerClass {
    //20190408 Andy @Introv - #101-default PP Category
    Private Static Final Id PP_CATEGORY_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_PP_Category__cASI_MFM_CN_PP_Category');
    Private Static Final List<ASI_MFM_PP_Category__c> DEF_PP_CATEGORY = new List<ASI_MFM_PP_Category__c>([SELECT id, name FROM ASI_MFM_PP_Category__c WHERE name='Content (D)' AND recordTypeId=:PP_CATEGORY_RECORD_TYPE_ID]);
    
    public static void routineBeforeInsert(list<ASI_MFM_Plan__c> trigger_new) {
        //20190408 Andy @Introv - #101-default PP Category
        Id idDefPPCategory = null;
        if (DEF_PP_CATEGORY.size() > 0) {
            idDefPPCategory = DEF_PP_CATEGORY[0].id;
        }

        for(ASI_MFM_Plan__c p : trigger_new){
            // Added by Michael Yip (Introv) 15Sep2014 to change owner to make it equal to budget owner
            if(p.ASI_MFM_Budget_Owner__c != null && p.ASI_MFM_Budget_Owner__c != p.ownerid)
                p.ownerid = p.ASI_MFM_Budget_Owner__c;
            
            //20190408 Andy @Introv - #101-default PP Category
            if ((idDefPPCategory != NULL) && (p.ASI_MFM_PP_Category__c == NULL))
                p.ASI_MFM_PP_Category__c = idDefPPCategory;
        }
    }

}
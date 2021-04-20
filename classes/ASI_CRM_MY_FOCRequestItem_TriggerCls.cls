/*********************************************************************************
 * Name:        ASI_CRM_MY_FreeGoodsRequestItem_TriggerClass--> ASI_CRM_MY_FOCRequestItem_TriggerCls
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-01-03       Introv: Daniel WONG     Created
*********************************************************************************/

public without sharing class ASI_CRM_MY_FOCRequestItem_TriggerCls{
    public static String className = 'ASI_CRM_MY_FOCRequestItem_TriggerCls';
    public static Id idRTMinSP = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_MinSP');
    
    public static void routineBeforeUpsert(list<ASI_FOC_Request_Item__c> trigger_new){
        system.debug('ASI_CRM_MY_FOCRequestItem_TriggerCls Before Trigger');
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {
            Map<String, map<String, String>> mapOfSetup = ASI_CRM_MY_Function.getContractSetupMapping();
            Set<Id> setSKUs = new Set<Id>();
            map<id, decimal> mapMinSP =new map<id, decimal> ();

            //To get the SKU Min SP
            for(ASI_FOC_Request_Item__c i : trigger_new){
                if(i.ASI_CRM_Min_SP__c ==null){
                    setSKUs.add(i.ASI_FOC_SKU__c);    
                }
            }
            if(setSKUs.size()>0){
                mapMinSP = ASI_CRM_MY_Function.getSKUMinSP(setSKUs, Date.today(), idRTMinSP);
            }
            system.debug('ASI_CRM_MY_FOCRequestItem_TriggerCls Before Trigger mapMinSP='+mapMinSP);
            for(ASI_FOC_Request_Item__c i : trigger_new){
                if(i.recordTypeId ==  Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_FOC_MY_RequestItem')){
                    if(i.ASI_CRM_SetupCode__c != NULL){
                        i.ASI_CRM_GLReasonCode__c = mapOfSetup.get(i.ASI_CRM_SetupCode__c).get('GL');
                        i.ASI_CRM_JDECOA__c = mapOfSetup.get(i.ASI_CRM_SetupCode__c).get('AC');
                    }
                
                    if(i.ASI_CRM_Min_SP__c ==null && mapMinSP.get(i.ASI_FOC_SKU__c)!=null){
                        i.ASI_CRM_Min_SP__c = mapMinSP.get(i.ASI_FOC_SKU__c);
                    }
                    
                }
            }
        }
    }
}
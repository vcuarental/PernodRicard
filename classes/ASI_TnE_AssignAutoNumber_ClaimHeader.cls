/*********************************************************************************
 * Name:ASI_TnE_AssignAutoNumber_ClaimHeader
 * Description: Class to Assign Custom Auto Number to TnE Claim Header
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 01/04/2015       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_TnE_AssignAutoNumber_ClaimHeader extends ASI_TnE_TriggerAbstract {


    public ASI_TnE_AssignAutoNumber_ClaimHeader() {
        super('ASI_TnE_AssignAutoNumber_ClaimHeader');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_TnE_ClaimHeader__c> validheaderList = (List<ASI_TnE_ClaimHeader__c>)sObjList;
        
        ASI_TnE_AutoNumberAssignment autoNumAssign = null;
        for (ASI_TnE_ClaimHeader__c header:validheaderList)
        {
           
            if (autoNumAssign == null) 
            {
                if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_SG')){
                    autoNumAssign = new ASI_TnE_AutoNumberAssignment('ASI_TnE_SG_Claim_Header');
                    header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
                }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_HK')){
                    autoNumAssign = new ASI_TnE_AutoNumberAssignment('ASI_TnE_HK_Claim_Header');
                    header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
                }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_ID')){
                    autoNumAssign = new ASI_TnE_AutoNumberAssignment('ASI_TnE_ID_Claim_Header');
                    header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
                }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_MY')){
                    autoNumAssign = new ASI_TnE_AutoNumberAssignment('ASI_TnE_MY_Claim_Header');
                    header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
                }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_TH')){
                    autoNumAssign = new ASI_TnE_AutoNumberAssignment('ASI_TnE_TH_Claim_Header');
                    header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
                }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_PH')){
                    autoNumAssign = new ASI_TnE_AutoNumberAssignment('ASI_TnE_PH_Claim_Header');
                    header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
                }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_KH')){
                    autoNumAssign = new ASI_TnE_AutoNumberAssignment('ASI_TnE_KH_Claim_Header');
                    header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
                }
            }else{
                header.ASI_TnE_Claim_ID__c = autoNumAssign.nextAutoNumStr();
            }
        }
        
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();
    }
}
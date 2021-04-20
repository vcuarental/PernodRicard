/*********************************************************************************
 * Name:ASI_CRM_JP_AssignAutoNumber_Contract 
 * Description: Class to Assign Custom Auto Number to Contract No. JP Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/11/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_AssignAutoNumber_Contract extends ASI_CRM_JP_TriggerAbstract {


    public ASI_CRM_JP_AssignAutoNumber_Contract () {
        super('ASI_CRM_JP_AssignAutoNumber_Contract ');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_CRM_Purchase_Contract__c> validContractList = (List<ASI_CRM_Purchase_Contract__c>)sObjList;
        
        ASI_CRM_JP_AutoNumberAssignment autoNumAssign = null;
        for (ASI_CRM_Purchase_Contract__c validContract : validContractList )
        {
            if (autoNumAssign == null) {
                if(Global_RecordTypeCache.getRt(validContract.recordTypeid).developerName.contains('Rebate')){
                    autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Contract_Rebate_No');
                    validContract.name = autoNumAssign.nextAutoNumStr();
                } else {
                    autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Contract_No');
                    validContract.name = autoNumAssign.nextAutoNumStr();
                }
            }

            if (autoNumAssign != null) {
                autoNumAssign.writeToDB();
                autoNumAssign = null;
            }
        }
    }
}
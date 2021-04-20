/*********************************************************************************
 * Name:ASI_CRM_SG_AssignAutoNumber_CreditDebit 
 * Description: Class to Assign Custom Auto Number to Payment Request No. SG Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-03-30    Laputa: Vincent      Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_AssignAutoNumber_CreditDebit extends ASI_CRM_SG_TriggerAbstract {


    public ASI_CRM_SG_AssignAutoNumber_CreditDebit () {
        super('ASI_CRM_SG_AssignAutoNumber_CreditDebit ');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Credit_Debit_Note__c> validList = (List<ASI_CRM_Credit_Debit_Note__c>)sObjList;
        
        ASI_CRM_SG_AutoNumberAssignment autoNumAssign = new ASI_CRM_SG_AutoNumberAssignment('ASI_CRM_SG_Credit_Debit_Note_No');
        
        for (ASI_CRM_Credit_Debit_Note__c validRecord : validList ){
        
                validRecord.name = autoNumAssign.nextAutoNumStr();
        }
        
        
        if (autoNumAssign != null) {
            autoNumAssign.writeToDB();
        }
        
    }
}
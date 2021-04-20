/*********************************************************************************
 * Name:ASI_CRM_SG_AssignAutoNumber_Payment 
 * Description: Class to Assign Custom Auto Number to Payment Request No. SG Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/01/2015       Laputa: Conrad          Created
 * 2017-02-27		Laputa: Vincent			[VL 1.0] Correct auto number logic for mass insert
*********************************************************************************/

public with sharing class ASI_CRM_SG_AssignAutoNumber_Payment extends ASI_CRM_SG_TriggerAbstract {


    public ASI_CRM_SG_AssignAutoNumber_Payment () {
        super('ASI_CRM_SG_AssignAutoNumber_Payment ');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_TH_CRM_PaymentRequest__c> validPaymentList = (List<ASI_TH_CRM_PaymentRequest__c>)sObjList;
        
        /* [VL 1.0] BEGIN */
        /*
        ASI_CRM_SG_AutoNumberAssignment autoNumAssign = null;
        
        for (ASI_TH_CRM_PaymentRequest__c validPayment : validPaymentList ){
        
            if (autoNumAssign == null) {
                autoNumAssign = new ASI_CRM_SG_AutoNumberAssignment('ASI_CRM_SG_Payment_Request_No');
                validPayment.name = autoNumAssign.nextAutoNumStr();
            }
        }
        */
        ASI_CRM_SG_AutoNumberAssignment autoNumAssign = new ASI_CRM_SG_AutoNumberAssignment('ASI_CRM_SG_Payment_Request_No');
        
        for (ASI_TH_CRM_PaymentRequest__c validPayment : validPaymentList ){
        
                validPayment.name = autoNumAssign.nextAutoNumStr();
        }
        /* [VL 1.0] END */
        
        
        if (autoNumAssign != null) {
            autoNumAssign.writeToDB();
        }
        
    }
}
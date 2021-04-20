/*********************************************************************************
 * Name:ASI_BRD_Generic_AssignAutoNumber
 * Description: Class to Assign Custom Auto Number for ASI BRD Generic
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/09/2015       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_BRD_Generic_AssignAutoNumber extends ASI_BRD_Generic_TriggerAbstract {


    public ASI_BRD_Generic_AssignAutoNumber() {
        super('ASI_BRD_Generic_AssignAutoNumber');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<Account> accList = (List<Account>)sObjList;
        Map<String, ASI_BRD_Generic_CRM_Mapping__c> brdMap = ASI_BRD_Generic_CRM_Mapping__c.getAll();
        Map<String, ASI_HK_CRM_AutoNumberAssignment> autoNumAssign = new Map<String, ASI_HK_CRM_AutoNumberAssignment>();
        for (Account acc: accList)
        {
            if(acc.ASI_BRD_Converted_Lead_Record_Type__pc == null && acc.ASI_BRD_Primary_Market__pc != null){
                if (autoNumAssign.get(acc.ASI_BRD_Primary_Market__pc) == null) {    
                    if(brdMap != null && acc.ASI_BRD_Primary_Market__pc != null && brdMap.get(acc.ASI_BRD_Primary_Market__pc) != null && brdMap.get(acc.ASI_BRD_Primary_Market__pc).ASI_BRD_Running_Number__c != null){
                        autoNumAssign.put(acc.ASI_BRD_Primary_Market__pc, new ASI_HK_CRM_AutoNumberAssignment(brdMap.get(acc.ASI_BRD_Primary_Market__pc).ASI_BRD_Running_Number__c));
                    }
                }
                if(autoNumAssign.get(acc.ASI_BRD_Primary_Market__pc) != null){
                    acc.ASI_LUX_Internal_Member_No__c = autoNumAssign.get(acc.ASI_BRD_Primary_Market__pc).nextAutoNumStr();
                }
            }
        }
        
        for(ASI_HK_CRM_AutoNumberAssignment assign:autoNumAssign.values()){
            assign.writeToDB();
        }
    }
}
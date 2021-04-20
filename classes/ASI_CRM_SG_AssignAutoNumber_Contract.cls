/*********************************************************************************
 * Name:ASI_CRM_SG_AssignAutoNumber_Contract 
 * Description: Class to Assign Custom Auto Number to Contract No. SG Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/01/2015       Laputa: Conrad          Created
* 2016-04-15		Laputa: Vincent			[VL 1.0] Cater proposal, add "-P" after proposal no.
*********************************************************************************/

public with sharing class ASI_CRM_SG_AssignAutoNumber_Contract extends ASI_CRM_SG_TriggerAbstract {


    public ASI_CRM_SG_AssignAutoNumber_Contract () {
        super('ASI_CRM_SG_AssignAutoNumber_Contract ');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
    
        List<ASI_TH_CRM_Contract__c> validContractList = (List<ASI_TH_CRM_Contract__c>)sObjList;
        Set<ID> ownerIDSet = new Set<ID>();
        
        for (ASI_TH_CRM_Contract__c validContract : validContractList )
        {
            ownerIDSet.add(validContract.ownerid);
        }
        
        Map<ID, user> ownerMap = new Map<ID, user>([SELECT ID, firstname, lastname FROM USER WHERE ID IN : ownerIDSet]);
        
        ASI_CRM_SG_AutoNumberAssignment autoNumAssign = null;
        
        /* [VL 1.0] BEGIN */
        //id proposalID = Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG Proposal').getRecordTypeId();
        id proposalID = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        /* [VL 1.0] END */
        
        for (ASI_TH_CRM_Contract__c validContract : validContractList )
        {
            String nameAlias = '';
            try {
                nameAlias = (ownerMap.get(validContract.ownerid)).firstname.substring(0, 1) + (ownerMap.get(validContract.ownerid)).firstname.substring(0, 1) + (ownerMap.get(validContract.ownerid)).lastname.substring(0, 1);
            } catch(exception e) {
                nameAlias='XXX';
            }
            
            if(nameAlias.length() != 3) {
                nameAlias='XXX';
            }

            if (autoNumAssign == null) 
            {
                autoNumAssign = new ASI_CRM_SG_AutoNumberAssignment('ASI_CRM_SG_Contract_No');
                String currentAutoNum = autoNumAssign.nextAutoNumStr();
                String[] splitAutoNum = currentAutoNum.split('-');
                String newAutoNum = splitAutoNum[0] + '-' + nameAlias + '-' + splitAutoNum[1] + '-' + splitAutoNum[2];
                /* [VL 1.0] BEGIN */
                newAutoNum += (validContract.recordtypeid == proposalID) ? '-P' : '';
                /* [VL 1.0] END */
                validContract.name = newAutoNum;
            }
        }
        
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();
    }
}
/*********************************************************************************
 * Name:ASI_CRM_SG_AssignApprover_Contract 
 * Description: Assign approvers to sys approvers hidden fields in contract           
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 21/01/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_AssignApprover_Contract extends ASI_CRM_SG_TriggerAbstract {

    protected FINAL String FIRSTAPPROVER_FirstName = 'Yann';
    protected FINAL String FIRSTAPPROVER_LastName = 'Soenen';
    protected FINAL String THIRDAPPROVER_FirstName = 'Albert';
    protected FINAL String THIRDAPPROVER_LastName = 'GOH';
    protected FINAL String FOURTHAPPROVER_FirstName = 'Gaurav';
    protected FINAL String FOURTHAPPROVER_LastName = 'Sabharwal';
    protected FINAL String FIFTHAPPROVER_FirstName = 'Paul-Robert';
    protected FINAL String FIFTHAPPROVER_LastName = 'BOUHIER';
    
    public ASI_CRM_SG_AssignApprover_Contract() {
        super('ASI_CRM_SG_AssignApprover_Contract');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_TH_CRM_Contract__c> cnttractList = (List<ASI_TH_CRM_Contract__c>)sObjList;
        List<ASI_TH_CRM_Contract__c> contractList = new List<ASI_TH_CRM_Contract__c>();
        
        if(oldMap == null) {
            contractList = cnttractList;
        } else {
            Map<ID, ASI_TH_CRM_Contract__c> contractOldMap = (Map<ID, ASI_TH_CRM_Contract__c>)oldMap;
            
            for(ASI_TH_CRM_Contract__c contract : cnttractList) {
                if(contract.ownerID != contractOldMap.get(contract.id).ownerID ) {
                    contractList.add(contract);
                }
            }
        }
        
        if(contractList.size() > 0) {
        
            Set<ID> ownerIDSet = new Set<ID>();
        
            for(ASI_TH_CRM_Contract__c contract : contractList) {
                ownerIDSet.add(contract.ownerID);
            }
        
            Map<ID, User> ownerMap = new Map<ID, User>();
            Map<String, User> firstLastNameUserMap = new Map<String, User>();
        
            if(ownerIDSet != null) {
                ownerMap = new Map<ID, User>([
                                                SELECT ID, Name, firstName, LastName, managerID 
                                                FROM User 
                                                WHERE ID IN : ownerIDSet
                                                OR (firstname = : FIRSTAPPROVER_FirstName AND lastname = : FIRSTAPPROVER_LastName)
                                                OR (firstname = : THIRDAPPROVER_FirstName AND lastname = : THIRDAPPROVER_LastName)
                                                OR (firstname = : FOURTHAPPROVER_FirstName AND lastname = : FOURTHAPPROVER_LastName)
                                                OR (firstname = : FIFTHAPPROVER_FirstName AND lastname = : FIFTHAPPROVER_LastName)
                                             ]);
                for(User usr : ownerMap.values()) {
                    firstLastNameUserMap.put(usr.firstname + usr.lastname, usr);
                }
            }
        
            if(ownerMap.size() > 0) {
        
                for(ASI_TH_CRM_Contract__c contract : contractList) {
                    contract.ASI_CRM_CN_Sys_Approver_1__c = (firstLastNameUserMap.get(FIRSTAPPROVER_FirstName+FIRSTAPPROVER_LastName) != null ? firstLastNameUserMap.get(FIRSTAPPROVER_FirstName+FIRSTAPPROVER_LastName).id : null);
                    contract.ASI_CRM_CN_Sys_Approver_2__c = ownerMap.get(contract.ownerid).managerid;
                    contract.ASI_CRM_CN_Sys_Approver_3__c = (firstLastNameUserMap.get(THIRDAPPROVER_FirstName+THIRDAPPROVER_LastName) != null ? firstLastNameUserMap.get(THIRDAPPROVER_FirstName+THIRDAPPROVER_LastName).id : null);
                    contract.ASI_CRM_CN_Sys_Approver_4__c = (firstLastNameUserMap.get(FOURTHAPPROVER_FirstName+FOURTHAPPROVER_LastName) != null ? firstLastNameUserMap.get(FOURTHAPPROVER_FirstName+FOURTHAPPROVER_LastName).id : null);
                    contract.ASI_CRM_CN_Sys_Approver_5__c = (firstLastNameUserMap.get(FIFTHAPPROVER_FirstName+FIFTHAPPROVER_LastName) != null ? firstLastNameUserMap.get(FIFTHAPPROVER_FirstName+FIFTHAPPROVER_LastName).id : null);
                }
            }
        }
    }

}
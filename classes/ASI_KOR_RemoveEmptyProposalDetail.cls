/**********************************************************************************
 * Name : ASI_KOR_RemoveEmptyProposalDetail 
 * Created : Vincent Lam
 * Revision History:
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-04-04		Laputa: Kevin			Created
 **********************************************************************************/


public class ASI_KOR_RemoveEmptyProposalDetail extends ASI_KOR_TriggerAbstract{
    
    public ASI_KOR_RemoveEmptyProposalDetail() {
        super('ASI_KOR_RemoveEmptyProposalDetail');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        list<string> list_idToBeDelete = new list<string>();
        for(ASI_KOR_SR_Proposal_Detail__c srDetail : (List<ASI_KOR_SR_Proposal_Detail__c>)sObjList){            
            if (!srDetail.ASI_KOR_System_Generated__c &&
				!srDetail.ASI_KOR_Is_Pre_payment__c && (
                srDetail.ASI_KOR_Target_Volume__c == 0 || srDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c == 0 ||
                srDetail.ASI_KOR_Target_Volume__c == null || srDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c == null
            )){
                list_idToBeDelete.add(srDetail.id);
            }
        }
        if (list_idToBeDelete.size()>0){
            delete [select id from ASI_KOR_SR_Proposal_Detail__c where id in :list_idToBeDelete];
        }
    }                                        
}
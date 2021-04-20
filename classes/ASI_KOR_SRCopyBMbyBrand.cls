/*********************************************************************************************************************************************************
* Name : ASI_KOR_SRCopyBMbyBrand 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2017-05-22       Laputa: Vincent         Created
*********************************************************************************************************************************************************/
public Class ASI_KOR_SRCopyBMbyBrand extends ASI_KOR_TriggerAbstract{
    
    
    public ASI_KOR_SRCopyBMbyBrand() {
        super('ASI_KOR_SRCopyBMbyBrand');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (tAction == TriggerAction.AFTER_INSERT) {
            
            List<ASI_KOR_SR_Proposal_Header__c> srPropHeader = (List<ASI_KOR_SR_Proposal_Header__c>) sObjList;
			
			List<ASI_KOR_SR_Proposal_By_Brand__c> srByBrandToInsert = new List<ASI_KOR_SR_Proposal_By_Brand__c>();
			
			List<string> list_srID = new List<string>();
            
            for (ASI_KOR_SR_Proposal_Header__c sr: srPropHeader){
                for (ASI_KOR_BM_Proposal_By_Brand__c bmByBrand : [
					select id, ASI_KOR_Brand__c, ASI_KOR_UOM__c from ASI_KOR_BM_Proposal_By_Brand__c where ASI_KOR_BM_Proposal_Header__c = :sr.ASI_KOR_BM_Proposal_Header__c
				]) {
					ASI_KOR_SR_Proposal_By_Brand__c srByBrand = new ASI_KOR_SR_Proposal_By_Brand__c(
						ASI_KOR_BM_Proposal_By_Brand__c = bmByBrand.id,
						ASI_KOR_Brand__c = bmByBrand.ASI_KOR_Brand__c,
						ASI_KOR_SR_Proposal_Header__c = sr.id,
						ASI_KOR_UOM__c = bmByBrand.ASI_KOR_UOM__c
					);
					srByBrandToInsert.add(srByBrand);
				}
				list_srID.add(sr.id);
            }
			
			if (srByBrandToInsert.size()>0) insert srByBrandToInsert;
			
			if (list_srID.size()>0){
				Database.executeBatch(new ASI_KOR_CalPrevMonthsValueByBrand(list_srID),20);
			}
        }
    }
}
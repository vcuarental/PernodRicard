/*********************************************************************************************************************************************************
* Name : ASI_KOR_SRPaymentSettlementController 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??										Created
* 2017-02-14       Laputa: Vincent         [VL 1.0] bypass this trigger if the record has already input BM proposal, in order for me to prepare UAT data
* 2017-04-05	   Laputa: Kevin		   [KC 2.0] Add a checking to block creation if NSD is approved the proposal for that Year and Month  
*********************************************************************************************************************************************************/
public Class ASI_KOR_SRProposalHeader extends ASI_KOR_TriggerAbstract{
    
    
    public ASI_KOR_SRProposalHeader() {
        super('ASI_KOR_SRProposalHeaderPopulate');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (tAction == TriggerAction.BEFORE_INSERT) {
            /*[KC 2.0] BEGIN */
            List<ASI_KOR_SR_Proposal_Header__c> srPropHeader = (List<ASI_KOR_SR_Proposal_Header__c>) sObjList;
            List<String> srMonth = new List<String>();
            List<String> srYear = new List<String>();
            Map<String, ASI_KOR_NSD_Proposal_Header__c> nsdPropHeaderMap = new Map<String, ASI_KOR_NSD_Proposal_Header__c>();
            
            for (ASI_KOR_SR_Proposal_Header__c sr: srPropHeader){
                srMonth.add(sr.ASI_KOR_Month__c);
                srYear.add(sr.ASI_KOR_Year__c);               
            }
                        
            List<ASI_KOR_NSD_Proposal_Header__c> nsdPropHeader= [SELECT Name, ASI_KOR_Month__c, ASI_KOR_Year__c, ASI_KOR_Status__c 
                                                                 FROM ASI_KOR_NSD_Proposal_Header__c 
                                                    				WHERE ASI_KOR_Month__c IN :srMonth 
                                                    				AND ASI_KOR_Year__c IN :srYear];
                        
            for (ASI_KOR_NSD_Proposal_Header__c nsdProp: nsdPropHeader){
                String propKey = nsdProp.ASI_KOR_Year__c + nsdProp.ASI_KOR_Month__c; 
                   nsdPropHeaderMap.put(propKey,nsdProp); 
            }
            /*[KC 2.0] END */
           
            
            for(ASI_KOR_SR_Proposal_Header__c newValues : srPropHeader){
                
                /* [VL 1.0] BEGIN */
                /*
                if (newValues.ASI_KOR_BM_Proposal_Header__c != null) continue;
                */
                /* [VL 1.0] END */
                
                /*[KC 2.0] BEGIN */
                String srPropKey = newValues.ASI_KOR_Year__c + newValues.ASI_KOR_Month__c;
                ASI_KOR_NSD_Proposal_Header__c nsdProp = nsdPropHeaderMap.get(srPropKey);
                
                if (nsdProp.ASI_KOR_Status__c == 'Approved'){
                    newValues.addError('Proposal of '+ newValues.ASI_KOR_Year__c +'-'+ newValues.ASI_KOR_Month__c + ' has been finalized by NSD');
                }
                 /*[KC 2.0] END */
                
                
                List<User> manager = [SELECT managerID from USER WHERE ID = :newValues.OwnerId];
                
                if(manager.size()>0){
                    String managerID = manager.get(0).managerID;
                    
                    List<ASI_KOR_BM_Proposal_Header__c> bmProposalHeader =    
                        [SELECT 
                         Name, ID 
                         From 
                         ASI_KOR_BM_Proposal_Header__c 
                         Where 
                         OwnerID = :managerID AND
                         ASI_KOR_Year__c = :newValues.ASI_KOR_Year__c AND 
                         ASI_KOR_Month__c = :newValues.ASI_KOR_Month__c
                        ];
                    
                    if(bmProposalHeader.size()>0){      
                        newValues.ASI_KOR_BM_Proposal_Header__c = bmProposalHeader.get(0).Id;                
                    }else{
                        newValues.addError('The proposal process hasn\'t started.');
                    }       
                }                
            }    
        }
    }
}
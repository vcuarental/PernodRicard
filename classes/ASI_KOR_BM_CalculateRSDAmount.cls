public class ASI_KOR_BM_CalculateRSDAmount extends ASI_KOR_TriggerAbstract {
	
    public ASI_KOR_BM_CalculateRSDAmount() {
        super('ASI_KOR_BM_CalculateRSDAmount');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_KOR_BM_Proposal_Header__c> bmProposalHeaderList = (List<ASI_KOR_BM_Proposal_Header__c>) sObjList;
        Map<Id, ASI_KOR_BM_Proposal_Header__c> bmProposalHeaderMap = (Map<Id, ASI_KOR_BM_Proposal_Header__c>) oldMap;
            
        Set<Id> rsdProposalHeaderIdSet = new Set<Id>();
        Set<Id> bmProposalHeaderIdSet = new Set<Id>();
        for(ASI_KOR_BM_Proposal_Header__c bmProposalHeader : bmProposalHeaderList) {
            if(bmProposalHeaderMap.get(bmProposalHeader.Id).ASI_KOR_Status__c == 'Draft' && 
               bmProposalHeader.ASI_KOR_Status__c == 'Submitted') {
                   rsdProposalHeaderIdSet.add(bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c);
               }
            
            if(bmProposalHeaderMap.get(bmProposalHeader.Id).ASI_KOR_Status__c == 'Submitted' && 
               bmProposalHeader.ASI_KOR_Status__c == 'Draft') {
                   rsdProposalHeaderIdSet.add(bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c);
               }
            bmProposalHeaderIdSet.add(bmProposalHeader.Id);
        }
        
        if(rsdProposalHeaderIdSet.size() > 0) {
            List<ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderList = calculatRSDAmount(bmProposalHeaderList, bmProposalHeaderMap, rsdProposalHeaderIdSet);
            
            update rsdProposalHeaderList;
        }    
        
    }
    
    private List<ASI_KOR_RSD_Proposal_Header__c> calculatRSDAmount(List<ASI_KOR_BM_Proposal_Header__c> bmProposalHeaderList, Map<Id, ASI_KOR_BM_Proposal_Header__c> bmProposalHeaderMap, Set<Id> rsdProposalHeaderIdSet) {
        Map<Id, ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderMap = new Map<Id, ASI_KOR_RSD_Proposal_Header__c> (
                                                                       		[SELECT Id, ASI_KOR_No_of_Sumitted_Branches__c, ASI_KOR_CA_Amount_Pending__c
                                                                             FROM ASI_KOR_RSD_Proposal_Header__c
                                                                             WHERE Id in :rsdProposalHeaderIdSet]
                                                                       );
        for(ASI_KOR_BM_Proposal_Header__c bmProposalHeader : bmProposalHeaderList) {
            ASI_KOR_RSD_Proposal_Header__c rsdProposalHeader = rsdProposalHeaderMap.get(bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c);
            if(bmProposalHeaderMap.get(bmProposalHeader.Id).ASI_KOR_Status__c == 'Draft' && 
               bmProposalHeader.ASI_KOR_Status__c == 'Submitted') {
                   
                   if(rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c == null) {
                       rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c = 1;
                   } else {
                       rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c += 1;
                   }
                   
                   if(rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c == null) {
                       rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c = bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                   } else {
                       rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c += bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                   }
                   
               }
            
            if(bmProposalHeaderMap.get(bmProposalHeader.Id).ASI_KOR_Status__c == 'Submitted' && 
               bmProposalHeader.ASI_KOR_Status__c == 'Draft') {
                   
                   if(rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c == null) {
                       rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c = 0;
                   } else {
                       rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c -= 1;
                   }
                   
                   if(rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c == null) {
                       rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c = 0;
                   } else {
                       rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c -= bmProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                   }
                   
               }
        }
        
        return rsdProposalHeaderMap.values();
        
    }
}
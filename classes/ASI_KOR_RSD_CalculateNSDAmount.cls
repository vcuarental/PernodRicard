public class ASI_KOR_RSD_CalculateNSDAmount extends ASI_KOR_TriggerAbstract {
    
    public ASI_KOR_RSD_CalculateNSDAmount() {
        super('ASI_KOR_RSD_CalculateNSDAmount');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    	List<ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderList = (List<ASI_KOR_RSD_Proposal_Header__c>) sObjList;
        Map<Id, ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderMap = (Map<Id, ASI_KOR_RSD_Proposal_Header__c>) oldMap;
        
        Set<Id> nsdProposalHeaderIdSet = new Set<Id>();
        Set<Id> rsdProposalHeaderIdSet = new Set<Id>();
        for(ASI_KOR_RSD_Proposal_Header__c rsdProposalHeader : rsdProposalHeaderList) {
           	if(rsdProposalHeaderMap.get(rsdProposalHeader.Id).ASI_KOR_Status__c == 'Draft' && 
               rsdProposalHeader.ASI_KOR_Status__c == 'Submitted') {
                   nsdProposalHeaderIdSet.add(rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c);
               }
            
            if(rsdProposalHeaderMap.get(rsdProposalHeader.Id).ASI_KOR_Status__c == 'Submitted' && 
               rsdProposalHeader.ASI_KOR_Status__c == 'Draft') {
                nsdProposalHeaderIdSet.add(rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c);
            }
            rsdProposalHeaderIdSet.add(rsdProposalHeader.Id);
        } 
        
        if(nsdProposalHeaderIdSet.size() > 0) {
            List<ASI_KOR_NSD_Proposal_Header__c> nsdProposalHeaderList = calculatNSDAmount(rsdProposalHeaderList, rsdProposalHeaderMap, nsdProposalHeaderIdSet);
            
            update nsdProposalHeaderList;
        }
    }
    
    private List<ASI_KOR_NSD_Proposal_Header__c> calculatNSDAmount(List<ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderList, Map<Id, ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderMap, Set<Id> nsdProposalHeaderIdSet) {
    	Map<Id, ASI_KOR_NSD_Proposal_Header__c> nsdProposalHeaderMap = new Map<Id, ASI_KOR_NSD_Proposal_Header__c>(
            																	[SELECT Id, ASI_KOR_No_of_Sumitted_Regions__c
                                                                        		 FROM ASI_KOR_NSD_Proposal_Header__c
                                                                        		 WHERE Id in :nsdProposalHeaderIdSet]
                                                                                );
        
        for(ASI_KOR_RSD_Proposal_Header__c rsdProposalHeader : rsdProposalHeaderList) {
            ASI_KOR_NSD_Proposal_Header__c nsdPorposalHeader = nsdProposalHeaderMap.get(rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c);
           	if(rsdProposalHeaderMap.get(rsdProposalHeader.Id).ASI_KOR_Status__c == 'Draft' && 
               rsdProposalHeader.ASI_KOR_Status__c == 'Submitted') {
                   if(nsdPorposalHeader.ASI_KOR_No_of_Sumitted_Regions__c == null) {
                       nsdPorposalHeader.ASI_KOR_No_of_Sumitted_Regions__c = 1;
                   } else {
                       nsdPorposalHeader.ASI_KOR_No_of_Sumitted_Regions__c += 1;
                   }
               }
            
            if(rsdProposalHeaderMap.get(rsdProposalHeader.Id).ASI_KOR_Status__c == 'Submitted' && 
               rsdProposalHeader.ASI_KOR_Status__c == 'Draft') {
                   if(nsdPorposalHeader.ASI_KOR_No_of_Sumitted_Regions__c == null) {
                       nsdPorposalHeader.ASI_KOR_No_of_Sumitted_Regions__c = 0;
                   } else {
                       nsdPorposalHeader.ASI_KOR_No_of_Sumitted_Regions__c -= 1;
                   }
            }
        }
        
        return nsdProposalHeaderMap.values();
    }
}
/**********************************************************************************
 * Name : ASI_KOR_CalPrevMonthsValueByBrand_NSD 
 * Created : Vincent Lam
 * Revision History:
 * 1. 2017-06-01 - [VL] Created; 
 **********************************************************************************/

global class ASI_KOR_CalPrevMonthsValueByBrand_NSD
    implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {

	// initial parameter
	public set<string> list_nsdID = new set<string>();
		    
	public ASI_KOR_CalPrevMonthsValueByBrand_NSD(){
		for (ASI_KOR_NSD_Proposal_Header__c nsd : [
			select id
			from ASI_KOR_NSD_Proposal_Header__c
			where ASI_KOR_Status__c = 'In Progress'
		]){
			this.list_nsdID.add(nsd.id);
		}
	}
	
    global class AggregateResultIterable implements Iterable<AggregateResult> {
        public set<string> list_nsdID;
        global AggregateResultIterable (set<string> list_nsdID){
             this.list_nsdID = list_nsdID;
         }
        global Iterator<AggregateResult> Iterator(){
            return new AggregateResultIterator(list_nsdID);
       }
    }
 
    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results {get;set;}
        Integer index {get; set;} 
 
        global AggregateResultIterator(set<string> list_nsdID) {
            index = 0;
			results = 
                    [Select 
                       sum(ASI_KOR_Actual_Volume_1_Month_Ago__c) volume1M, 
                       sum(ASI_KOR_Actual_Volume_2_Months_Ago__c) volume2M, 
                       sum(ASI_KOR_Total_VI_1_Month_Ago_Number__c) VI1M, 
                       sum(ASI_KOR_Total_VI_2_Months_Ago_Number__c) VI2M, 
                       ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand 
                     From  
                         ASI_KOR_RSD_Proposal_By_Brand__c  
                     where  
						ASI_KOR_NSD_Proposal_By_Brand__r.ASI_KOR_NSD_Proposal_Header__c in :list_nsdID
                     group by 
                       ASI_KOR_NSD_Proposal_By_Brand__c] ;
        } 
 
        global boolean hasNext(){ 
           return results != null && !results.isEmpty() && index < results.size(); 
        }    
 
        global AggregateResult next(){ 
            return results[index++];            
        }       
    }    
 
    global Iterable<AggregateResult> start(Database.batchableContext info){
        // just instantiate the new iterable here and return
        return new AggregateResultIterable(list_nsdID);
    }
 
    global void execute(Database.BatchableContext contextInstance, list<AggregateResult> pLstFetchedRecords) {
        
		list<ASI_KOR_NSD_Proposal_By_Brand__c> list_updateNSDbyBrand = new list<ASI_KOR_NSD_Proposal_By_Brand__c>();
		
        for (AggregateResult ar : pLstFetchedRecords){
			Decimal volume1M = (Decimal)(ar.get('volume1M'));
			Decimal volume2M = (Decimal)(ar.get('volume2M'));
			Decimal VI1M = (Decimal)(ar.get('VI1M'));
			Decimal VI2M = (Decimal)(ar.get('VI2M'));
			String nsdByBrandID = String.valueOf(ar.get('nsdByBrand'));
			
			ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c(
				id = nsdByBrandID,
			   ASI_KOR_Actual_Volume_1_Month_Ago__c = volume1M, 
			   ASI_KOR_Actual_Volume_2_Months_Ago__c = volume2M, 
			   ASI_KOR_Total_VI_1_Month_Ago__c = VI1M, 
			   ASI_KOR_Total_VI_2_Months_Ago__c = VI2M
			);
			list_updateNSDbyBrand.add(nsdByBrand);
        }
				
		if (list_updateNSDbyBrand.size()>0){
			
			try {
				update list_updateNSDbyBrand;
			} catch(DmlException exceptionInstance) {
				// DC - TODO : Nothing
			}
			
		}

    }
    
        
    /* [DC 3.1] BEGIN */
    public void execute(SchedulableContext contextInstance) {}
    /* [DC 3.1] END */

    // do the final proposal data update / insert in finish
    global void finish(Database.BatchableContext contextInstance) {
        
            
    }
        
        
    
}
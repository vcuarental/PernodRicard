public with sharing class ASI_TnE_TW_ClaimHeaderTriggerClass {


    public static void beforeDeleteMethod(Map<Id, ASI_TnE_ClaimHeader__c> pMapOldClaimHeaders) {
        system.debug('**beforeDeleteMethod**' + pMapOldClaimHeaders);
        //Initiallizing collections
        List<ASI_MFM_PO__c> lstPO_ToUpdate = new List<ASI_MFM_PO__c>();
        Map<Id, Double> mapPOWithAmt = new Map<Id, Double>();
        Map<Id, Double> mapPOWithAmtToReduce = new Map<Id, Double>();
        
        Double amt;
        
        //Iterating to calculate amount to deduct for a PO
        for(ASI_TnE_ClaimDetail__c claimDtl : [SELECT Id, ASI_TnE_Receipt_Amount__c, 
                                                      ASI_TnE_MFM_PO__c,
                                                      ASI_TnE_MFM_PO__r.ASI_MFM_T_E_Amount__c
                                               FROM ASI_TnE_ClaimDetail__c
                                               WHERE ASI_TnE_Receipt_Amount__c != null 
                                               AND ASI_TnE_MFM_PO__c != null 
                                               AND  ASI_TnE_ClaimHeader__c IN : pMapOldClaimHeaders.keySet()]){
            
            amt = mapPOWithAmtToReduce.get(claimDtl.ASI_TnE_MFM_PO__c);
            
            if(amt == null) 
                amt  = 0.0;
               
            amt = amt + claimDtl.ASI_TnE_Receipt_Amount__c;
            
            mapPOWithAmtToReduce.put(claimDtl.ASI_TnE_MFM_PO__c, amt);
            mapPOWithAmt.put(claimDtl.ASI_TnE_MFM_PO__c, claimDtl.ASI_TnE_MFM_PO__r.ASI_MFM_T_E_Amount__c);
        }//End for
        
        system.debug('**mapPOWithAmt**' + mapPOWithAmt); 
        system.debug('**mapPOWithAmtToReduce**' + mapPOWithAmtToReduce);  
                                                  
        //Calculating remaining amount for PO
        for(Id poId : mapPOWithAmtToReduce.keySet()){
            amt = mapPOWithAmt.get(poId ) == null ? 0.0 : mapPOWithAmt.get(poId );
            
            lstPO_ToUpdate.add(new ASI_MFM_PO__c(Id = poId, 
                                                 ASI_MFM_T_E_Amount__c = (amt - mapPOWithAmtToReduce.get(poId))));
        }//End for
        
        system.debug('**lstPO_ToUpdate**' + lstPO_ToUpdate);
               
        if(!lstPO_ToUpdate.isEmpty()) {
            try {
                update lstPO_ToUpdate;
            } catch(DmlException exceptionInstance) {
                System.debug('Error occurred : ' + exceptionInstance.getMessage());
            }//End Catch
        }//End if !lstPosToUpdate.isEmpty()
    }//End beforeDeleteMethod method
    
    public static void routineAfterUpdate (list<ASI_TnE_ClaimHeader__c> trigger_new, map<id, ASI_TnE_ClaimHeader__c> trigger_oldMap) {
    	System.debug('start enter after update');
        set<id> claimheader_id = new set<id>();
        for (ASI_TnE_ClaimHeader__c ClaimHeader:trigger_new) {
            if(ClaimHeader.ASI_TnE_status__c != trigger_oldMap.get(ClaimHeader.id).ASI_TnE_status__c){
                claimheader_id.add(ClaimHeader.id);
            }            
        }        
        
        set<id> plan_id = new set<id>();
        for (ASI_TnE_ClaimDetail__c  d:[select ASI_TnE_CAP_Plan__c from ASI_TnE_ClaimDetail__c where ASI_TnE_CAP_Plan__c!=null and ASI_TnE_ClaimHeader__c in :claimheader_id ]) {
            plan_id.add(d.ASI_TnE_CAP_Plan__c );                  
        }
        
        Map<id,asi_mfm_plan__c> planMap = new Map<id,asi_mfm_plan__c>();
        for (ASI_TnE_ClaimDetail__c  d:[select ASI_TnE_CAP_Plan__c,ASI_TnE_AD_AP__c,ASI_TnE_Receipt_Amount__c,ASI_TnE_FX_Rate__c,ASI_TnE_ClaimHeader__r.asi_tne_status__c from ASI_TnE_ClaimDetail__c where ASI_TnE_CAP_Plan__c in :plan_id]) {
            
            double amount =0;
            if(d.ASI_TnE_ClaimHeader__r.asi_tne_status__c !='Draft')
                amount=(d.ASI_TnE_Receipt_Amount__c==null?0:d.ASI_TnE_Receipt_Amount__c) *(d.ASI_TnE_FX_Rate__c==null?1:d.ASI_TnE_FX_Rate__c);            
            System.debug('SH amount: '+amount); 
            
            if(!planMap.containsKey(d.ASI_TnE_CAP_Plan__c )){
                asi_mfm_plan__c p=new asi_mfm_plan__c();
                p.id=d.ASI_TnE_CAP_Plan__c;
                p.ASI_MFM_TnE_Amount__c =0;                
                p.ASI_MFM_TnE_Non_A_D_Amount__c=0;
                p.ASI_MFM_TW_TnE_A_D_Amount__c = 0;
                
                p.ASI_MFM_TnE_Amount__c+=amount ;
                
                if(d.ASI_TnE_AD_AP__c=='A&D')
                    p.ASI_MFM_TW_TnE_A_D_Amount__c += amount;
                else
                    p.ASI_MFM_TnE_Non_A_D_Amount__c+= amount;
                
                planMap.put(d.ASI_TnE_CAP_Plan__c,p );  
            } else {
                asi_mfm_plan__c p=planMap.get(d.ASI_TnE_CAP_Plan__c);
                 
                p.ASI_MFM_TnE_Amount__c+=amount ;
                
                if(d.ASI_TnE_AD_AP__c=='A&D')
                    p.ASI_MFM_TW_TnE_A_D_Amount__c += amount;
                else
                    p.ASI_MFM_TnE_Non_A_D_Amount__c+= amount;
                
                planMap.put(d.ASI_TnE_CAP_Plan__c,p );  
            }               
        }
        system.debug('SH PpplanMap: '+ planMap);
        if(!planMap.isEmpty() && !Test.isRunningTest())
            update planMap.values();
        
        
     }

}//End ASI_TnE_TW_ClaimHeaderTriggerClass  Class
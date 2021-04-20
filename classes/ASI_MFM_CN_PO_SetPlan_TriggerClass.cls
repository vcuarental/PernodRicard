public class ASI_MFM_CN_PO_SetPlan_TriggerClass {
    public static String className = 'ASI_MFM_CN_PO_SetPlan_TriggerClass';
    @testVisible
    public static Boolean passTrigger = false;
    
    public static Boolean checkSetContain(Set<Id> oldSet, Set<Id> newSet){
        for(Id objId: oldSet){
            if(newSet.contains(objId)) {
            }else {
                return false;
            }
        }
        return true;
    }
    
    //AM@Introv 20190718 - fix sfdc limitation for eMarket web service
    private static boolean checkEMarketWebService(List<ASI_MFM_PO__c> triggerNew) {
        boolean bIsByEmarket = false;
        if (triggerNew.size()>0) {
            ASI_MFM_PO__c oTmpPO = triggerNew[0];
            if (oTmpPO.ASI_MFM_From_eMarket__c != NULL)
            	bIsByEmarket = oTmpPO.ASI_MFM_From_eMarket__c;
        }
        return bIsByEmarket;
    }
    
	public static void routineBeforeUpdate(List<ASI_MFM_PO__c> triggerNew, Map<Id, ASI_MFM_PO__c> triggerOldMap ){
        if(ASI_CRM_CN_Function.IsBypassTrigger(className)) return;
        if(passTrigger) return;
        if (checkEMarketWebService(triggerNew))	{	//AM@Introv 20190718 - fix sfdc limitation for eMarket web service
            return;
        }
        Set<Id> amountChangedPoSet = new Set<Id>();
        Map<Id,Set<Id>> planToBrandMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> poBrandMap = new Map<Id,Set<Id>>();
        Set<Id> planSet = new Set<Id>();
        Set<Id> newbalancePliIdSet = new Set<Id>();
        
        Map<String,Double> planBalanceChangeMap = new Map<String,Double>();
        Map<Id, ASI_MFM_PO__c> triggerNewMap = new Map<Id,ASI_MFM_PO__c>();
        Set<Id> planChangedPOIds = new Set<Id>();
        Map<Id,Double> planBalance = new Map<Id,Double>();
        for(ASI_MFM_PO__c po: triggerNew) {
            triggerNewMap.put(po.Id,po);
            planSet.add(po.ASI_MFM_Plan__c);
            ASI_MFM_PO__c oldpo = triggerOldMap.get(po.id);
            if(oldpo!=null && oldpo.ASI_MFM_Plan__c!=null) {planSet.add(oldpo.ASI_MFM_Plan__c);}
            if(oldpo==null || oldpo.ASI_MFM_CN_PO_Amount_RMB__c != po.ASI_MFM_CN_PO_Amount_RMB__c){ amountChangedPoSet.add(po.Id); }
            
            if(oldpo!=null && oldpo.ASI_MFM_Plan__c!=null
              && oldpo.ASI_MFM_Plan__c != po.ASI_MFM_Plan__c) 
            {
                planChangedPOIds.add(po.Id);
            }
        }
        
        //AM@Introv 20191015 - fix sfdc limitation (soql 101)
        //if(amountChangedPoSet.size() == 0 && planChangedPOIds.size() == 0) return;
        if(planChangedPOIds.size() == 0) return;
        
        List<ASI_MFM_Plan_Line_Item__c> planlineList = [SELECT id, ASI_MFM_Plan__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Total_Cost__c  FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__c IN :planSet];
        for(ASI_MFM_Plan_Line_Item__c planline :planlineList) {
            if(!planToBrandMap.containsKey(planline.ASI_MFM_Plan__c)) planToBrandMap.put(planline.ASI_MFM_Plan__c,new Set<Id>());
            planToBrandMap.get(planline.ASI_MFM_Plan__c).add(planline.ASI_MFM_Sub_brand_Code__c);
            Double balance = (planline.ASI_MFM_Remaining_Balance__c!=null) ? planline.ASI_MFM_Remaining_Balance__c:0;
            if(planline.ASI_MFM_Remaining_Balance__c==null) {
                newbalancePliIdSet.add(planline.id);
                planBalanceChangeMap.put(planline.ASI_MFM_Plan__c+''+planline.ASI_MFM_Sub_brand_Code__c,planline.ASI_MFM_Total_Cost__c );
            } else {
                planBalanceChangeMap.put(planline.ASI_MFM_Plan__c+''+planline.ASI_MFM_Sub_brand_Code__c,planline.ASI_MFM_Remaining_Balance__c);
            }
            
        }
		string soqlStr = 'SELECT ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__c plan,ASI_MFM_Plan_Line_Item__c planline, sum(ASI_MFM_Amount__c) amount';
        soqlStr += ' ,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c subbrandcode';
        soqlStr += ' FROM ASI_MFM_PO_Line_Item__c';
        soqlStr += ' WHERE ASI_MFM_Plan_Line_Item__c IN :newbalancePliIdSet';
        soqlStr += ' GROUP BY ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__c, ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c';
        for(AggregateResult ar : database.query(soqlStr)){
            if(ar.get('subbrandcode')!=null && ar.get('subbrandcode')!=''
              && ar.get('amount')!=null && ar.get('amount')!=''
              && ar.get('planline')!=null && ar.get('planline')!='') 
            {
                Id subbrandCodeId 	= (Id)ar.get('subbrandcode');
                Id pliId 		= (Id)ar.get('planline');
                Double amount 	= (Double)ar.get('amount');
                String planBalanceKey = pliId+''+subbrandCodeId;
                if(planBalanceChangeMap.containsKey(planBalanceKey)) {
                    planBalanceChangeMap.put(planBalanceKey, planBalanceChangeMap.get(planBalanceKey)-amount);
                }
            }
        }
        system.debug('##!! planBalanceChangeMap : ' + planBalanceChangeMap);
        Set<Id> planMismatchPoSet = new Set<Id>();        
	
        List<ASI_MFM_PO_Line_Item__c> polineItemList = [SELECT id,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Plan__c,ASI_MFM_Plan_Line_Item__c
                                                        , ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Amount__c 
                                                        , ASI_MFM_Sub_brand_Code__c
                                                        FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c IN :planChangedPOIds];
        for(ASI_MFM_PO_Line_Item__c poline :polineItemList){
            if(!poBrandMap.containsKey(poline.ASI_MFM_PO__c)) {poBrandMap.put(poline.ASI_MFM_PO__c, new Set<Id>());}
            poBrandMap.get(poline.ASI_MFM_PO__c).add(poline.ASI_MFM_Sub_brand_Code__c);
        }
		for(ASI_MFM_PO__c po : triggerNew) {
            if(planChangedPOIds.contains(po.Id)) {
                Set<Id> newPlanSubBrandset = planToBrandMap.get(po.ASI_MFM_Plan__c);
                Set<Id> poSubbrandSet = poBrandMap.get(po.Id);
                system.debug('## newPlanSubBrandset ' + newPlanSubBrandset);
                system.debug('## poSubbrandSet ' + poSubbrandSet);
                //system.debug(checkSetContain(poSubbrandSet,newPlanSubBrandset));
                if(newPlanSubBrandset==null || poSubbrandSet==null) {//show error of no subbrand
                    system.debug('Missing Sub-brand');
                } else if(!checkSetContain(poSubbrandSet,newPlanSubBrandset)){
                    //New Plan not contain all subbrand in PO line items Plan
                    po.addError('Sub-brands in new assigned plan not match to previous sub-brands');
                    planMismatchPoSet.add(po.id);
                }
            }
        }

        //AM@Introv 20190807 - PRCN IT confirmed no need to check plan balance
        /*
        for(ASI_MFM_PO_Line_Item__c poline :polineItemList){
            if(planMismatchPoSet.contains(poline.ASI_MFM_PO__c)) continue;
            if(poline.ASI_MFM_Plan_Line_Item__c!=null) {
                ASI_MFM_PO__c oldpo = triggerOldMap.get(poline.ASI_MFM_PO__c);
                ASI_MFM_PO__c newpo = triggerNewMap.get(poline.ASI_MFM_PO__c);
                if(oldpo==null || newpo==null) continue;
                String oldPlan = oldpo.ASI_MFM_Plan__c+''+poline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                String newPlan = newpo.ASI_MFM_Plan__c+''+poline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                planBalanceChangeMap.put(oldPlan, planBalanceChangeMap.get(oldPlan)+poline.ASI_MFM_Amount__c);
                planBalanceChangeMap.put(newPlan, planBalanceChangeMap.get(newPlan)-poline.ASI_MFM_Amount__c);
            }
        }
        
        for(ASI_MFM_PO_Line_Item__c poline :polineItemList){
            if(planMismatchPoSet.contains(poline.ASI_MFM_PO__c)) continue;
            if(poline.ASI_MFM_Plan_Line_Item__c!=null) {
                ASI_MFM_PO__c oldpo = triggerOldMap.get(poline.ASI_MFM_PO__c);
                ASI_MFM_PO__c newpo = triggerNewMap.get(poline.ASI_MFM_PO__c);
                if(oldpo==null || newpo==null) continue;
                String oldPlan = oldpo.ASI_MFM_Plan__c+''+poline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                String newPlan = newpo.ASI_MFM_Plan__c+''+poline.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                if(planBalanceChangeMap.get(oldPlan)<0 || planBalanceChangeMap.get(newPlan)<0) {
                    newpo.addError('Exceeded plan line amount');
                }
            }
        }
        */
    }
    
    public static void routineAfterUpdate(List<ASI_MFM_PO__c> triggerNew, Map<Id, ASI_MFM_PO__c> triggerOldMap ){
        if(ASI_CRM_CN_Function.IsBypassTrigger(className)) return;
        if(passTrigger) return;
        if (checkEMarketWebService(triggerNew))	{	//AM@Introv 20190718 - fix sfdc limitation for eMarket web service
            return;
        }
        
        Set<Id> poidSet = new Set<Id>();
        List<ASI_MFM_PO_Line_Item__c> polineList = new List<ASI_MFM_PO_Line_Item__c>();
        for(ASI_MFM_PO__c po: triggerNew){
            ASI_MFM_PO__c oldPO = triggerOldMap.get(po.id);
            //AM@Introv 20191015 - fix sfdc limitation (soql 101)
            /*
            if(oldPO == null 
               || oldPO.ASI_MFM_Plan__c != po.ASI_MFM_Plan__c 
               || oldPO.ASI_MFM_PO_Amount__c != po.ASI_MFM_PO_Amount__c  ) {
                poidSet.add(po.id);
            }
			*/
            if(oldPO == null || oldPO.ASI_MFM_Plan__c != po.ASI_MFM_Plan__c) poidSet.add(po.id);
        }
        if(poidSet.size()>0) {
            for(ASI_MFM_PO_Line_Item__c poline : [SELECT id FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c IN :poidSet]){
                polineList.add(poline);
            }
            if(polineList.size()>0) update polineList;
        }
    }
    
}
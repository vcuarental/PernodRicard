public without Sharing class ASI_MFM_CN_PlanLine_TriggerClass {
    public static String className = 'ASI_MFM_CN_PlanLine_TriggerClass';
    @testVisible
    private static Boolean passTrigger = false; 
    
    public static void routineBeforeInsert(List<ASI_MFM_Plan_Line_Item__c> triggerNew){
        if(ASI_CRM_CN_Function.IsBypassTrigger(className)) return;
        for(ASI_MFM_Plan_Line_Item__c planline : triggerNew) {
			planline.ASI_MFM_Remaining_Balance__c = planline.ASI_MFM_Total_Cost__c;
        }
    }
    
    public static void routineBeforeUpdate(List<ASI_MFM_Plan_Line_Item__c> triggerNew, Map<Id, ASI_MFM_Plan_Line_Item__c> triggerOldMap){
        if(ASI_CRM_CN_Function.IsBypassTrigger(className)) return;
        if(passTrigger) return;
        Set<Id> updatePlanLineIdSet = new Set<Id>();
        List<ASI_MFM_Plan_Line_Item__c> updatePlanLineList = new List<ASI_MFM_Plan_Line_Item__c>();
        Map<id, List<ASI_MFM_PO_Line_Item__c>> mapPlanLine_PolList = new Map<id, List<ASI_MFM_PO_Line_Item__c>>();
        
        for(ASI_MFM_Plan_Line_Item__c  pl : triggerNew) {
            ASI_MFM_Plan_Line_Item__c oldPlanLine = triggerOldMap.get(pl.id);
            if(oldPlanLine.ASI_MFM_CN_ReCalculate__c != pl.ASI_MFM_CN_ReCalculate__c
              || oldPlanLine.ASI_MFM_Total_Cost__c != pl.ASI_MFM_Total_Cost__c){
                updatePlanLineIdSet.add(pl.id);
                updatePlanLineList.add(pl);
            }
        }
        for(ASI_MFM_PO_Line_Item__c poline: [
            SELECT id,ASI_MFM_Amount__c,ASI_MFM_Plan_Line_Item__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c
            FROM ASI_MFM_PO_Line_Item__c 
            WHERE ASI_MFM_Plan_Line_Item__c!=null
            AND ASI_MFM_Plan_Line_Item__c IN :updatePlanLineIdSet
        ]) {
            if(!mapPlanLine_PolList.containsKey(poline.ASI_MFM_Plan_Line_Item__c)) {
                mapPlanLine_PolList.put(poline.ASI_MFM_Plan_Line_Item__c,new List<ASI_MFM_PO_Line_Item__c>());
            }
            mapPlanLine_PolList.get(poline.ASI_MFM_Plan_Line_Item__c).add(poline);
        }
        
        for(ASI_MFM_Plan_Line_Item__c planline : updatePlanLineList) {
            Double totalPlanAmount = 0;
            if(mapPlanLine_PolList.get(planline.id)!=null){
                for(ASI_MFM_PO_Line_Item__c poline : mapPlanLine_PolList.get(planline.id)){
                    if(poline.ASI_MFM_Amount__c!=null)  {
                        Double exRate = (poline.ASI_MFM_Exchange_Rate__c != poline.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c) ? poline.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c:poline.ASI_MFM_Exchange_Rate__c;
                        if (exRate==null) exRate = 1.0;		//20190908:AM - fix test class failure
                        totalPlanAmount += (poline.ASI_MFM_Amount__c * exRate);
                    }
                    	
                }
            }
            planline.ASI_MFM_Remaining_Balance__c = planline.ASI_MFM_Total_Cost__c-totalPlanAmount;
            planline.ASI_MFM_CN_ReCalculate__c = false;
        }
	}
}
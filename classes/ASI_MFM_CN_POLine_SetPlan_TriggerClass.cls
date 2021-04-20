public without Sharing class ASI_MFM_CN_POLine_SetPlan_TriggerClass {
    public static String className = 'ASI_MFM_CN_POLine_SetPlan_TriggerClass';
    
    @testVisible
    public static Boolean passTrigger = false;
    
    @future
    public static void futurePoLineUpdate(List<Id> idList) {
        List<ASI_MFM_PO_Line_Item__c> polines = [SELECT id,ASI_MFM_PO__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_From_eMarket__c
                                                 FROM ASI_MFM_PO_Line_Item__c WHERE Id IN :idList];
        
        Map<id, Set<id>> poToPlanlinesMap = new Map<id, Set<id>>();
        Set<id> poidSet = new Set<id>();
        Set<id> planSet = new Set<id>();
        Map<id, ASI_MFM_PO__c> poMap = new Map<id, ASI_MFM_PO__c>();
        Map<string,ASI_MFM_Plan_Line_Item__c> planlineItemMap = new Map<string,ASI_MFM_Plan_Line_Item__c>();
        
        for(ASI_MFM_PO_Line_Item__c poline : polines) {
            poidSet.add(poline.ASI_MFM_PO__c);
        }

        for(ASI_MFM_PO__c po : [SELECT id, ASI_MFM_Plan__c FROM ASI_MFM_PO__c WHERE id IN :poidSet]) {
            planSet.add(po.ASI_MFM_Plan__c);
            poMap.put(po.id, po);
        }
        for(ASI_MFM_Plan_Line_Item__c  planitem : [SELECT id, ASI_MFM_Plan__c, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__c IN :planSet]) {
            planlineItemMap.put(planitem.ASI_MFM_Plan__c+''+planitem.ASI_MFM_Sub_brand_Code__c,planitem);
        }
        for(ASI_MFM_PO_Line_Item__c poline :polines) {
            id relatedPlanId = null;
            ASI_MFM_Plan_Line_Item__c planItem = null;
            ASI_MFM_PO__c relatedPo = poMap.get(poline.ASI_MFM_PO__c);
            
            if(relatedPo!=null) relatedPlanId = relatedPo.ASI_MFM_Plan__c;
            if(relatedPlanId!=null) planItem = planlineItemMap.get(relatedPlanId+''+poline.ASI_MFM_Sub_brand_Code__c);
            if(planItem!=null && poline.ASI_MFM_Plan_Line_Item__c != planItem.id) {
                poline.ASI_MFM_Plan_Line_Item__c = planItem.id;
            }
            
            poline.ASI_MFM_From_eMarket__c = false;		//this flag is for insert only, need to set false after emarket web service call
        }

        update polines;
    }
    
    //AM@Introv 20191015 - fix sfdc limitation (soql 101) start
    @TestVisible
    private static void handlePlan(Set<Id> planlineIdSet){
        List<ASI_MFM_Plan_Line_Item__c> pliList = new List<ASI_MFM_Plan_Line_Item__c>();
        for(Id plId : planlineIdSet){
            pliList.add(new ASI_MFM_Plan_Line_Item__c(id=plId,ASI_MFM_CN_ReCalculate__c=true));
        }
        update pliList;
    }
	
    @future	//AM@Introv 20191018 - cannot run future in batch
    public static void futureHandlePlan(Set<Id> planlineIdSet){
        handlePlan(planlineIdSet);
    }
    //AM@Introv 20191015 - fix sfdc limitation (soql 101) end
    
    private static boolean checkEMarketWebService(List<ASI_MFM_PO_Line_Item__c> triggerNew) {
        boolean bIsByEmarket = false;
        if (triggerNew.size()>0) {
            ASI_MFM_PO_Line_Item__c oLineItem = triggerNew[0];
            if (oLineItem.ASI_MFM_From_eMarket__c != NULL)
            	bIsByEmarket = oLineItem.ASI_MFM_From_eMarket__c;
        }
        return bIsByEmarket;
    }
    
    @testVisible
    public static void routineBeforeInsert(List<ASI_MFM_PO_Line_Item__c> triggerNew){
        if(CheckByPassTrigger()) return;
        
        List<ASI_MFM_PO_Line_Item__c> nonemktLines = new List<ASI_MFM_PO_Line_Item__c>();
        for(ASI_MFM_PO_Line_Item__c line : triggerNew) {
            if(line.ASI_MFM_From_eMarket__c != true){nonemktLines.add(line);}
        }
        if(nonemktLines.size()>0)routineBeforeUpsert(nonemktLines, new Map<Id, ASI_MFM_PO_Line_Item__c>());
    }
    
    @testVisible
    public static void routineBeforeUpdate(List<ASI_MFM_PO_Line_Item__c> triggerNew, Map<Id, ASI_MFM_PO_Line_Item__c> triggerOldMap){
        if(CheckByPassTrigger()) return;
        
        List<ASI_MFM_PO_Line_Item__c> nonemktLines = new List<ASI_MFM_PO_Line_Item__c>();
        for(ASI_MFM_PO_Line_Item__c line : triggerNew) {
            if(line.ASI_MFM_From_eMarket__c != true){nonemktLines.add(line);}
        }
        if(nonemktLines.size()>0)routineBeforeUpsert(nonemktLines, triggerOldMap);
    }

    @testVisible
    public static void routineBeforeUpsert(List<ASI_MFM_PO_Line_Item__c> triggerNew, Map<Id, ASI_MFM_PO_Line_Item__c> triggerOldMap){
        if(CheckByPassTrigger()) return;
        if (checkEMarketWebService(triggerNew))	{	//AM@Introv 20190620 - fix sfdc limitation for eMarket web service
            return;
        }
        Map<id, Set<id>> poToPlanlinesMap = new Map<id, Set<id>>();
        Set<id> poidSet = new Set<id>();
        Set<id> planSet = new Set<id>();
        Map<id, ASI_MFM_PO__c> poMap = new Map<id, ASI_MFM_PO__c>();
        Map<string,ASI_MFM_Plan_Line_Item__c> planlineItemMap = new Map<string,ASI_MFM_Plan_Line_Item__c>();
        
        //AM@Introv 20191015 - fix sfdc limitation (soql 101) - should always check plan change - start
        /*
        for(ASI_MFM_PO_Line_Item__c poline : triggerNew) {
            ASI_MFM_PO_Line_Item__c oldPoline = triggerOldMap.get(poline.id);
            if(oldPoline == null 
               || oldPoline.ASI_MFM_Sub_brand_Code__c!=poline.ASI_MFM_Sub_brand_Code__c
               || oldPoline.ASI_MFM_Amount__c != poline.ASI_MFM_Amount__c
              ) {
                poidSet.add(poline.ASI_MFM_PO__c);
            }

        }
        if(poidSet.size()==0) return;
		*/
        for(ASI_MFM_PO_Line_Item__c poline : triggerNew) {
            poidSet.add(poline.ASI_MFM_PO__c);
        }
        //AM@Introv 20191015 - fix sfdc limitation (soql 101) - should always check plan change - end

        for(ASI_MFM_PO__c po : [SELECT id, ASI_MFM_Plan__c FROM ASI_MFM_PO__c WHERE id IN :poidSet]) {
            planSet.add(po.ASI_MFM_Plan__c);
            poMap.put(po.id, po);
        }
        for(ASI_MFM_Plan_Line_Item__c  planitem : [SELECT id, ASI_MFM_Plan__c, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__c IN :planSet]) {
            planlineItemMap.put(planitem.ASI_MFM_Plan__c+''+planitem.ASI_MFM_Sub_brand_Code__c,planitem);
        }
        for(ASI_MFM_PO_Line_Item__c poline :triggerNew) {
            id relatedPlanId = null;
            ASI_MFM_Plan_Line_Item__c planItem = null;
            ASI_MFM_PO__c relatedPo = poMap.get(poline.ASI_MFM_PO__c);
            
            if(relatedPo!=null) relatedPlanId = relatedPo.ASI_MFM_Plan__c;
            if(relatedPlanId!=null) planItem = planlineItemMap.get(relatedPlanId+''+poline.ASI_MFM_Sub_brand_Code__c);
            if(planItem!=null && poline.ASI_MFM_Plan_Line_Item__c != planItem.id) {
                poline.ASI_MFM_Plan_Line_Item__c = planItem.id;
            }
        }
    }
    
    public static void routineAfterUpdate(List<ASI_MFM_PO_Line_Item__c> triggerNew, Map<Id, ASI_MFM_PO_Line_Item__c> triggerOldMap ){
        if(CheckByPassTrigger()) return;
        
        Set<Id> planlineIdSet = new Set<Id>();
        for(ASI_MFM_PO_Line_Item__c pol : triggerNew){
            ASI_MFM_PO_Line_Item__c polOld = triggerOldMap.get(pol.id);
            if( pol.ASI_MFM_Plan_Line_Item__c!=null 
               &&(pol.ASI_MFM_Plan_Line_Item__c != polOld.ASI_MFM_Plan_Line_Item__c
               || pol.ASI_MFM_Amount__c != polOld.ASI_MFM_Amount__c)
              ) {
                if(pol.ASI_MFM_Plan_Line_Item__c!=null)planlineIdSet.add(pol.ASI_MFM_Plan_Line_Item__c);
                if(polOld.ASI_MFM_Plan_Line_Item__c!=null)planlineIdSet.add(polOld.ASI_MFM_Plan_Line_Item__c);                
            }
        }
        if(planlineIdSet.size()>0) futureHandlePlan(planlineIdSet);		//AM@Introv 20191015 - fix sfdc limitation (soql 101) handlePlan(planlineIdSet);
    }
    
    public static void routineAfterInsert(List<ASI_MFM_PO_Line_Item__c> triggerNew) {
        if(CheckByPassTrigger()) return;
        
        List<Id> listId = new List<Id>();
        for(ASI_MFM_PO_Line_Item__c pol : triggerNew) {
            if(pol.id!=null && pol.ASI_MFM_From_eMarket__c==true)listId.add(pol.id);   
        }
        if(listId.size()>0)ASI_MFM_CN_POLine_SetPlan_TriggerClass.futurePoLineUpdate(listId);

        Set<Id> planlineIdSet = new Set<Id>();
        for(ASI_MFM_PO_Line_Item__c pol : triggerNew) {
            if(pol.ASI_MFM_Plan_Line_Item__c!=null && pol.ASI_MFM_From_eMarket__c!=true) planlineIdSet.add(pol.ASI_MFM_Plan_Line_Item__c);
        }
        if(planlineIdSet.size()>0) futureHandlePlan(planlineIdSet);		//AM@Introv 20191015 - fix sfdc limitation (soql 101) handlePlan(planlineIdSet);
    }

    public static void routineAfterDelete(List<ASI_MFM_PO_Line_Item__c> triggerOld){
        if(CheckByPassTrigger()) return;
        
        Set<Id> planlineIdSet = new Set<Id>();
        for(ASI_MFM_PO_Line_Item__c pol : triggerOld) {
            if(pol.ASI_MFM_Plan_Line_Item__c!=null) planlineIdSet.add(pol.ASI_MFM_Plan_Line_Item__c);
        }
        if(planlineIdSet.size()>0) futureHandlePlan(planlineIdSet);		//AM@Introv 20191015 - fix sfdc limitation (soql 101) handlePlan(planlineIdSet);
    }

    public static void routineAfterUndelete(List<ASI_MFM_PO_Line_Item__c> triggerNew){
        if(CheckByPassTrigger()) return;
        
        Set<Id> planlineIdSet = new Set<Id>();
        for(ASI_MFM_PO_Line_Item__c pol : triggerNew) {
            if(pol.ASI_MFM_Plan_Line_Item__c!=null) planlineIdSet.add(pol.ASI_MFM_Plan_Line_Item__c);
        }
        if(planlineIdSet.size()>0) futureHandlePlan(planlineIdSet);		//AM@Introv 20191015 - fix sfdc limitation (soql 101) handlePlan(planlineIdSet);
    }
    
    private static boolean CheckByPassTrigger() {
        boolean bByPass = false;
        
        if (!bByPass) {
        	bByPass = (system.isBatch() || system.isFuture());
        }
        if (!bByPass) {
            bByPass = ASI_CRM_CN_Function.IsBypassTrigger(className);
        }
        if (!bByPass) {
            bByPass = passTrigger;
        }
                
        return bByPass;
    }

}
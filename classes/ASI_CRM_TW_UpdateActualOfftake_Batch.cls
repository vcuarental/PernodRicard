/*Created by Twinkle Li @04/20/2015
* Batch Apex to update Actual Offtake Records (record type: ASI CRM TW Actual Offtake (Target Vol)) with Contract Target figures
* Update Actual Offtake (from original record type), Outlet Depletion & Bottle Head
*/

global class ASI_CRM_TW_UpdateActualOfftake_Batch implements Database.Batchable<sObject>, Database.Stateful{
    Public Integer monthOffset {get;set;} 
    Public Date fromDate {get;set;}
    Public Date toDate {get;set;}
    Public Integer baseYear {get;set;}
    Public Integer baseMonth {get;set;}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        monthOffset = -1; //default value if custom setting not found
        ASI_CRM_TW_Settings__c customSettingTW = [SELECT id, ASI_CRM_TW_ActualOfftake_Offset__c FROM ASI_CRM_TW_Settings__c];
        if(customSettingTW != null && customSettingTW.ASI_CRM_TW_ActualOfftake_Offset__c != null)
            monthOffset = (Integer)customSettingTW.ASI_CRM_TW_ActualOfftake_Offset__c;
        
        Date tmpDate = Date.today().addMonths(monthOffset);       
        fromDate = Date.newInstance(tmpDate.year(),tmpDate.month(),1);
        
        tmpDate = fromDate.addMonths(1);
        toDate = Date.newInstance(tmpDate.year(),tmpDate.month(),1);
        
        baseYear = fromDate.Year();
        baseMonth = fromDate.Month();
        String soqlQuery = 'SELECT Id, ASI_TH_CRM_Sub_brand__c, ASI_TH_CRM_Outlet__c, ASI_TH_CRM_Outlet__r.ASI_HK_CRM_IsDeliveryAccount__c, ASI_TH_CRM_Month__c, ASI_TH_CRM_Quantity__c, ASI_CRM_Bottle_Head__c, ASI_CRM_Box_Lid__c, ASI_CRM_Depletion__c, ASI_CRM_Target_Vol__c FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_TH_CRM_Month__c = \'' +String.valueof(baseMonth)+ '\' AND ASI_TH_CRM_Year__c = \'' +String.valueof(baseYear)+ '\' AND RecordType.DeveloperName = \'ASI_CRM_TW_Actual_Offtake_Target_Vol\'';
        
        system.debug('soqlQuery: ' + soqlQuery);
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_TH_CRM_Actual_Offtake__c> listActualOfftake_TargetVol){   
        List<ASI_TH_CRM_Actual_Offtake__c> listActualOfftake_Origin = new List<ASI_TH_CRM_Actual_Offtake__c>();
        //List<ASI_MFM_Plan_Line_Item__c> listPlanLineItem = new List<ASI_MFM_Plan_Line_Item__c>();
        List<ASI_CRM_OutletDepletion__c> listOutletDep = new List<ASI_CRM_OutletDepletion__c>();
       
        Set<Id> outletId = new Set<Id>();
        Set<Id> subBrandId = new Set<Id>();
        Set<Id> parentOutletId = new Set<Id>();
        
        Map<String, ASI_TH_CRM_Actual_Offtake__c> mapActualOfftake = new Map<String, ASI_TH_CRM_Actual_Offtake__c>();
        //Map<String, ASI_MFM_Plan_Line_Item__c> mapPlanLineItem = new Map<String, ASI_MFM_Plan_Line_Item__c>();
        Map<String, ASI_CRM_OutletDepletion__c> mapOutletDep = new Map<String, ASI_CRM_OutletDepletion__c>();        
        Map<Id, Id> mapParentChildOutlet = new Map<Id, Id>();
        
        for(ASI_TH_CRM_Actual_Offtake__c itm : listActualOfftake_TargetVol){
            outletId.add(itm.ASI_TH_CRM_Outlet__c);
            if(itm.ASI_TH_CRM_Outlet__r.ASI_HK_CRM_IsDeliveryAccount__c){
                parentOutletId.add(itm.ASI_TH_CRM_Outlet__c);
            }
            subBrandId.add(itm.ASI_TH_CRM_Sub_brand__c);
        }
        
        //Get child outlet id, matching with parent
        for(Account acc: [SELECT id, ParentId FROM Account WHERE ParentId IN : parentOutletId]){
            mapParentChildOutlet.put(acc.id, acc.ParentId);
            outletId.add(acc.id);
        }
        
        //Query Actual Offtake values
        listActualOfftake_Origin = [SELECT Id, ASI_TH_CRM_Quantity__c, ASI_TH_CRM_Outlet__c, ASI_TH_CRM_Sub_brand__c FROM ASI_TH_CRM_Actual_Offtake__c WHERE ASI_TH_CRM_Outlet__c IN:outletId AND ASI_TH_CRM_Sub_brand__c IN:subBrandId AND RecordType.DeveloperName = 'ASI_CRM_TW_Actual_Offtake' AND ASI_TH_CRM_Offtake_G_L_Date__c >=: fromDate AND ASI_TH_CRM_Offtake_G_L_Date__c < :toDate];
        for(ASI_TH_CRM_Actual_Offtake__c itm : listActualOfftake_Origin){
            ASI_TH_CRM_Actual_Offtake__c objActualOff = new ASI_TH_CRM_Actual_Offtake__c();
            //If it is an child outlet
            if(outletId.contains(itm.ASI_TH_CRM_Outlet__c) && !parentOutletId.contains(itm.ASI_TH_CRM_Outlet__c)){
                if(mapActualOfftake.containsKey(string.valueOf(mapParentChildOutlet.get(itm.ASI_TH_CRM_Outlet__c))+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c))){
                    objActualOff = mapActualOfftake.get(mapParentChildOutlet.get(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c));
                    objActualOff.ASI_TH_CRM_Quantity__c += itm.ASI_TH_CRM_Quantity__c;
                }
                else
                    objActualOff = itm;
            }
            //If it is a parent outlet
            else if(parentOutletId.contains(itm.ASI_TH_CRM_Outlet__c)){
                if(mapActualOfftake.containsKey(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c))){
                    objActualOff = mapActualOfftake.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c));
                    objActualOff.ASI_TH_CRM_Quantity__c += itm.ASI_TH_CRM_Quantity__c;
                }
                else
                    objActualOff= itm;
            }
            //Otherwise
            else
                objActualOff= itm;
                
            mapActualOfftake.put(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c), objActualOff);
        }
        system.debug(mapActualOfftake);
        
        //Query Target Vol. values
        /*listPlanLineItem = [SELECT Id, ASI_MFM_Plan__r.ASI_MFM_Account__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Expected_Volume__c FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__r.ASI_MFM_Account__c IN:outletId AND ASI_MFM_Sub_brand_Code__c IN:subBrandId AND RecordType.DeveloperName = 'ASI_MFM_TW_Plan_Line_Item'];
        for(ASI_MFM_Plan_Line_Item__c itm : listPlanLineItem){
            mapPlanLineItem.put(string.valueOf(itm.ASI_MFM_Plan__r.ASI_MFM_Account__c)+string.valueOf(itm.ASI_MFM_Sub_brand_Code__c), itm);
        }
        system.debug(mapPlanLineItem);*/
        
        //Query Depletion & Bottle head values
        listOutletDep = [SELECT Id, ASI_CRM_Outlet__c, ASI_CRM_SubBrand__c, ASI_CRM_Bottle_Head__c, ASI_CRM_Depletion__c FROM ASI_CRM_OutletDepletion__c WHERE ASI_CRM_Outlet__c IN:outletId AND ASI_CRM_SubBrand__c IN:subBrandId AND RecordType.DeveloperName = 'ASI_CRM_TW_OutletDepletion_RcrdTyp' AND ASI_CRM_Date__c >=: fromDate AND ASI_CRM_Date__c < :toDate];
        for(ASI_CRM_OutletDepletion__c itm : listOutletDep){
            ASI_CRM_OutletDepletion__c objOutletDepl = new ASI_CRM_OutletDepletion__c();
            //If it is an child outlet
            if(outletId.contains(itm.ASI_CRM_Outlet__c) && !parentOutletId.contains(itm.ASI_CRM_Outlet__c)){
                if(mapOutletDep.containsKey(string.valueOf(mapParentChildOutlet.get(itm.ASI_CRM_Outlet__c))+string.valueOf(itm.ASI_CRM_SubBrand__c))){
                    objOutletDepl = mapOutletDep.get(mapParentChildOutlet.get(itm.ASI_CRM_Outlet__c)+string.valueOf(itm.ASI_CRM_SubBrand__c));
                    objOutletDepl.ASI_CRM_Depletion__c += itm.ASI_CRM_Depletion__c;
                    objOutletDepl.ASI_CRM_Bottle_Head__c += itm.ASI_CRM_Bottle_Head__c;
                }
                else
                    objOutletDepl = itm;
            }
            //If it is a parent outlet
            else if(parentOutletId.contains(itm.ASI_CRM_Outlet__c)){
                if(mapOutletDep.containsKey(string.valueOf(itm.ASI_CRM_Outlet__c)+string.valueOf(itm.ASI_CRM_SubBrand__c))){
                    objOutletDepl = mapOutletDep.get(string.valueOf(itm.ASI_CRM_Outlet__c)+string.valueOf(itm.ASI_CRM_SubBrand__c));
                    objOutletDepl.ASI_CRM_Depletion__c += itm.ASI_CRM_Depletion__c;
                    objOutletDepl.ASI_CRM_Bottle_Head__c += itm.ASI_CRM_Bottle_Head__c;
                }
                else
                    objOutletDepl = itm;
            }
            //Otherwise
            else
                objOutletDepl = itm;
                
            mapOutletDep.put(string.valueOf(itm.ASI_CRM_Outlet__c)+string.valueOf(itm.ASI_CRM_SubBrand__c), objOutletDepl);
        }
        system.debug(mapOutletDep);
        
        //Update Actual Offtake Values with Target Vol. record type
        for(ASI_TH_CRM_Actual_Offtake__c itm : listActualOfftake_TargetVol){
            if(itm.ASI_TH_CRM_Outlet__c != NULL && itm.ASI_TH_CRM_Sub_brand__c != NULL && mapActualOfftake.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c)) != NULL)
                itm.ASI_TH_CRM_Quantity__c = mapActualOfftake.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c)).ASI_TH_CRM_Quantity__c ;
            else
                itm.ASI_TH_CRM_Quantity__c = 0;
            /*if(mapPlanLineItem.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c)) != NULL)
                itm.ASI_CRM_Target_Vol__c = mapPlanLineItem.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c)).ASI_MFM_Expected_Volume__c ;*/
            if(itm.ASI_TH_CRM_Outlet__c != NULL && itm.ASI_TH_CRM_Sub_brand__c != NULL && mapOutletDep.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c)) != NULL){
                itm.ASI_CRM_Depletion__c = mapOutletDep.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c)).ASI_CRM_Depletion__c;
                itm.ASI_CRM_Bottle_Head__c = mapOutletDep.get(string.valueOf(itm.ASI_TH_CRM_Outlet__c)+string.valueOf(itm.ASI_TH_CRM_Sub_brand__c)).ASI_CRM_Bottle_Head__c;
            }
            else{
                itm.ASI_CRM_Depletion__c = 0;
                itm.ASI_CRM_Bottle_Head__c = 0;
            }
        }
        update listActualOfftake_TargetVol;
    }
    
    global void finish(Database.BatchableContext BC){
    } 
}
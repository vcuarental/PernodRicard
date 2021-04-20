/*********************************************************************************
 * Name:ASI_CRM_JP_InsertRepeatCallDetail
 * Description: Insert Repeat Call Detail for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 16/12/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_InsertRepeatCallDetail extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_InsertRepeatCallDetail() {
        super('ASI_CRM_JP_InsertRepeatCallDetail');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Call_Plan__c> planList = (List<ASI_CRM_Call_Plan__c>)sObjList;
        List<ASI_CRM_Call_Detail__c> newDetailList = new List<ASI_CRM_Call_Detail__c >();
        Set<Id> repeatIdSet = new Set<Id>();
        String theQuery = 'Select ';
        
        if (oldMap == null) {
            for (ASI_CRM_Call_Plan__c plan: planList) {
                repeatIdSet.add(plan.OwnerId);
            }
            Map<String, Schema.SObjectField> callDetailFieldMap = Schema.SObjectType.ASI_CRM_Call_Detail__c.fields.getMap();
            for(String fields:callDetailFieldMap.keySet()){
                theQuery += fields + ' ,';
            }
            thequery = theQuery.subString(0,theQuery.length()-1);
            thequery += 'From ASI_CRM_Call_Detail__c where CreatedById In :repeatIdSet And ASI_CRM_Original_Call_Detail__c = null';
            List<ASI_CRM_Call_Detail__c> detailList = (List<ASI_CRM_Call_Detail__c>)Database.query(theQuery);
            
            for (ASI_CRM_Call_Plan__c plan: planList) {
                for(ASI_CRM_Call_Detail__c detail:detailList){
                    if(detail.CreatedById == plan.OwnerId){
                        if(detail.ASI_CRM_Pattern__c == 'Weekly'){
                            Integer numOfDays = detail.ASI_CRM_Visit_Date_Formula__c.daysBetween(detail.ASI_CRM_Repeat_End_Date__c);
                            Integer i = 0;
                            for(i=(7*Integer.valueOf(detail.ASI_CRM_Frequency__c));i<=numOfDays;i+=(7*Integer.valueOf(detail.ASI_CRM_Frequency__c))){
                                if(Date.valueOf(plan.ASI_CRM_Period_From__c) <= detail.ASI_CRM_Visit_Date_From__c.date().addDays(i) &&
                                        Date.valueOf(plan.ASI_CRM_Period_To__c) >= detail.ASI_CRM_Visit_Date_From__c.date().addDays(i)){
                                    ASI_CRM_Call_Detail__c newDetail = new ASI_CRM_Call_Detail__c();
                                    newDetail = detail.clone(true,true);
                                    newDetail.id = null;
                                    newDetail.ASI_CRM_Call_Plan__c = plan.Id;
                                    newDetail.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat');
                                    newDetail.ASI_CRM_Visit_Date_From__c = detail.ASI_CRM_Visit_Date_From__c.addDays(i);
                                    newDetail.ASI_CRM_Visit_Date_To__c = detail.ASI_CRM_Visit_Date_To__c.addDays(i);
                                    newDetail.ASI_CRM_Original_Call_Detail__c = detail.id;
                                    newDetail.ASI_CRM_Status__c = 'Draft';
                                    newDetail.ASI_CRM_JDE_Document_No__c='';
                                    newDetail.ASI_CRM_JDE_Synced__c=false;
                                    newDetailList.add(newDetail); 
                                }
                            }
                        }else if(detail.ASI_CRM_Pattern__c == 'Monthly'){
                            Integer numOfMonths = detail.ASI_CRM_Visit_Date_Formula__c.monthsBetween(detail.ASI_CRM_Repeat_End_Date__c);
                            Integer i = 0;
                            for(i=Integer.valueOf(detail.ASI_CRM_Frequency__c);i<=numOfMonths;i+=Integer.valueOf(detail.ASI_CRM_Frequency__c)){
                                if(Date.valueOf(plan.ASI_CRM_Period_From__c) <= detail.ASI_CRM_Visit_Date_From__c.date().addMonths(i) &&
                                        Date.valueOf(plan.ASI_CRM_Period_To__c) >= detail.ASI_CRM_Visit_Date_From__c.date().addMonths(i) &&
                                        detail.ASI_CRM_Visit_Date_From__c.addMonths(i).day() == detail.ASI_CRM_Visit_Date_From__c.day() &&
                                        detail.ASI_CRM_Visit_Date_To__c.addMonths(i).day() == detail.ASI_CRM_Visit_Date_To__c.day()){
                                    ASI_CRM_Call_Detail__c newDetail = new ASI_CRM_Call_Detail__c();
                                    newDetail = detail.clone(true,true);
                                    newDetail.id = null;
                                    newDetail.ASI_CRM_Call_Plan__c = plan.Id;
                                    newDetail.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat');
                                    newDetail.ASI_CRM_Visit_Date_From__c = detail.ASI_CRM_Visit_Date_From__c.addMonths(i);
                                    newDetail.ASI_CRM_Visit_Date_To__c = detail.ASI_CRM_Visit_Date_To__c.addMonths(i);
                                    newDetail.ASI_CRM_Original_Call_Detail__c = detail.id;
                                    newDetail.ASI_CRM_Status__c = 'Draft';
                                    newDetail.ASI_CRM_JDE_Document_No__c='';
                                    newDetail.ASI_CRM_JDE_Synced__c=false;
                                    newDetailList.add(newDetail);       
                                }
                            }
                        }
                    }
                }
            }            
        }
        else {
            Map<ID, ASI_CRM_Call_Plan__c> oldPlanMap = (Map<ID, ASI_CRM_Call_Plan__c>) oldMap;
            Set<Id> planIdSet = new Set<Id>(); 
            for (ASI_CRM_Call_Plan__c plan:planList) {
                if(plan.ASI_CRM_Period_From__c != oldPlanMap.get(plan.id).ASI_CRM_Period_From__c || plan.ASI_CRM_Period_To__c != oldPlanMap.get(plan.id).ASI_CRM_Period_To__c){
                    repeatIdSet.add(plan.OwnerId);
                    planIdSet.add(plan.Id);
                }
            }
            Map<String, Schema.SObjectField> callDetailFieldMap = Schema.SObjectType.ASI_CRM_Call_Detail__c.fields.getMap();
            for(String fields:callDetailFieldMap.keySet()){
                theQuery += fields + ' ,';
            }
            thequery = theQuery.subString(0,theQuery.length()-1);
            thequery += 'From ASI_CRM_Call_Detail__c where CreatedById In :repeatIdSet And ASI_CRM_Original_Call_Detail__c = null'; 
            List<ASI_CRM_Call_Detail__c> detailList = (List<ASI_CRM_Call_Detail__c>)Database.query(theQuery);
            List<ASI_CRM_Call_Detail__c> existDetailList = [Select ASI_CRM_Call_Plan__c, ASI_CRM_Visit_Date_Formula__c, ASI_CRM_Original_Call_Detail__c From ASI_CRM_Call_Detail__c Where CreatedById In :repeatIdSet And ASI_CRM_Original_Call_Detail__c <> null And ASI_CRM_Call_Plan__c In :planIdSet];
            for (ASI_CRM_Call_Plan__c plan: planList) {
                for(ASI_CRM_Call_Detail__c detail:detailList){
                    if(detail.CreatedById == plan.OwnerId){
                        if(detail.ASI_CRM_Pattern__c == 'Weekly'){
                            Integer numOfDays = detail.ASI_CRM_Visit_Date_Formula__c.daysBetween(detail.ASI_CRM_Repeat_End_Date__c);
                            Integer i = 0;
                            for(i=(7*Integer.valueOf(detail.ASI_CRM_Frequency__c));i<=numOfDays;i+=(7*Integer.valueOf(detail.ASI_CRM_Frequency__c))){
                                Boolean isInsert = true;
                                for (ASI_CRM_Call_Detail__c existDetail:existDetailList){
                                    if(isInsert && existDetail.ASI_CRM_Original_Call_Detail__c == detail.Id && existDetail.ASI_CRM_Visit_Date_Formula__c == detail.ASI_CRM_Visit_Date_Formula__c.addDays(i) && existDetail.ASI_CRM_Call_Plan__c == plan.Id){
                                        isInsert = false;
                                    }
                                }
                                if(isInsert && Date.valueOf(plan.ASI_CRM_Period_From__c) <= detail.ASI_CRM_Visit_Date_From__c.date().addDays(i) &&
                                        Date.valueOf(plan.ASI_CRM_Period_To__c) >= detail.ASI_CRM_Visit_Date_From__c.date().addDays(i)){
                                    ASI_CRM_Call_Detail__c newDetail = new ASI_CRM_Call_Detail__c();
                                    newDetail = detail.clone(true,true);
                                    newDetail.id = null;
                                    newDetail.ASI_CRM_Call_Plan__c = plan.Id;
                                    newDetail.ASI_CRM_Visit_Date_From__c = detail.ASI_CRM_Visit_Date_From__c.addDays(i);
                                    newDetail.ASI_CRM_Visit_Date_To__c = detail.ASI_CRM_Visit_Date_To__c.addDays(i);
                                    newDetail.ASI_CRM_Original_Call_Detail__c = detail.id;
                                    newDetail.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat');
                                    newDetail.ASI_CRM_Status__c = 'Draft';
                                    newDetailList.add(newDetail);
                                }
                            }
                        }else if(detail.ASI_CRM_Pattern__c == 'Monthly'){
                            Integer numOfMonths = detail.ASI_CRM_Visit_Date_Formula__c.monthsBetween(detail.ASI_CRM_Repeat_End_Date__c);
                            Integer i = 0;
                            for(i=Integer.valueOf(detail.ASI_CRM_Frequency__c);i<=numOfMonths;i+=Integer.valueOf(detail.ASI_CRM_Frequency__c)){
                                Boolean isInsert = true;
                                for (ASI_CRM_Call_Detail__c existDetail:existDetailList){
                                    if(isInsert && existDetail.ASI_CRM_Original_Call_Detail__c == detail.Id && existDetail.ASI_CRM_Visit_Date_Formula__c == detail.ASI_CRM_Visit_Date_Formula__c.addMonths(i) && existDetail.ASI_CRM_Call_Plan__c == plan.Id){
                                        isInsert = false;
                                    }
                                }
                                if(isInsert && Date.valueOf(plan.ASI_CRM_Period_From__c) <= detail.ASI_CRM_Visit_Date_From__c.date().addMonths(i) &&
                                        Date.valueOf(plan.ASI_CRM_Period_To__c) >= detail.ASI_CRM_Visit_Date_From__c.date().addMonths(i) &&
                                        detail.ASI_CRM_Visit_Date_From__c.addMonths(i).day() == detail.ASI_CRM_Visit_Date_From__c.day() && 
                                        detail.ASI_CRM_Visit_Date_To__c.addMonths(i).day() == detail.ASI_CRM_Visit_Date_To__c.day()){
                                    ASI_CRM_Call_Detail__c newDetail = new ASI_CRM_Call_Detail__c();
                                    newDetail = detail.clone(true,true);
                                    newDetail.id = null;
                                    newDetail.ASI_CRM_Call_Plan__c = plan.Id;
                                    newDetail.ASI_CRM_Visit_Date_From__c = detail.ASI_CRM_Visit_Date_From__c.addMonths(i);
                                    newDetail.ASI_CRM_Visit_Date_To__c = detail.ASI_CRM_Visit_Date_To__c.addMonths(i);
                                    newDetail.ASI_CRM_Original_Call_Detail__c = detail.id;
                                    newDetail.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat');
                                    newDetail.ASI_CRM_Status__c = 'Draft';
                                    newDetailList.add(newDetail);       
                                }
                            }
                        }
                    }
                }
            }            
            
        }
        
        if(newDetailList.size() > 0){
            insert newDetailList;
        }
    }
    
}
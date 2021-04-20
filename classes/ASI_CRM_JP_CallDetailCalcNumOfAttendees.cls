/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetailCalcNumOfAttendees
 * Description: Trigger Handler for calculating number of attendees of CRM JP
 * Test Class: ASI_CRM_JP_CallDetail_Test3
 * 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/11/2014       Laputa: Hank          Created
 * 08/10/2019       Wilken Lee          	[WL 1.0] Add Tax Rate/Area picklist and default Tax Rate
*********************************************************************************/

public with sharing class ASI_CRM_JP_CallDetailCalcNumOfAttendees extends ASI_CRM_JP_TriggerAbstract {
    
    
    public ASI_CRM_JP_CallDetailCalcNumOfAttendees() {
        super('ASI_CRM_JP_CallDetailCalcNumOfAttendees');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Call_Detail__c> detailList = (List<ASI_CRM_Call_Detail__c>)sObjList;
        Map<Id, User> ownerMap = new Map<Id, User>();
        Map<Id, ASI_CRM_Call_Detail__c> detailMap = new Map<Id, ASI_CRM_Call_Detail__c>();
        Set<Id> headerIdSet = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        Set<Id> detailIdSet = new Set<Id>();
        List<ASI_JP_TnE_Tax_Date_Mapping__c> taxDtMapList = ASI_JP_TnE_Tax_Date_Mapping__c.getAll().values();
        
		/*[WL 1.0] BEGIN*/
		for (ASI_CRM_Call_Detail__c detail:detailList){
			//Default Tax Rate/Area if blank
			if (detail.ASI_CRM_Tax_Rate_Area__c == null){
				for (ASI_JP_TnE_Tax_Date_Mapping__c taxmap:taxDtMapList){
					if (taxmap.ASI_JP_TnE_Start_Date__c <= detail.ASI_CRM_Visit_Date_From__c && detail.ASI_CRM_Visit_Date_From__c <= taxmap.ASI_JP_TnE_End_Date__c && taxmap.ASI_JP_TnE_IsDefault_Tax_Rate__c){
						detail.ASI_CRM_Tax_Rate_Area__c = taxmap.ASI_TnE_Tax_Area__c;
					}
				}
			}
			
			//Default Tax Rate % based on assigned Tax Rate/Area
			if (detail.ASI_CRM_Tax_Rate_Area__c == 'CP0')
				detail.ASI_CRM_Tax_Rate__c = 0;
			else if (detail.ASI_CRM_Tax_Rate_Area__c == 'CP8' || detail.ASI_CRM_Tax_Rate_Area__c == 'CP8R')
				detail.ASI_CRM_Tax_Rate__c = 8;
			else if (detail.ASI_CRM_Tax_Rate_Area__c == 'CP10')
				detail.ASI_CRM_Tax_Rate__c = 10;
		}
		/*[WL 1.0] END*/
		
        if (oldMap == null) {
            for (ASI_CRM_Call_Detail__c detail: detailList) {
                headerIdSet.add(detail.ASI_CRM_Call_Plan__c);
                for(ASI_JP_TnE_Tax_Date_Mapping__c t:taxDtMapList){
                    if(t.ASI_JP_TnE_Start_Date__c <= detail.ASI_CRM_Visit_Date_Formula__c && detail.ASI_CRM_Visit_Date_Formula__c <= t.ASI_JP_TnE_End_Date__c){
                        detail.ASI_CRM_Tax_Rate__c = 100 * t.ASI_JP_TnE_Tax_Rate__c;
                    }
                }
            }
            for(ASI_CRM_Call_Plan__c plan: [Select OwnerId From ASI_CRM_Call_Plan__c Where Id In:headerIdSet]){
                ownerIdSet.add(plan.OwnerId);
            }
            ownerMap = new Map<Id, User>([Select Id, Name, ASI_JP_TnE_Department_Category_Code__c From User Where Id In :ownerIdSet]);
            for(ASI_CRM_Call_Plan__c plan: [Select OwnerId From ASI_CRM_Call_Plan__c Where Id In:headerIdSet]){
                ownerMap.put(plan.Id, ownerMap.get(plan.OwnerId));
            }
        }
        else {
            Map<ID, ASI_CRM_Call_Detail__c> oldDetailMap = (Map<ID, ASI_CRM_Call_Detail__c>) oldMap;
            for (ASI_CRM_Call_Detail__c detail: detailList) {
                detailIdSet.add(detail.Id);
                // If Status is Cancelled, remove the Reminder Id and Reminder checkbox
                if (detail.ASI_CRM_Status__c == 'Cancelled' && detail.ASI_CRM_Reminder_Id__c != null && (detail.ASI_CRM_Status__c != oldDetailMap.get(detail.Id).ASI_CRM_Status__c)) {
                    //detail.ASI_CRM_Reminder_Id__c = null;
                    detail.ASI_CRM_Reminder__c = false;
                }
                if(detail.ASI_CRM_Visit_Date_Formula__c != oldDetailMap.get(detail.Id).ASI_CRM_Visit_Date_Formula__c){
                    for(ASI_JP_TnE_Tax_Date_Mapping__c t:taxDtMapList){
                        if(t.ASI_JP_TnE_Start_Date__c <= detail.ASI_CRM_Visit_Date_Formula__c && detail.ASI_CRM_Visit_Date_Formula__c <= t.ASI_JP_TnE_End_Date__c){
                            detail.ASI_CRM_Tax_Rate__c = 100 * t.ASI_JP_TnE_Tax_Rate__c;
                        }
                    }
                }
            }
            
            detailMap = new Map<Id, ASI_CRM_Call_Detail__c>([Select Id, (Select ASI_CRM_Attendee__r.Name, ASI_CRM_Department_Code__c From Employee_Attendees__r) From ASI_CRM_Call_Detail__c Where Id In: detailIdSet ]);
        }
        
        if (oldMap == null) {
            for (ASI_CRM_Call_Detail__c detail: detailList) {
                allAttendees ='';
                allAttendees = ownerMap.get(detail.ASI_CRM_Call_Plan__c).Name;
                if(ownerMap.get(detail.ASI_CRM_Call_Plan__c).ASI_JP_TnE_Department_Category_Code__c == '1'){
                    PRJAttendees = ownerMap.get(detail.ASI_CRM_Call_Plan__c).Name;
                }
                detail.ASI_CRM_Number_of_Attendees_BS__c = calcNumOfAttendees(detail.ASI_CRM_Attendees_BS__c);
                detail.ASI_CRM_Number_of_Attendees_Other__c= calcNumOfAttendees(detail.ASI_CRM_Attendees_Other__c) + detail.ASI_CRM_Number_of_PRJ_Other_Attendees__c;
                detail.ASI_CRM_JP_All_Attendees__c = allAttendees;
                detail.ASI_CRM_Attendees_PRJ__c = PRJAttendees;
                //Verify the number of Attendees is the same with the field Total Number Of Attendess
                /*
                if (calcNumOfAttendees(detail.ASI_CRM_JP_All_Attendees__c) != (detail.ASI_CRM_Number_of_Attendees_Other__c + detail.ASI_CRM_Number_of_Attendees_BS__c + detail.ASI_CRM_Number_of_PRJ_Sales_Attendees__c) + 1) {
                    detail.addError(System.Label.ASI_CRM_JP_Call_Detail_NumOfAttendeesError);
                }
                */
            }
        }
        else {
            Map<ID, ASI_CRM_Call_Detail__c> oldDetailMap = (Map<ID, ASI_CRM_Call_Detail__c>) oldMap;
            for (ASI_CRM_Call_Detail__c detail: detailList) {
                allAttendees = '';
                PRJAttendees = '';
                for (ASI_CRM_Employee_Attendee__c att: detailMap.get(detail.id).Employee_Attendees__r) {
                    if (allAttendees == ''){
                        allAttendees += att.ASI_CRM_Attendee__r.Name;
                    }else{
                        allAttendees += ';' + att.ASI_CRM_Attendee__r.Name;
                    }
                    if(att.ASI_CRM_Department_Code__c == '1'){
                        if(PRJAttendees == ''){
                            PRJAttendees += att.ASI_CRM_Attendee__r.Name;
                        }else{
                            PRJAttendees += ';' + att.ASI_CRM_Attendee__r.Name; 
                        }
                    }
                }
                detail.ASI_CRM_Number_of_Attendees_BS__c = calcNumOfAttendees(detail.ASI_CRM_Attendees_BS__c);
                detail.ASI_CRM_Number_of_Attendees_Other__c = calcNumOfAttendees(detail.ASI_CRM_Attendees_Other__c) + detail.ASI_CRM_Number_of_PRJ_Other_Attendees__c;
                detail.ASI_CRM_JP_All_Attendees__c = allAttendees;
                detail.ASI_CRM_Attendees_PRJ__c = PRJAttendees;
            }
        }
    }
    
    private String allAttendees ='';
    private String PRJAttendees = '';
    
    private decimal calcNumOfAttendees(String attendees){
        decimal numOfAttendees = 0;
        if (attendees == null) {
            return 0;
        } 
        String att = attendees.trim().replaceAll('(\\s+)', '');
        String[] attendeeArray = att.split(';');
        for (String str:attendeeArray ) {
            if(str != ''){
                numOfAttendees += 1;
                if (allAttendees != '') {
                    allAttendees += ';' + str;
                } else {
                    allAttendees += str;
                }
            }
        }
        return numOfAttendees;
    }
}
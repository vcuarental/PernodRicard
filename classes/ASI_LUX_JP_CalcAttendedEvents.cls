/*********************************************************************************
 * Name:ASI_LUX_JP_CalcAttendedEvents
 * Description: Calculate Lux JP Attended Events for Total and Past 12 months. Japan LUX specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 16/10/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_LUX_JP_CalcAttendedEvents extends ASI_HK_CRM_TriggerAbstract {
    
    // Final Variable to filter Campaign Recordtypes
    public final static Set<ID> RECORDTYPE_FILTER_CAMPAIGN = new Set<ID>{
                                                                           Global_RecordTypeCache.getRtId('CampaignASI_LUX_JP_Campaign'),
                                                                           Global_RecordTypeCache.getRtId('CampaignASI_BRD_SG_TGL_Campaign'),
                                                                           Global_RecordTypeCache.getRtId('CampaignASI_BRD_SG_GHM_Campaign'),
                                                                           Global_RecordTypeCache.getRtId('CampaignASI_LUX_SG_Campaign')
                                                                      };

    public ASI_LUX_JP_CalcAttendedEvents() {
        super('ASI_LUX_JP_CalcAttendedEvents');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<CampaignMember> validcmpMemberList = new List<CampaignMember>();
        
        if(oldMap == null) {
            for(CampaignMember cmpMember : (List<CampaignMember>)sObjList) {
                if(cmpMember.status.containsIgnoreCase('Attended') && !cmpMember.status.containsIgnoreCase('Not Attended')) {
                        validcmpMemberList.add(cmpMember);
                    }
            }
        } 
        else {
            Map<ID, CampaignMember> cmpMemberOldMap= (Map<ID, CampaignMember>) oldmap;
            
            for(CampaignMember cmpMember : (List<CampaignMember>)sObjList) {
                if(cmpMember.status != cmpMemberOldMap.get(cmpmember.id).status && (cmpMember.status.containsIgnoreCase('Attended') && !cmpMember.status.containsIgnoreCase('Not Attended'))
                       || cmpMember.status != cmpMemberOldMap.get(cmpmember.id).status && (cmpMemberOldMap.get(cmpmember.id).status.containsIgnoreCase('Attended'))) {
                        validcmpMemberList.add(cmpMember);
                    }
            }
            
        }
        
        if (validcmpMemberList.size() > 0) {
            
            Set<ID> ctntIdSet = new Set<ID>();
        
            for (CampaignMember cmpMember : validcmpMemberList) { 
                ctntIDSet.add(cmpMember.contactid);
            }
            
            // Calculate Date interval for the past 12 months Order Amount Calculation
            Date endDate = Date.newInstance(date.today().year(), date.today().month(), 1);
            Date startDate = endDate.addMonths(-12);
            endDate = date.today();
            
            List<Contact> ctntToUpdateList = new List<Contact>();
            
            List<Contact> ctntList = [
                                        SELECT ID, accountID, ASI_LUX_Number_of_attended_events_P12M__c, ASI_LUX_Number_of_attended_events_Total__c,
                                        (
                                            SELECT ID, CampaignID, ContactID, Campaign.StartDate, Campaign.EndDate
                                            FROM CampaignMembers 
                                            WHERE Status LIKE : '%Attended%' 
                                            AND (NOT Status LIKE : '%Not Attended%') 
                                            AND Campaign.StartDate != NULL 
                                            AND Campaign.EndDate != NULL
                                            AND Campaign.recordtypeID IN : RECORDTYPE_FILTER_CAMPAIGN
                                        )
                                        FROM Contact 
                                        WHERE ID IN : ctntIDSet AND (NOT account.recordType.DeveloperName LIKE :'%ASI_BRD_Generic%')
                                     ];
                                     
            for (Contact ctnt : ctntList) {

                List<CampaignMember> cmpMemberList = ctnt.CampaignMembers;
                Decimal sumCampaignAttended = 0;
                Decimal sumCampaignAttendedP12 = 0;
                for(CampaignMember cmpMember : cmpMemberList) {
                   
                        sumCampaignAttended += 1;
                    if (startDate <= cmpMember.Campaign.EndDate && endDate >= cmpMember.Campaign.EndDate) {
                        
                        sumCampaignAttendedP12 += 1;
                    }
                }
                
                if (ctnt.ASI_LUX_Number_of_attended_events_P12M__c != sumCampaignAttendedP12 
                        || ctnt.ASI_LUX_Number_of_attended_events_Total__c != sumCampaignAttended) {
                    Contact ctntUpdate = new Contact(ID = ctnt.id);
                    ctntUpdate.ASI_LUX_Number_of_attended_events_P12M__c = sumCampaignAttendedP12;
                    ctntUpdate.ASI_LUX_Number_of_attended_events_Total__c = sumCampaignAttended;
                    ctntToUpdateList.add(ctntUpdate);
                }

            }
            
            if (ctntToUpdateList.size() > 0) {
                update ctntToUpdateList;
            }
        }
        
    }

}
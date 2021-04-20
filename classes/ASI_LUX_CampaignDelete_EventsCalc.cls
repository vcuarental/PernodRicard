/*********************************************************************************
 * Name:ASI_LUX_CampaignDelete_EventsCalc
 * Description: Calculate Lux JP Attended Events for Total and Past 12 months during deletion
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/03/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_LUX_CampaignDelete_EventsCalc extends ASI_LUX_TriggerAbstract {

    public ASI_LUX_CampaignDelete_EventsCalc() {
        super('ASI_LUX_CampaignDelete_EventsCalc');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        List<Campaign> campaignList = (List<Campaign>)sObjList;
        Set<ID> cmpIdSet = new Set<ID>();
        
        for(Campaign cmp : campaignList) {
            cmpIdSet.add(cmp.id);
        }
        
        List<CampaignMember> validcmpMemberList = (List<CampaignMember>)queryAll(cmpIdSet, 'CampaignMember', 'CampaignID', '');
        
        System.debug('validcmpMemberList ' + validcmpMemberList);
        
        if(validcmpMemberList.size() > 0) {
            Set<ID> ctntIdSet = new Set<ID>();
            Set<ID> cmpMemberIDSet = new Set<ID>();
            
            for (CampaignMember cmpMember : validcmpMemberList) { 
                ctntIDSet.add(cmpMember.contactid);
                cmpMemberIDSet.add(cmpMember.id);
            }
            // Calculate Date interval for the past 12 months Order Amount Calculation
            Date endDate = Date.newInstance(date.today().year(), date.today().month(), 1);
            Date startDate = endDate.addMonths(-12);
            endDate = date.today();
            
            List<Contact> ctntToUpdateList = new List<Contact>();
            
            System.debug('cmpMemberIDSet ' + cmpMemberIDSet);
            
            System.debug('ctntIDSet ' + ctntIDSet);
            
            List<Contact> ctntList = [
                                        SELECT ID, accountID, ASI_LUX_Number_of_attended_events_P12M__c, ASI_LUX_Number_of_attended_events_Total__c,
                                        (
                                            SELECT ID, CampaignID, ContactID, Campaign.StartDate, Campaign.EndDate
                                            FROM CampaignMembers 
                                            WHERE Status LIKE : '%Attended%' 
                                            AND (NOT Status LIKE : '%Not Attended%') 
                                            AND Campaign.StartDate != NULL 
                                            AND Campaign.EndDate != NULL
                                            AND Campaign.recordtypeID IN : ASI_LUX_JP_CalcAttendedEvents.RECORDTYPE_FILTER_CAMPAIGN
                                            AND ID NOT IN : cmpMemberIDSet
                                        )
                                        FROM Contact 
                                        WHERE ID IN : ctntIDSet
                                     ];
            
            System.debug('ctntList ' + ctntList);
            
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
    
    private List<sObject> queryAll(Set<ID> filterIDSet, String sObjectName, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' From '+sObjectName+' where '+filteringField+' IN : filterIDSet ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }

}
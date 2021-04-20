/*********************************************************************************
 * Name:ASI_LUX_CalculateSegmentationTrigger
 * Description: Calculate Lux Segmentation for record input in CampaignMember
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/10/2014       Laputa: Conrad          Created
 * 07/11/2014       Laputa: Conrad          Add MY Campaign record type
 * 09/02/2015       Laputa: Conrad          Add SG Campaign record type
*********************************************************************************/

public with sharing class ASI_LUX_CalculateSegmentationTrigger extends ASI_HK_CRM_TriggerAbstract {
    
    // Final Variable to filter Campaign Recordtypes
    private final Set<ID> RECORDTYPE_FILTER_CAMPAIGN = new Set<ID>{
                                                                       Global_RecordTypeCache.getRtId('CampaignASI_LUX_HK_Campaign'), 
                                                                       Global_RecordTypeCache.getRtId('CampaignASI_LUX_Regional_Campaign'), 
                                                                       Global_RecordTypeCache.getRtId('CampaignASI_LUX_TW_Campaign'),
                                                                       Global_RecordTypeCache.getRtId('CampaignASI_LUX_MY_Campaign'),
                                                                       Global_RecordTypeCache.getRtId('CampaignASI_LUX_SG_Campaign'),
                                                                       Global_RecordTypeCache.getRtId('CampaignASI_BRD_SG_TGL_Campaign'),
                                                                       Global_RecordTypeCache.getRtId('CampaignASI_BRD_SG_GHM_Campaign')
                                                                  };

    public ASI_LUX_CalculateSegmentationTrigger() {
        super('ASI_LUX_CalculateSegmentationTrigger');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<CampaignMember> validcmpMemberList = new List<CampaignMember>();
        
        if(oldMap == null) {
            for(CampaignMember cmpMember : (List<CampaignMember>)sObjList) {
                // Only filter out the sales order where the Amount or Order Date has been updated: only applies for after update
                if(cmpMember.status.containsIgnoreCase('Attended') && !cmpMember.status.containsIgnoreCase('not attended')) {
                        validcmpMemberList.add(cmpMember);
                    }
            }
        } 
        else {
            // If Update trigger, filter out the ones that are valid AKA the ones where the update affects the score
            Map<ID, CampaignMember> cmpMemberOldMap= (Map<ID, CampaignMember>) oldmap;
            
            for(CampaignMember cmpMember : (List<CampaignMember>)sObjList) {
                // Only filter out the sales order where the Amount or Order Date has been updated: only applies for after update
                if(cmpMember.status != cmpMemberOldMap.get(cmpmember.id).status && (cmpMember.status.containsIgnoreCase('Attended') && !cmpMember.status.containsIgnoreCase('not attended'))
                       || cmpMember.status != cmpMemberOldMap.get(cmpmember.id).status && (cmpMemberOldMap.get(cmpmember.id).status.containsIgnoreCase('Attended') && !cmpMemberOldMap.get(cmpmember.id).status.containsIgnoreCase('not attended'))) {
                        validcmpMemberList.add(cmpMember);
                    }
            }
            
        }
        
        if (validcmpMemberList.size() > 0) {
        
            Set<ID> ctntIdSet = new Set<ID>();
            
            //************************************************* OLD CODE: determine the current start of the fiscal year date
            List<ASI_HK_CRM_Running_Number__c> runningNumberList = [select ASI_HK_CRM_First_Month_of_Fiscal_Year__c from ASI_HK_CRM_Running_Number__c where ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c'];
            ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c();
            if (!runningNumberList.isEmpty())
                runningNumber = runningNumberList.get(0);
            
            for (CampaignMember cmpMember : validcmpMemberList) { 
                if (runningNumberList.isEmpty()) {
                    cmpMember.adderror('Score calculation failed because the record ASI_HK_CRM_Sales_Order__c for the Object ASI_HK_CRM_Running_Number__c is missing. Please contact the System Administrator to verify that this Running Number record is deployed');
                }
                ctntIDSet.add(cmpMember.contactid);
            }
            
            Integer month = (Integer) runningNumber.ASI_HK_CRM_First_Month_of_Fiscal_Year__c;
            Integer year = Datetime.now().year();

            Decimal totalScore = 0;
            Decimal conversionFactor = 1;
            Datetime endFiscal = Datetime.newInstance(year, month,1);
            Datetime startFiscal = Datetime.newInstance(year, month,1);
            endFiscal = endFiscal.addDays(1);
            Date startFiscalDate = startFiscal.Date();
            Date endFiscalDate = endFiscal.Date();

            // if the startfiscaldate is in the future, change the year to the last year 
            if (startFiscalDate > date.today())
                startFiscalDate = startFiscalDate.addyears(-1);
            //************************************************* OLD CODE: END
            
            List<Account> accToUpdateList = new List<Account>();
            
            List<Contact> ctntList = [
                                        SELECT ID, accountID, account.ASI_LUX_Segment_Involvement_YTD__c,
                                        (
                                            SELECT ID, CampaignID, ContactID, Campaign.StartDate, Campaign.EndDate
                                            FROM CampaignMembers 
                                            WHERE Status LIKE : '%Attended%' 
                                            AND (NOT Status LIKE : '%not Attended%') 
                                            AND Campaign.StartDate != NULL 
                                            AND Campaign.EndDate >=: startFiscalDate
                                            AND Campaign.recordtypeID IN : RECORDTYPE_FILTER_CAMPAIGN
                                        )
                                        FROM Contact 
                                        WHERE ID IN : ctntIDSet
                                     ];
            
            for (Contact ctnt : ctntList) {

                List<CampaignMember> cmpMemberList = ctnt.CampaignMembers;
                Decimal sumCampaignAttended = 0;
                
                for(CampaignMember cmpMember : cmpMemberList) {
                        sumCampaignAttended += 1;
                }
                
                Account acc = new Account (ID = ctnt.accountid);

                if (sumCampaignAttended < 5)
                {
                    acc.ASI_LUX_Segment_Involvement_YTD__c = 'Low < 5 Physically attended events';
                }
                else
                {
                    acc.ASI_LUX_Segment_Involvement_YTD__c = 'High ≥ 5 Physically attended events';
                }
                
                if (acc.ASI_LUX_Segment_Involvement_YTD__c != ctnt.account.ASI_LUX_Segment_Involvement_YTD__c) {
                    accToUpdateList.add(acc);
                }
            }
            
            if (accToUpdateList.size() > 0) {
                
                update accToUpdateList;
            }
        }
        
    }

}
/*********************************************************************************
 * Name:ASI_BRD_LeadConversion
 * Description: Lead conversion for Lead 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/09/2015       Laputa: Hank          Created
*********************************************************************************/

public without sharing class ASI_BRD_Generic_LeadConversion extends ASI_BRD_Generic_TriggerAbstract {

    public ASI_BRD_Generic_LeadConversion() {
        super('ASI_BRD_Generic_LeadConversion');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<Lead> leadList = (List<Lead>)sObjList;
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        if (oldMap == null) {
              
        }
        else {
            Map<ID, Lead> oldLeadMap = (Map<ID, Lead>) oldMap;
            for(Lead l: leadList){
                if(l.ASI_BRD_Sys_Lead_Auto_Convert__c != null && (l.ASI_BRD_Sys_Lead_Auto_Convert__c != oldLeadMap.get(l.Id).ASI_BRD_Sys_Lead_Auto_Convert__c)) {
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(l.Id);
                    lc.setConvertedStatus('Qualified - Convert');
                    lc.setDoNotCreateOpportunity(true);
                    leadConverts.add(lc);
                }
            }
        }
        if(!leadConverts.isEmpty()){
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
        }
    }
}
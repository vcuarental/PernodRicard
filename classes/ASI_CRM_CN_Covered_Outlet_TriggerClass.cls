public with sharing class ASI_CRM_CN_Covered_Outlet_TriggerClass {
    public ASI_CRM_CN_Covered_Outlet_TriggerClass (){}
    
    public static void routineBeforeUpdate(list<ASI_CRM_CN_Covered_Outlet__c> trigger_new, map<id, ASI_CRM_CN_Covered_Outlet__c> trigger_oldMap) {
        /*//cn contract map 
        // Map<ID,ASI_TH_CRM_Contract__c> Contract_list = new Map<id,ASI_TH_CRM_Contract__c>([Select id,Recordtypeid from ASI_TH_CRM_Contract__c Where Recordtypeid=:Global_RecordTypeCache.getRtId('ASI_CRM_CN_Contract') ]);
        List<ASI_CRM_CN_Covered_Outlet__c> Covered_outlet_list = [Select ASI_CRM_CN_Contract__c,ASI_CRM_CN_Outlet__c from ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c!=null and ASI_CRM_CN_Outlet__c!=null];
        for(ASI_CRM_CN_Covered_Outlet__c a: trigger_new){
            for(ASI_CRM_CN_Covered_Outlet__c b: Covered_outlet_list){
                if(a.ASI_CRM_CN_Contract__c==b.ASI_CRM_CN_Contract__c&&a.ASI_CRM_CN_Outlet__c==b.ASI_CRM_CN_Outlet__c)
                {
                    a.addError('Duplication of Covered Outlet Exist!');
                }
            }
        }*/
        
    }
    
    
    //----- added by leo @2014/06/22 (start) -----
    public static void routineBeforeUpsert(list<ASI_CRM_CN_Covered_Outlet__c> trigger_new, map<id, ASI_CRM_CN_Covered_Outlet__c> trigger_oldMap) {
        //******* check duplicate covered outlet (start) *******
        Set<ID> contractIdSet = new Set<ID>();
        
        for(ASI_CRM_CN_Covered_Outlet__c co: trigger_new) {
            if(co.ASI_CRM_CN_Contract__c != null && co.ASI_CRM_CN_Outlet__c != null)
            {
                if(!contractIdSet.contains(co.ASI_CRM_CN_Contract__c))
                    contractIdSet.add(co.ASI_CRM_CN_Contract__c);
            }
        }
        
        List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletList = 
            [SELECT ASI_CRM_CN_Contract__c, ASI_CRM_CN_Outlet__c, id FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c =: contractIdSet];
        
        for(ASI_CRM_CN_Covered_Outlet__c co: trigger_new) {
            System.Debug('Check Record ID: ' + co.id);
            
            if(co.ASI_CRM_CN_Contract__c != null && co.ASI_CRM_CN_Outlet__c != null)
            {
                for(ASI_CRM_CN_Covered_Outlet__c tempCoveredOutlet : coveredOutletList) {                
                    if(tempCoveredOutlet.ASI_CRM_CN_Contract__c == co.ASI_CRM_CN_Contract__c && tempCoveredOutlet.ASI_CRM_CN_Outlet__c == co.ASI_CRM_CN_Outlet__c)
                    {
                        if(co.Id == null || (co.Id != null && co.Id != tempCoveredOutlet.Id))
                            co.addError(Label.ASI_CRM_CN_Duplicate_Covered_Outlet);
                    }
                }
                
                //---- create more than 1 new same rows immediately ---
                //if(co.Id == null)
                //{
                integer count = 0;
                for(ASI_CRM_CN_Covered_Outlet__c coUpdated: trigger_new) {
                    if(coUpdated.ASI_CRM_CN_Contract__c == co.ASI_CRM_CN_Contract__c && coUpdated.ASI_CRM_CN_Outlet__c == co.ASI_CRM_CN_Outlet__c)
                    {
                        count += 1;
                    }
                }
                
                if(count > 1) co.addError(Label.ASI_CRM_CN_Duplicate_Covered_Outlet);
                //}
            }
        }    
        //******* check duplicate covered outlet (end) *******
    }
    //----- added by leo @2014/06/22 (end) -----
}
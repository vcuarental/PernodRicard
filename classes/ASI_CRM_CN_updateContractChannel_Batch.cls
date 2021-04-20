global class ASI_CRM_CN_updateContractChannel_Batch implements Database.Batchable<sObject> ,Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT ParentId
                                         FROM ASI_CRM_AccountsAdditionalField__History 
                                         WHERE (field = 'ASI_CRM_CN_NewChannel__c' 
                                                OR field='ASI_CRM_CN_CCity__c') 
                                         AND CreatedDate >= LAST_N_DAYS:1
                                         ORDER BY createdDate DESC]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Set<Id> parentSet = new Set<Id>();
        List<ASI_CRM_AccountsAdditionalField__History> acHistory = (List<ASI_CRM_AccountsAdditionalField__History>)scope;
        
        for(ASI_CRM_AccountsAdditionalField__History acH: acHistory)
        {
            parentSet.add(acH.ParentId);
        }
        List<ASI_CRM_AccountsAdditionalField__c> acList 
            = new List<ASI_CRM_AccountsAdditionalField__c>([SELECT id, Name
                                                            , ASI_CRM_CN_NewChannel__c
                                                            , ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c
                                                            , ASI_CRM_CN_CCity__c
                                                            FROM ASI_CRM_AccountsAdditionalField__c 
                                                            WHERE Id IN: parentSet
                                                            AND (recordType.developerName= 'ASI_CRM_Outlet_CN')
                                                                 //OR recordType.developerName= 'ASI_CRM_CN_WS')//20160726 Ben @ Elufa
                                                            AND (ASI_CRM_CN_NewChannel__r.Name != 'All Customer')
                                                           ]);
        Map<Id,ASI_CRM_AccountsAdditionalField__c> acMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_TH_CRM_Contract__c> updateList = new List<ASI_TH_CRM_Contract__c>();
        
        if(acList.size() > 0)
        {
            for(ASI_CRM_AccountsAdditionalField__c ac: acList)
            {
                acMap.put(ac.Id, ac);
            }
            
            List<ASI_TH_CRM_Contract__c> contractList 
                = new List<ASI_TH_CRM_Contract__c>([SELECT id, Name
                                                    ,ASI_CRM_CN_Outlet_WS__c
                                                    ,ASI_CRM_PO_Channel__c
                                                    ,ASI_CRM_PO_Province__c
                                                    FROM ASI_TH_CRM_Contract__c
                                                    WHERE ASI_CRM_CN_Outlet_WS__c IN: acMap.keySet()
                                                    AND ASI_CRM_New_FY_PO__c = TRUE
                                                    AND (NOT ASI_CRM_CN_Status__c LIKE 'FY landing Archive')//20170210 Elufa
                                                   ]);
            
            for(ASI_TH_CRM_Contract__c contract: contractList)
            {
                if(acMap.containsKey(contract.ASI_CRM_CN_Outlet_WS__c))
                {
                    Boolean hasUpdate = false;
                    if(acMap.get(contract.ASI_CRM_CN_Outlet_WS__c).ASI_CRM_CN_NewChannel__c != NULL)
                    {
                        contract.ASI_CRM_PO_Channel__c = acMap.get(contract.ASI_CRM_CN_Outlet_WS__c).ASI_CRM_CN_NewChannel__c;
                        hasUpdate = true;
                    }
                    if(acMap.get(contract.ASI_CRM_CN_Outlet_WS__c).ASI_CRM_CN_CCity__c != NULL && acMap.get(contract.ASI_CRM_CN_Outlet_WS__c).ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c != NULL)
                    {
                        contract.ASI_CRM_PO_Province__c = acMap.get(contract.ASI_CRM_CN_Outlet_WS__c).ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
                        hasUpdate = true;
                    }
                    if(hasUpdate = true)
                        updateList.add(contract);
                }
            }
            
            if(updateList.size() > 0)
                Database.update(updateList, false);
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {}
}
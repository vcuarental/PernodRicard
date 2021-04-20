/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | ESN_AutojoinByAffiliates_Config__c                                                 |
|     - Description     | Configuration page for the Custom setting named ESN_AutojoinByAffiliates_Config__c |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 07/05/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public without sharing class ESN_VFC19_AutojoinByAffiliateConfig {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public List<ESN_AutojoinByAffiliates_Config__c> allAutojoinByAffiliateConfigs_list {get;set;}
    public Map<String,ESN_AutojoinByAffiliates_Config__c> name2autojoinConfig_map {get;set;}
    public Set<Id> allGroupsID_list {get;set;}
    public Map<Id,String> id2Group_map {get;set;}
    public String msg {get;set;}
    public String newAffiliate {get;set;}
    public String newChatterGroup {get;set;}
    public String alreadyExistMsg {get;set;}
    public String emailAdmin {get;set;}
    public String configNameSelected {get;set;}
    public Boolean batchOnGoing {get;set;}
            
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public ESN_VFC19_AutojoinByAffiliateConfig() {
        /* Get the admin Email */
        String emailAdmin = Utils_UsefulMethods.adminEmailOfPRCustomSetting();

        allGroupsID_list = new Set<Id>();
        msg = '';

        // Get all configurations for Autojoin By Affiliate //
        name2autojoinConfig_map = ESN_AutojoinByAffiliates_Config__c.getAll();
        allAutojoinByAffiliateConfigs_list = name2autojoinConfig_map.values();
        allAutojoinByAffiliateConfigs_list.sort();
        
        for(ESN_AutojoinByAffiliates_Config__c conf : allAutojoinByAffiliateConfigs_list){
            if(!allGroupsID_list.contains(conf.Chatter_Group_ID__c))
                allGroupsID_list.add(conf.Chatter_Group_ID__c);
        }

        List<CollaborationGroup> groups_list = [SELECT Id, Name FROM CollaborationGroup];
        id2Group_map = new Map<Id,String>();
        for(CollaborationGroup grp : groups_list){
            id2Group_map.put(grp.Id, grp.Name);
        }
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/  
    
    /*
     * Button : Save the new configuration, if not already existed. 
     ***/ 
    public Pagereference saveNewConf(){
        ESN_AutojoinByAffiliates_Config__c newConf = new ESN_AutojoinByAffiliates_Config__c();
        newConf.Chatter_Group_ID__c = newChatterGroup;
        newConf.Affiliate__c = newAffiliate;
        newConf.Name = newAffiliate + ' to ' + id2Group_map.get(newChatterGroup).deleteWhitespace();
        if(newConf.Name.length() >= 35)
            newConf.Name = newConf.Name.substring(0, 35);
        
        Boolean confAlreadyExist = false;
        for(ESN_AutojoinByAffiliates_Config__c conf : allAutojoinByAffiliateConfigs_list){
            if(conf.Chatter_Group_ID__c == newConf.Chatter_Group_ID__c && conf.Affiliate__c == newConf.Affiliate__c)
                confAlreadyExist = true;
        }
        
        if(!confAlreadyExist) {
            alreadyExistMsg = '';
            try{
                insert newConf;
                newAffiliate = '';
                newChatterGroup = '';
            }catch (Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,e.getMessage());
                ApexPages.addMessage(myMsg);
            }
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'This couple already exists.');
            ApexPages.addMessage(myMsg);
        }
        allAutojoinByAffiliateConfigs_list.add(newConf);
        allAutojoinByAffiliateConfigs_list.sort();
        name2autojoinConfig_map = ESN_AutojoinByAffiliates_Config__c.getAll();
        return null;
    }
    
    /*
     * Link "Delete": Delete the selected batch once time . 
     ***/ 
    public Pagereference deleteSelectedConf(){
        ESN_AutojoinByAffiliates_Config__c selectedConf = name2autojoinConfig_map.get(configNameSelected);

        try{
            delete selectedConf;
        }catch (Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        allAutojoinByAffiliateConfigs_list = ESN_AutojoinByAffiliates_Config__c.getAll().values();
        allAutojoinByAffiliateConfigs_list.sort();
        return null;
    }
    
    /*
     * Link "Run this batch once": Run the selected batch once time . 
     ***/ 
    public Pagereference runOnce(){
        ESN_AutojoinByAffiliates_Config__c selectedConf = name2autojoinConfig_map.get(configNameSelected);
        
        /* Create a Map with key : Group ID and Value : a list of its future users */
        Map<Id,Set<Id>> group2listUsers_map = new Map<Id,Set<Id>>();
        batchOnGoing = true;
    
        try{
            // Check if the limit of 5 batches running at the same time is reached //
            Integer MAX_BATCHES = 5;
            Integer runningBatchJobs = [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND status in ('Queued','Processing','Preparing')];
            
            if(runningBatchJobs >= MAX_BATCHES) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No resources available.  Please try again later.'));
                return null;
            } else {
                APB03_Autojoin_By_Affiliate batch = new APB03_Autojoin_By_Affiliate();
                
                if(selectedConf.Affiliate__c != 'All')
                    batch.soql = 'SELECT Id FROM User WHERE isActive = true AND CompanyName = \''+selectedConf.Affiliate__c+'\' AND ProfileId != \''+EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c+'\'';
                else
                    batch.soql = 'SELECT Id FROM User WHERE isActive = true AND ProfileId != \''+EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c+'\'';
                
                batch.ChatterGroupId = selectedConf.Chatter_Group_ID__c;
                
                if(!(Test.isRunningTest() && batchOnGoing)) // If is Test and batchOnGoing = true, don't run the batch because it ran already once. 
                    ID batch_processId = Database.executeBatch(batch, 200); //execute the batch
            }
        }catch (Exception e){
            batchOnGoing = false;
            if(e.getTypeName()!='DUPLICATE_VALUE')
                Utils_UsefulMethods.notifyAdminException(emailAdmin, 'ESN_VFC19_AutojoinByAffiliateConfig', 'Exception during run the batch for affiliate ['+ selectedConf.Affiliate__c +'] and group ['+ selectedConf.Chatter_Group_ID__c +'].',e);
        }
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'The batch is currently in progress. Check this page to see the result : <br/> <a target="_blank" href="/apexpages/setup/listAsyncApexJobs.apexp">Apex Jobs (new window)</a> ');
        ApexPages.addMessage(myMsg);
        return null;
    }

}
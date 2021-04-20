public with sharing class EUR_CRM_MassDistrObjectiveCtrller {
    
    private static final Integer PAGE_SIZE = 100;
    public Apexpages.StandardSetController standardSetCon { get; set; }
    public String NumOfRecords {
        get{
            return (standardSetCon == null ? '0' : (standardSetCon.getResultSize() > 2000 ? '2000+' :  String.valueof(standardSetCon.getResultSize())) );
        } private set;
    }
    
    public EUR_CRM_GB_Objective__c MyObjective { get; set; }
    
    public EUR_CRM_MassDistrObjectiveCtrller(Apexpages.StandardSetController stdSetCon){
        standardSetCon = stdSetCon;
        standardSetCon.setPageSize(PAGE_SIZE);
        Id objId = Apexpages.currentPage().getParameters().get('objId');
        MyObjective = [Select Id, Name, EUR_CRM_Is_Published__c, EUR_CRM_End_Date__c,RecordTypeId, EUR_CRM_Start_Date__c,RecordType.id, RecordType.Developername From EUR_CRM_GB_Objective__c Where Id =: objId];
    }
    private Set<String> atRecordTypes = new Set<String>{'EUR_AT_Central_Objective'};
        
        private Map<String,String> rtMapping = EUR_CRM_RecordTypeHelper.MassDistrObjectiveCtrller_rtMapping;
    private Map<String,String> objectiveToVisitActionRtMapping = EUR_CRM_RecordTypeHelper.MassDistrObjectiveCtrller_objectiveToVisitActionRtMapping;
    
    public Boolean getIsPublishDisabled() {
        // Publish button always enabled, 'EUR_BG_Central_Promotion' removed
        if(MyObjective.RecordType.Developername == 'EUR_PT_Off_Trade_Central_Promotion' || MyObjective.RecordType.Developername == 'EUR_PT_On_Trade_Central_Promotion') {
            return false;
        }
        
        if(MyObjective.EUR_CRM_Is_Published__c == true) {
            // Disables publish button when the objective is already published
            return true;
        }
        
        return false;
    }
    
    public Boolean getIsMassCreateVisitAction() {
        if(MyObjective.RecordType.Developername == 'EUR_BG_Central_Promotion' || MyObjective.RecordType.Developername == 'EUR_PT_Off_Trade_Central_Promotion' || MyObjective.RecordType.Developername == 'EUR_PT_On_Trade_Central_Promotion') {
            return true;
        }
        
        return false;
    }
    
    public Boolean getIsMassCreateObjective() {
        return !getIsMassCreateVisitAction();
    }
    
    public PageReference massCreateVisitAction() {
        PageReference ref;
        System.Savepoint sp = Database.setSavepoint();
        
        try{
            String visitActionRecordTypeDevName = objectiveToVisitActionRtMapping.get(MyObjective.recordType.Developername);
            Id visitActionRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Visit_Action__c' + visitActionRecordTypeDevName);
            System.debug('Debug ' + visitActionRecordTypeId);
            System.debug('Debug ' + visitActionRecordTypeDevName);
            EUR_CRM_ListViewFilter filter = new EUR_CRM_ListViewFilter(standardSetCon);
            List<EUR_CRM_Account__c> filteredAcctList = Test.isRunningTest() ? EUR_CRM_FilteredMassChatterCtrllerTest.acctlist : filter.getEURAccountListByFilter();
            System.debug('filtered list: ' + filteredAcctList);
            List<EUR_CRM_Visit_Action__c> visitActions = new List<EUR_CRM_Visit_Action__c>();
            
            for(EUR_CRM_Account__c a: filteredAcctList) {
                EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c(
                    EUR_CRM_Start_Date__c = MyObjective.EUR_CRM_Start_Date__c,
                    EUR_CRM_Objective__c  = MyObjective.Id,
                    recordTypeId          = visitActionRecordTypeId,
                    EUR_CRM_Account__c    = a.Id,
                    EUR_CRM_Active__c     = false
                );
                
                visitActions.add(visitAction);
            }
            
            if(visitActions.size() > 0) {
                insert visitActions;
            }
            
            MyObjective.EUR_CRM_Is_Published__c = true;
            update MyObjective;
            
            ref = new PageReference('/' + MyObjective.Id);
            ref.setRedirect(true);
        } catch(Exception ex){
            if(ex.getTypeName() == 'DMLException'){
                Database.rollback(sp);
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, ex.getDMLMessage(0)));
            }
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
        
        return ref;
    }
    
    public PageReference massCreateObjective(){
        PageReference ref;
        System.Savepoint sp = Database.setSavepoint();
        
        try{    
            Map<Id,RecordType> objectiveRecordTypeMap = new Map<Id,RecordType>([select id,developername from recordtype where sobjecttype = 'EUR_CRM_GB_Objective__c']);
            Map<String, Id> objectiveActionRecordTypeMap = new Map<String,id>();
            for(RecordType rt : [select id,developername from recordtype where  sobjecttype = 'EUR_CRM_GB_Action__c']){
                objectiveActionRecordTypeMap.put(rt.developername, rt.id);
            }
            RecordType atActionRecordType = [select id from recordtype where developername = 'EUR_AT_Central_Objective' and sobjecttype = 'EUR_CRM_GB_Action__c'];
            
            EUR_CRM_ListViewFilter filter = new EUR_CRM_ListViewFilter(standardSetCon);
            List<EUR_CRM_Account__c> filteredAcctList = Test.isRunningTest() ? EUR_CRM_FilteredMassChatterCtrllerTest.acctlist : filter.getEURAccountListByFilter();
            System.debug('filtered list: ' + filteredAcctList);
            List<EUR_CRM_GB_Action__c> actionlist = new List<EUR_CRM_GB_Action__c>();
            System.debug('@rtMapping:'+rtMapping);
            system.debug('@objectiveRecordTypeMap:'+objectiveRecordTypeMap);
            
            for(EUR_CRM_Account__c a : filteredAcctList){
                
                EUR_CRM_GB_Action__c action = new EUR_CRM_GB_Action__c(EUR_CRM_Account__c = a.Id, EUR_CRM_GB_Objective__c = MyObjective.Id);
                system.debug('@MyObjective.recordTypeId:'+MyObjective.recordTypeId);
                String objecRecordType = objectiveRecordTypeMap.get(MyObjective.recordTypeId).developername;
                
                String objActionRecordTypeName = rtMapping.get(objecRecordType);
                action.RecordTypeId = objectiveActionRecordTypeMap.get(objActionRecordTypeName);
                system.debug('objecRecordType  '  +objecRecordType);
                system.debug('objActionRecordTypeName '  +objActionRecordTypeName );
                system.debug('action.RecordTypeId'  +action.RecordTypeId);
                actionlist.add(action);
            }
            if(actionlist.size()>0){
                system.debug('The size of ACtion: '+actionlist.size());
                //insert actionlist;
                if(actionlist.size() < 1000) {
                    //System.debug(actionlist.size());
                    insert actionlist;
                    
                } else {
                    Integer MAX_BATCHES = 10;
                    Integer runningBatchJobs = [select count() from AsyncApexJob where JobType = 'BatchApex'
                                                and status in ('Queued','Processing','Preparing')];
                    
                    if(runningBatchJobs >= MAX_BATCHES) {
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.WARNING, Label.EUR_CRM_No_Resources_Available
                        ));
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.INFO, 'ACtion Update error'
                        ));
                        //create the postDMLS
                        Database.executeBatch(new EUR_CRM_BatchDML_Utility(actionlist, 'EUR_CRM_GB_Action__c', EUR_CRM_BatchDML_Utility.Operation.INSERT_RECORDS,true, null));
                    }
                }
            }
            
            MyObjective.EUR_CRM_Is_Published__c = true;
            update MyObjective;
            ref = new PageReference('/'+MyObjective.Id);
            ref.setRedirect(true);
        }catch(Exception ex){
            if(ex.getTypeName() == 'DMLException'){
                Database.rollback(sp);
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, ex.getDMLMessage(0)));
            }
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
        return ref;
    }
    
}
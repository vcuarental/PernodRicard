public without sharing class ASI_ApprovalListAdminCtrl
{
    public integer counter=0; //keeps track of the offset
    public integer list_size=50;//sets the page size or number of rows
    public integer total_size{get;set;}//used to show user the total size of the list
    public integer start_index{set;get;}//start index of page
    public integer end_index{set;get;}//end index of page
    public list<ApprovalRecord> LApproval {set;get;}
    public string statusSelected {set;get;}
    public String selectedRegion{set;get;}
    public String selectedSubmitter{set;get;}//submitter picklist
    public String selectedApprover{set;get;}//approver picklist    
    public String docNum {set;get;}        // [SH] 2019-01-08
    public Date SubmitDate {set;get;}      // [SH] 2019-01-08
    public Datetime submitD {set;get;}     // [SH] 2019-01-08
    public Datetime submitD_1 {set;get;}   // [SH] 2019-01-08
    public String selectedType {set;get;}  // [SH] 2019-01-08
    public Boolean pageChange = false;     // [SH] 2019-04-09
    public List<ProcessInstanceWorkitem> allApproverID = new List<ProcessInstanceWorkitem>();
    public User curUser = [SELECT CompanyName FROM USER WHERE id =: userInfo.getUserID()];
    public set<ID> ApproverID = new set<ID>();
  //Public List<User> allSubmitter = new List<User>([SELECT id, Name FROM User WHERE CompanyName like: curUser.CompanyName AND CompanyName != 'Pernod Ricard China' AND IsActive = TRUE ORDER BY Name]);
    Public List<User> allSubmitter = Test.isRunningTest() ? new List<User>([SELECT id, Name FROM User WHERE CompanyName like: curUser.CompanyName AND CompanyName != 'Pernod Ricard China' AND IsActive = TRUE ORDER BY Name]):
                                                            new List<User>([SELECT id, Name FROM User WHERE CompanyName ='Pernod Ricard Taiwan' AND IsActive = TRUE ORDER BY Name]); 
    
    public ASI_ApprovalListAdminCtrl()
    {
        init();
    }//end constructor
    
    public List<SelectOption> getSubmitterList()
    {   
        Set<String> submitterSetID = new Set<String>();
        List<SelectOption> submitterList = new List<SelectOption>();
        submitterList.add(new SelectOption('All', 'All'));
        submitterSetID = allsubmiterSet();
        
        if(submitterSetID.size() > 0){

            for(User obj : allSubmitter)
            {
                if(submitterSetID.contains(obj.id))
                    submitterList.add(new SelectOption(obj.id, obj.Name));
            }//end for
        }
        
        return submitterList;
    }//endmethod: getSubmitterList
    
    public List<SelectOption> getApproverList()
    {
        List<SelectOption> approverList = new List<SelectOption>();
        List<User> allapprover = new List<User>([SELECT id, Name FROM User WHERE id IN: ApproverID ORDER BY Name]);
        
        approverList.add(new SelectOption('All','All'));
        
        for(User obj : allapprover)
        {
            approverList.add(new SelectOption(obj.id, obj.Name));
        }//end for
        
        return approverList;
    }//end method: getApproverList
    
	// [SH] 2019-01-08
    public List<SelectOption> getTypeList()
    {   
        Set<String> typeSet = new Set<String>();
        List<SelectOption> TypeList = new List<SelectOption>();
        TypeList.add(new SelectOption('All', 'All'));
        typeSet = alltypeSet();
        
        if(typeSet.size() > 0){

            for(String s : typeSet)
            {                
                typeList.add(new SelectOption(s, s));
            }//end for
        }
        
        return typeList;
    }//endmethod: gettypeList
    
    public void init()
    {
        selectedApprover = 'All';
        selectedSubmitter = 'All';
        statusSelected = 'Pending';
        docNum = null;                        // [SH] 2019-01-08
        SubmitDate = system.today();          // [SH] 2019-01-08
        selectedType = Test.isRunningTest() ? 'All' : 'Plan';                // [SH] 2019-01-08
        counter = 0;
        end_index = list_size;
        start_index = 1;
        pageChange = false;        			  // [SH] 2019-04-09   
        queryRec();
    }//end method: init
    
    //user clicked beginning
    public PageReference Beginning()
    {
        counter = 0;        
        queryRec();
        return null;
    }//end method: Beginning
    
    //user clicked previous button
    public PageReference Previous()
    {
        counter -= list_size;
        pageChange = counter == 0? false: true; // [SH] 2019-04-09
        queryRec();
        return null;
    }//end method: Previous
    
    //user clicked next button
    public PageReference Next()
    {
        counter += list_size;
        pageChange = true;                      // [SH] 2019-04-09
        queryRec();
        return null;
    }//endmethod: Next
    
    //user clicked end
    public PageReference End()
    {
        counter = total_size - math.mod(total_size, list_size);
        pageChange = true;                     // [SH] 2019-04-09
        queryRec();
        return null;
    }//end method: End
    
    //this will disable the previous and beginning buttons
    public Boolean getDisablePrevious()
    { 
        if (counter>0) return false; else return true;
    }//end method: getDisablePrevious
    
    //this will disable the next and end buttons
    public Boolean getDisableNext()
    {
        if (counter + list_size < total_size) return false; else return true;
    }//end method: getDisableNext
    
    public Integer getTotal_size()
    {
        return total_size;
    }//end method: getTotal_size
    
    public Integer getPageNumber()
    {
        return counter/list_size + 1;
    }//end method: getPageNumber
    
    public Integer getTotalPages()
    {
        if (math.mod(total_size, list_size) > 0)
        {
            return total_size/list_size + 1;
        }//end if
        else
        {
            return (total_size/list_size);
        }//end else
    }//end method: getTotalPages
    
    public void changeStatus()
    {
        counter = 0;
        start_index = 0;
        end_index = 0;
        selectedApprover = 'All'; 
        approverID.clear();
        pageChange = false;      // [SH] 2019-04-09
        queryRec();
    }//end method: changeStatus
    
    public void changeStatus2()
    {
        counter = 0;
        start_index = 0;
        end_index = 0;
        approverID.clear();
        pageChange = false;      // [SH] 2019-04-09
        queryRec();
    }//end method: changeStatus2    
    
    // [SH] 2019-01-08
    public String filter(String docNum, Date SubmitDate, String selectedSubmitter, String selectedApprover, String selectedType){
        String whereStatm = '';
        
        if(docNum != null && docNum != ''){
            whereStatm += ' and processinstance.targetobject.name like \'%' + docNum + '%\' ';
        }
        if(SubmitDate != null){
            submitD = Datetime.newInstance(SubmitDate.year(), SubmitDate.month(), SubmitDate.day());
            submitD_1 = Datetime.newInstance(SubmitDate.year(), SubmitDate.month(), SubmitDate.addDays(1).day());
            whereStatm += ' and (processinstance.CreatedDate >= :submitD and processinstance.CreatedDate < :submitD_1)';
        }
        if(selectedSubmitter != 'All'){
            whereStatm += ' and processinstance.createdBy.id = :selectedSubmitter ';
        }else{
            whereStatm += ' and processinstance.createdBy.id IN :allSubmitter ';
        }
        if(selectedApprover != 'All'){
            whereStatm += ' and ActorId = :selectedApprover ';
        }
        if(selectedType != null){
            String TypeName;            
            for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ){
                Schema.DescribeSObjectResult objResult = o.getDescribe();                
                if(selectedType == objResult.getLabel()){
                    TypeName = objResult.getName();
                }
                //system.debug( 'Sobject API Name: ' + objResult.getName() );
                //system.debug( 'Sobject Label Name: ' + objResult.getLabel() );   
            }
            if(TypeName != null)
                whereStatm += ' and processinstance.targetobject.type = \'' + TypeName + '\''; 
        }
        
        return whereStatm;
    }
    // END - [SH]
    
    public void queryRec()
    {
        //List<User> allSubmitter = new List<User>();
        
        system.debug('check111 ' + allSubmitter); system.debug('Linus Test: ' + SubmitDate);
        
        List<ProcessInstanceWorkitem> ttlSizeList = new list<ProcessInstanceWorkitem>();
        
        LApproval = new list<ApprovalRecord>();
        List<ProcessInstanceWorkitem> LProcIns = new list<ProcessInstanceWorkitem>();
        
        // [SH] 2019-01-08
        if(StatusSelected == 'Pending'){
            //allSubmitter = [SELECT id, Name FROM User WHERE CompanyName like: curUser.CompanyName AND CompanyName != 'Pernod Ricard China' AND IsActive = TRUE ORDER BY Name];
            allSubmitter = Test.isRunningTest() ? new List<User>([SELECT id, Name FROM User WHERE CompanyName like: curUser.CompanyName AND CompanyName != 'Pernod Ricard China' AND IsActive = TRUE ORDER BY Name]):
                                                            new List<User>([SELECT id, Name FROM User WHERE CompanyName ='Pernod Ricard Taiwan' AND IsActive = TRUE ORDER BY Name]); 
            /*
            String ttlqrl = 'Select id From ProcessInstanceWorkItem Where processinstance.status = :StatusSelected and processinstance.targetobjectid != null';
            String ttlFilter = filter(docNum, SubmitDate, selectedSubmitter, selectedApprover, selectedType);
            ttlqrl = ttlqrl + ttlFilter;
            system.debug('total size query: ' + ttlqrl);
            ttlSizeList = Database.query(ttlqrl);
            total_size = ttlSizeList.size();
            */
            //if(total_size > 0){
                String ProInsqrl = 'SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name, ' +
                            	   'processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id, processinstance.targetObject.Type ' +   // Added by 2018-01-10  Linus@introv
                                   'FROM ProcessInstanceWorkitem WHERE processinstance.status =: StatusSelected ';
                String ProInsFilter = filter(docNum, SubmitDate, selectedSubmitter, selectedApprover, selectedType);
                ProInsqrl = pageChange == false? ProInsqrl + ProInsFilter + ' ORDER BY processinstance.targetobjectid ASC, Actor.Name ASC ':
                                                 ProInsqrl + ProInsFilter + ' ORDER BY processinstance.targetobjectid ASC,  Actor.Name ASC limit :list_size offset :counter ';
                system.debug('ProIns query: ' + ProInsqrl);
           
                LProcIns = Database.query(ProInsqrl);                         
                total_size = LProcIns.size();
            	pageChange = false;
            
                String approverQrl = selectedSubmitter == 'All'? 'Select ActorId, processinstance.createdBy.id From ProcessInstanceWorkItem Where processinstance.status = :StatusSelected and processinstance.targetobjectid != null and processinstance.createdBy.id IN: allSubmitter':
                                                                 'Select ActorId, processinstance.createdBy.id From ProcessInstanceWorkItem Where processinstance.status = :StatusSelected and processinstance.targetobjectid != null and processinstance.createdBy.id =: selectedSubmitter';
            	system.debug('Approver Query: ' + approverQrl);
                allApproverID = Database.query(approverQrl);
                if(allApproverID.size()>0)
                {
                    for(ProcessInstanceWorkitem obj : allApproverID)
                    {   
                        approverID.add(obj.ActorId);
                    }//end for
                }//end if
            //}
        }else{
            total_size = 0;
        }
        // END - [SH]
        
        /*
        //pisklist:Submitter = ALL && pisklist:Approver = ALL 
        if (StatusSelected == 'Pending' && selectedApprover == 'All' && selectedSubmitter == 'All' )//&& allSubmitter.size() > 0)
        {
            allSubmitter = [SELECT id, Name FROM User WHERE CompanyName like: curUser.CompanyName AND CompanyName != 'Pernod Ricard China' AND IsActive = TRUE ORDER BY Name];
            
            total_size =  [SELECT count() FROM ProcessInstanceWorkitem 
                           WHERE processinstance.createdBy.id IN:allSubmitter AND processinstance.status = :StatusSelected
                           AND processinstance.status != null
                           AND processinstance.targetobjectid != null];
            
            if (total_size > 0)
            {    
                LProcIns = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name,
                            processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id, processinstance.targetObject.Type  // Added by 2018-01-10  Linus@introv
                            FROM ProcessInstanceWorkitem
                            WHERE processinstance.createdBy.id IN :allSubmitter AND processinstance.status =: StatusSelected
                            AND processinstance.targetobjectid != null AND processinstance.status != null
                            ORDER BY processinstance.targetobjectid ASC, Actor.Name ASC limit :list_size offset :counter ];
                
                allApproverID = [SELECT ActorId, processinstance.createdBy.id
                                 FROM ProcessInstanceWorkitem
                                 WHERE processinstance.createdBy.id IN: allSubmitter AND processinstance.status = :StatusSelected
                                 AND processinstance.targetobjectid != null AND processinstance.status != null];
            }//end if: total size > 0
            if(allApproverID.size()>0)
            {
                for(ProcessInstanceWorkitem obj : allApproverID)
                {   
                    approverID.add(obj.ActorId);
                }//end for
            }//end if
        }//end if
        
        //pisklist:Submitter = User && pisklist:Approver = ALL
        else if (StatusSelected == 'Pending' && selectedApprover == 'All' && selectedSubmitter != 'All')
        {
            total_size =  [SELECT count() FROM ProcessInstanceWorkitem 
                           WHERE processinstance.createdBy.id =:selectedSubmitter
                           AND processinstance.status = :StatusSelected
                           AND processinstance.status != null
                           AND processinstance.targetobjectid != null];
            
            if (total_size > 0)
            {    
                LProcIns = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name,
                            processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id, processinstance.targetObject.Type  // Added by 2018-01-10  Linus@introv
                            FROM ProcessInstanceWorkitem
                            WHERE processinstance.createdBy.id =:selectedSubmitter AND processinstance.status =: StatusSelected
                            AND processinstance.targetobjectid != null AND processinstance.status != null
                            ORDER BY processinstance.targetobjectid ASC, Actor.Name ASC limit :list_size offset :counter ];
                
                allApproverID = [SELECT ActorId
                                 FROM ProcessInstanceWorkitem
                                 WHERE processinstance.createdBy.id =:selectedSubmitter AND processinstance.status = :StatusSelected
                                 AND processinstance.targetobjectid != null AND processinstance.status != null];
            }//end if: total size > 0
            if(allApproverID.size()>0)
            {
                for(ProcessInstanceWorkitem obj : allApproverID)
                {
                    approverID.add(obj.ActorId);
                }//end for
            }//end if
        }//end if
        
        //pisklist:Submitter = ALL && pisklist:Approver = User
        else if(StatusSelected == 'Pending' && selectedApprover != 'All' && selectedSubmitter == 'All')// && allSubmitter.size() > 0)
        {
            total_size = [SELECT count() FROM ProcessInstanceWorkitem 
                          WHERE processinstance.createdBy.id IN :allSubmitter AND processinstance.status = :StatusSelected
                          AND processinstance.status != null
                          AND processinstance.targetobjectid != null
                          AND ActorID =: selectedApprover];
            
            system.debug('total_size: ' + total_size);
            
            if (total_size > 0)
            {
                LProcIns = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name,
                            processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id, processinstance.targetObject.Type  // Added by 2018-01-10  Linus@introv
                            FROM ProcessInstanceWorkitem
                            where processinstance.createdBy.id IN: allSubmitter AND processinstance.status = :StatusSelected AND
                            processinstance.targetobjectid != null AND processinstance.status != null
                            AND ActorId =: selectedApprover
                            order by processinstance.targetobjectid ASC, Actor.Name ASC limit :list_size offset :counter ];
                system.debug('LProcIns.size(): ' + LProcIns.size());
            }//end if
        }//end else if
        
        //pisklist:Submitter = User && pisklist:Approver = User
        else if(StatusSelected == 'Pending' && selectedApprover != 'All' && selectedSubmitter != 'All')
        {
            total_size = [SELECT count() FROM ProcessInstanceWorkitem 
                          WHERE processinstance.createdBy.id =:selectedSubmitter AND processinstance.status = :StatusSelected
                          AND processinstance.status != null
                          AND processinstance.targetobjectid != null
                          AND ActorID =: selectedApprover];
            
            system.debug('total_size: ' + total_size);
            
            if (total_size > 0)
            {
                LProcIns = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name,
                            processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id, processinstance.targetObject.Type  // Added by 2018-01-10  Linus@introv
                            FROM ProcessInstanceWorkitem
                            where processinstance.createdBy.id =: selectedSubmitter AND processinstance.status = :StatusSelected AND
                            processinstance.targetobjectid != null AND processinstance.status != null
                            AND ActorId =: selectedApprover
                            order by processinstance.targetobjectid ASC, Actor.Name ASC limit :list_size offset :counter ];
                system.debug('LProcIns.size(): ' + LProcIns.size());
            }//end if
        }//end else if
        else
        {
            total_size = 0;
        }//end else
        */
        if (LProcIns.size() >0)
        {
            // Added by 2018-01-10 Linus@introv
            // Finding Plan Start Date and End Date
            Set<Id> planIdSet = new Set<Id>();  
            Set<Id> focIdSet = new Set<Id>();           
            for(ProcessInstanceWorkitem item :  LProcIns){
                if(item.processinstance.targetObject.Type == 'ASI_MFM_Plan__c'){
                    planIdSet.add(item.processinstance.targetobjectid);
                }
                if(item.processinstance.targetObject.Type == 'ASI_FOC_Free_Goods_Request__c'){
                    focIdSet.add(item.processinstance.targetobjectid);
                }
            }            
            Map<id, ASI_MFM_Plan__c> mapPlan = new Map<id, ASI_MFM_Plan__c>([Select id, ASI_MFM_Start_Date__c, ASI_MFM_End_Date__c from ASI_MFM_Plan__c where id =: planIdSet]);
            Map<id, ASI_FOC_Free_Goods_Request__c> mapFOC = new Map<id, ASI_FOC_Free_Goods_Request__c>([Select id, recordtype.name from ASI_FOC_Free_Goods_Request__c where id =: focIdSet]);
            // End - Linus@introv                            
            
            for(ProcessInstanceWorkitem item :  LProcIns)
            {                                   
                system.debug(item);
                
                ApprovalRecord appRec = new ApprovalRecord(item);
                appRec.id = item.processinstance.targetobjectid;
                appRec.POType = (item.processinstance.targetobjectid).getSObjectType().getDescribe().getLabel();
                appRec.PONo = item.processinstance.targetobject.Name;
                appRec.Status = item.processinstance.Status;
                appRec.approver = item.ActorId;
                appRec.approverName = item.Actor.Name;
                appRec.CDate = String.valueof(item.processinstance.CreatedDate);
                appRec.lastApprovedDate = String.valueof(item.CreatedDate);
                appRec.submitter = String.valueOf(item.processinstance.createdBy.id);
                appRec.submitterName =  item.processinstance.createdBy.Name;
                // Added by 2018-01-10 Linus@introv
                appRec.StartDate = item.processinstance.targetobject.type == 'ASI_MFM_Plan__c' ? mapPlan.get(item.processinstance.targetobjectid).ASI_MFM_Start_Date__c != null? String.valueOf(mapPlan.get(item.processinstance.targetobjectid).ASI_MFM_Start_Date__c): null:null;
                appRec.EndDate = item.processinstance.targetobject.type == 'ASI_MFM_Plan__c' ? mapPlan.get(item.processinstance.targetobjectid).ASI_MFM_End_Date__c != null? String.valueOf(mapPlan.get(item.processinstance.targetobjectid).ASI_MFM_End_Date__c): null:null;
                appRec.RecordType = item.processinstance.targetobject.type == 'ASI_FOC_Free_Goods_Request__c' ? mapFOC.get(item.ProcessInstance.targetobjectid).recordtype.name: null;
                LApproval.add(appRec);
                
            }//end for
        }//end if
        
        if (total_size > 0 && total_size != null)
        {
            if (counter + list_size > total_size)
            {
                end_index = total_size;
            }//end if
            else
            {
                end_index = counter + list_size;
            }//end else
            start_index = counter +1;
        }//end if
    }//end method: queryRec
    
    private Set<String> allsubmiterSet(){
        
        List<processinstance> allsubmitterID = new List<processinstance>();
        
        Set<String> UserIDSet = new Set<String>();
        
        allsubmitterID = [SELECT createdBy.id, createdBy.Name FROM processinstance WHERE createdBy.id IN: allSubmitter AND status = 'Pending' AND targetobjectid != null AND status != null];
        Map<String, String> mapSubmitter = new Map<String, String>();
        
        
        if(allsubmitterID.size() > 0){
            for(processinstance obj : allsubmitterID)
                UserIDSet.add(obj.createdBy.id);
        }
        
        return UserIDSet;
    }
    
    // [SH] 2019-01-08
    private Set<String> alltypeSet(){
        List<processinstance> allTypeID = new List<processinstance>();
        
        Set<String> typeSet = new Set<String>();
        
        allTypeID = [SELECT targetobjectid FROM processinstance WHERE createdBy.id IN: allSubmitter AND status = 'Pending' AND targetobjectid != null AND status != null ];                
        
        if(allTypeID.size() > 0){
            for(processinstance obj : allTypeID)
                typeSet.add(obj.targetobjectid.getSObjectType().getDescribe().getLabel());
        }
        
        return typeSet;
    }
    
    public class ApprovalRecord
    {
        public ProcessInstanceWorkitem ApprovalItem {set;get;}
        public ProcessInstanceStep ApprovalItem1 {set;get;}
        public string id {set;get;}
        public String PONo {set;get;}
        public String POType {set;get;}
        // Added by 2018-01-10 Linus@introv
        public String StartDate {set;get;}
        public String EndDate {set;get;}
        // [SH] 2019-01-22 
        public String RecordType {set;get;}
        // End - Linus@introv 
        public String Status {set;get;}
        public string CDate {set;get;}
        public string approver {set;get;}
        public string approverName {set;get;}
        public string submitter {get;set;}
        public string submitterName {get;set;}
        public string lastApprovedDate {get;set;}
        
        public ApprovalRecord(ProcessInstanceWorkitem item)
        {
            ApprovalItem = item;     
        }//end constructor
        public ApprovalRecord(ProcessInstanceStep item1)
        {
            ApprovalItem1 = item1;     
        }//end constructor
        public ApprovalRecord(){}//end constructor
    }//end inner class: ApprovalRecord
}
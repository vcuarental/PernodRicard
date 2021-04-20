/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Elufa                                                             
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | ProcessInstanceWorkitem                                                                               
|     - Description     | Find related Approval Process (ProcessInstanceWorkitem) in all Object                                
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 23/12/2016                                                                        
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         | 2/2/2017 Elufa PRA Support - Should use ProcessInstanceStep object                                                                                
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/

public class ASI_MFM_KR_ApprovalListController {
    public integer counter=0;  //keeps track of the offset
    public integer list_size=5; //sets the page size or number of rows
    
    public integer total_size{get;set;} //used to show user the total size of the list
    public integer start_index{set;get;}
    public integer end_index{set;get;}
    
    public integer pageNumber{set;get;}
    public integer totalPages{set;get;}
    
    //SQL
    Public String QuerySQL {set;get;}{QuerySQL='';}
    Public String CountSQL {set;get;}{CountSQL='';}
    Public String FilterSQL {set;get;}{FilterSQL='';}
    Public String LimitSQL {set;get;}{LimitSQL='';}
    
    //User ID Set
    public set<id> SubmitterIdSet {set;get;}  
    public set<id> ApproverIdSet {set;get;}
    
    public list<ApprovalRecord> LApproval {set;get;}
    
    //Search
    Public String Submitter {set;get;}{Submitter='';}
    Public String Approver {set;get;}{Approver='';}
    Public String SubmitterId {set;get;}{SubmitterId='';}
    Public String ApproverId {set;get;}{ApproverId='';}
    
    Public String ObjectOptions {set;get;}{ObjectOptions='';}
    Public String RegionName {set;get;}{RegionName='';}
    Public String BranchName {set;get;}{BranchName='';}
    Public String Status  {set;get;}{Status='Pending';}	
    
    public ASI_MFM_Payment_Line_Item__c FromDate  { get; set; }{FromDate=new ASI_MFM_Payment_Line_Item__c();}
    public ASI_MFM_Payment_Line_Item__c ToDate  { get; set; }{ToDate =new ASI_MFM_Payment_Line_Item__c();}
    
    //Branch Name
    
     
    public String Msg {get;set;}{Msg='';}
    public boolean isProcess {get;set;} {isProcess=true;}
    

    
    public String sortField {
        get  {
            if (sortField == null){
                if(Status=='Pending'){
                    sortField = 'processinstance.targetobject.Name '; 
                }else{
                    sortField = 'targetobject.Name ';
                }
            }else{
                if(sortField=='Actor.Name' && Status!='Pending'){
                    sortField='LastActor.Name';
                }
            } 
            return sortField;  
            
        }
        set;
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
    
    
    public class ApprovalRecord{
        public ProcessInstanceWorkitem ApprovalItem {set;get;}
        public ProcessInstance ApprovalItem1 {set;get;} 
        public string id {set;get;}
        public String DocumentNo {set;get;}
        public String DocumentType {set;get;}
        public String Status {set;get;}
        public string CDate {set;get;}//Create Date
        public string approver {set;get;}
        public string approverName {set;get;}
        public string submitter {get;set;}
        public string submitterName {get;set;}
        public string lastApprovedDate {get;set;}
        
        public ApprovalRecord(ProcessInstanceWorkitem item){
            ApprovalItem = item;     
        }
        public ApprovalRecord(ProcessInstance item1){
            ApprovalItem1 = item1;     
        }
        
        public ApprovalRecord(){
        }
        
    }
    
    
    //**************************************************Pick List Value ********************************************************
    public List<SelectOption> getApprovalStatusOptions()
    {
        List<SelectOption> options = new List<SelectOption>();//Approved Pending Rejected     
        options.add(new SelectOption('Pending','Pending'));
        options.add(new SelectOption('Approved','Approved'));
        options.add(new SelectOption('Rejected','Rejected'));
        options.add(new SelectOption('Removed','Recalled'));
        
        return options;
    }
    
    //Region Name Options 
    public List<SelectOption> getRegionNameOptions() {  //select id, name from user where ASI_KOR_User_Region_Code__c !=null 
        
        String soqlUser='select ASI_KOR_User_Region_Name__c from user where IsActive = true and CompanyName like  \'%Korea%\' and ASI_KOR_User_Region_Name__c !=null group by ASI_KOR_User_Region_Name__c ';
        AggregateResult[] groupedResults=Database.query(soqlUser);
        Set<String> setRegionName = new Set<String>();
        for (AggregateResult ar : groupedResults) {
            setRegionName.add(String.valueOf(ar.get('ASI_KOR_User_Region_Name__c')));
            
        }
        List<SelectOption> RegionNameOptions = new List<SelectOption>();
        RegionNameOptions.add(new SelectOption('','--None--'));
        for(String category : setRegionName){
            RegionNameOptions.add(new SelectOption(category, category));
        }
        return RegionNameOptions;
    }
    
    public List<SelectOption> getBranchNameOptions() {
        
        String soqlUser='select ASI_KOR_User_Branch_Name__c from user where IsActive = true and CompanyName like  \'%Korea%\' and ASI_KOR_User_Branch_Name__c !=null group by ASI_KOR_User_Branch_Name__c ';
        AggregateResult[] groupedResults=Database.query(soqlUser);
        Set<String> setBranchName = new Set<String>();
        for (AggregateResult ar : groupedResults) {
            setBranchName.add(String.valueOf(ar.get('ASI_KOR_User_Branch_Name__c')));
            
        }        
        List<SelectOption> BranchNameOptions = new List<SelectOption>();
        BranchNameOptions.add(new SelectOption('','--None--'));
        for(String category : setBranchName){
            BranchNameOptions.add(new SelectOption(category, category));
        }
        return BranchNameOptions;
    }
    
    
    public List<SelectOption> getSearchObjectOptions() {
        List<ASI_KR_Setting__c> SettingList = [select id,name,ASI_MFM_Object__c,ASI_CRM_Type__c,ASI_MFM_API_Name__c from ASI_KR_Setting__c where ASI_CRM_Type__c='ASI_MFM_KR_ApprovalListPage' order by Name]; //ASI_KR_Setting__c.getAll().values();
        Set<String> setObject = new Set<String>();
        Map<String, String> ObjectMap= new Map<String, String>();
        if(SettingList!=null){
            for (ASI_KR_Setting__c Setting : SettingList) {
                if(Setting.ASI_CRM_Type__c!=null && Setting.ASI_MFM_Object__c !=null && Setting.ASI_MFM_API_Name__c !=null){
                    if(Setting.ASI_CRM_Type__c=='ASI_MFM_KR_ApprovalListPage' ){
                        setObject.add(setting.ASI_MFM_Object__c);
                        ObjectMap.put(setting.ASI_MFM_Object__c, setting.ASI_MFM_API_Name__c);
                    }
                }
                
            }
        }
        List<SelectOption> SearchObjectOptions = new List<SelectOption>();
        SearchObjectOptions.add(new SelectOption('','--None--'));
        for(string key : ObjectMap.keySet()){
            SearchObjectOptions.add(new SelectOption(ObjectMap.get(key),key));
        }
        return SearchObjectOptions;
    }
    //**************************************************Pick List Value ********************************************************
    
    
    
    public ASI_MFM_KR_ApprovalListController(){
        Status='Pending';
        init();
    }
    
    
    public void init(){
        Date SelectedDate =  Date.today(); 
        Date firstDate = SelectedDate.toStartOfMonth();
        fromDate.ASI_MFM_Invoice_Date__c=firstDate;
        Date SelectedDateMonthEnd= firstDate.addDays(date.daysInMonth(SelectedDate.year() , SelectedDate.month())  - 1);
        ToDate.ASI_MFM_Invoice_Date__c=SelectedDateMonthEnd;
        
        Approver='';
       
        ApproverId='';
        ObjectOptions='';
        RegionName='';
        BranchName='';
        if(Status=='Pending'){
            sortField = 'processinstance.targetobject.Name ';
        }else{
            sortField = 'targetobject.Name ';
        }
        
        
        list_size=integer.valueOf(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_KR_Approval_List_No_Of_Row__c) ;
        SubmitterIdSet= new set<id>();
        ApproverIdSet= new set<id>();
        SubmitterIdSet.add(System.UserInfo.getUserId());
        counter=0;
        end_index = list_size;
        start_index=1;
        pageNumber=1;
        Submitter=System.UserInfo.getName();
        SubmitterId=System.UserInfo.getUserId();
        
        
        String fromDate_s = DateTime.newInstance(fromDate.ASI_MFM_Invoice_Date__c.year(),fromDate.ASI_MFM_Invoice_Date__c.month(),fromDate.ASI_MFM_Invoice_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
        String toDate_c = DateTime.newInstance(toDate.ASI_MFM_Invoice_Date__c.year(),toDate.ASI_MFM_Invoice_Date__c.month(),toDate.ASI_MFM_Invoice_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
        
        
        if(Status=='Pending'){
            FilterSQL=' AND processinstance.CreatedDate >=  ' + fromDate_s + 'T00:00:00Z '+' AND processinstance.CreatedDate <= ' + toDate_c + 'T00:00:00Z '  +' and processinstance.createdBy.id IN (\''+System.UserInfo.getUserId()+'\') '+GetObjectSQL();
        }else{
            FilterSQL=' AND CreatedDate >=  ' + fromDate_s + 'T00:00:00Z '+' AND CreatedDate <= ' + toDate_c + 'T00:00:00Z ' +' and createdBy.id IN (\''+System.UserInfo.getUserId()+'\') and status =\''+Status+'\''+GetObjectSQL();
        }
        
        queryRecord();
        
    }
    
    Public String GetObjectSQL(){
        String StrSQL=' And (';
        Boolean FirstFind= false;
        List<ASI_KR_Setting__c> SettingList = [select id,name,ASI_MFM_Object__c,ASI_CRM_Type__c,ASI_MFM_API_Name__c from ASI_KR_Setting__c where ASI_CRM_Type__c='ASI_MFM_KR_ApprovalListPage' order by Name];
          if(SettingList!=null){
            for (ASI_KR_Setting__c Setting : SettingList) {
                if(Setting.ASI_CRM_Type__c!=null && Setting.ASI_MFM_Object__c !=null && Setting.ASI_MFM_API_Name__c !=null){
                    if(Setting.ASI_CRM_Type__c=='ASI_MFM_KR_ApprovalListPage' ){
                        if(!FirstFind){
                            FirstFind=true;
                            StrSQL+=' processinstance.TargetObject.Type=  \''+setting.ASI_MFM_API_Name__c+'\' ';
                        }else{
                            StrSQL+=' OR processinstance.TargetObject.Type= \''+setting.ASI_MFM_API_Name__c+'\' ';
                        }
                    }
                }
                
            }
        }
        StrSQL+=')';
        return StrSQL;
        
    }
    
    public void queryRecord(){
        
        if(Status=='Pending'){
            //CountSQL='SELECT count() FROM ProcessInstanceWorkitem  where  processinstance.status = \'Pending\'  AND processinstance.status != null AND processinstance.targetobjectid != null ';
            CountSQL='SELECT count() FROM ProcessInstanceWorkitem  where processinstance.createdBy.CompanyName like \'%Korea%\' AND processinstance.status = \'Pending\'  AND processinstance.status != null AND processinstance.targetobjectid != null ';
            //QuerySQL='SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.TargetObject.Type, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name, processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id FROM ProcessInstanceWorkitem'+' where processinstance.status = \'Pending\' AND processinstance.targetobjectid != null AND processinstance.status != null '; //For testing only//UserIdSet.add('005D00000023l95');
            QuerySQL='SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.TargetObject.Type, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name, processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id FROM ProcessInstanceWorkitem'+' where processinstance.createdBy.CompanyName like \'%Korea%\' AND processinstance.status = \'Pending\' AND processinstance.targetobjectid != null AND processinstance.status != null '; //For testing only//UserIdSet.add('005D00000023l95');
        }else{
            //CountSQL='SELECT count() FROM ProcessInstance where status != null AND targetobjectid != null ';
            CountSQL='SELECT count() FROM ProcessInstance where createdBy.CompanyName like \'%Korea%\' AND status != null AND targetobjectid != null ';
            //QuerySQL='SELECT Id,CompletedDate,CreatedBy.Name,targetobject.Name,CreatedDate,LastModifiedById,LastModifiedDate,TargetObjectId,Status,SubmittedBy.Name,LastActorId,LastActor.Name,(SELECT ID, ProcessNodeId, StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending,OriginalActorId,OriginalActor.Name,ProcessInstanceId,RemindersSent,CreatedDate FROM StepsAndWorkitems order by CreatedDate desc ) FROM ProcessInstance where status != null AND targetobjectid != null';
            QuerySQL='SELECT Id,CompletedDate,CreatedBy.Name,targetobject.Name,CreatedDate,LastModifiedById,LastModifiedDate,TargetObjectId,Status,SubmittedBy.Name,LastActorId,LastActor.Name,(SELECT ID, ProcessNodeId, StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending,OriginalActorId,OriginalActor.Name,ProcessInstanceId,RemindersSent,CreatedDate FROM StepsAndWorkitems order by CreatedDate desc ) FROM ProcessInstance where createdBy.CompanyName like \'%Korea%\' AND status != null AND targetobjectid != null';
        }
        
        
        LimitSQL= ' order by '+sortField+'  '+sortDir+'  limit  '+list_size+' offset  '+counter;  //LimitSQL= ' order by processinstance.targetobjectid ASC  limit  '+list_size+' offset  '+counter;
        
        LApproval = new list<ApprovalRecord>();
        List<ProcessInstanceWorkitem> LProcIns = new list<ProcessInstanceWorkitem>();
        List<ProcessInstance> PIList = new list<ProcessInstance>();
        
        
        if(SubmitterIdSet.size()>0 || ApproverIdSet.size()>0 ){

            //system.assertEquals(null,QuerySQL+FilterSQL+LimitSQL);
            //Get Total size
            total_size=Database.countQuery(CountSQL+FilterSQL);
           
            if (total_size > 0){ system.debug('Test current SQL!!!  '+QuerySQL+FilterSQL+LimitSQL);
                if(Status=='Pending'){
                    system.debug('het GetObjectSQL now'+GetObjectSQL());
                    system.debug('Test current Pending SQL!!!  '+QuerySQL+FilterSQL+LimitSQL);
                    LProcIns=Database.query(QuerySQL+FilterSQL+LimitSQL);
                }else{
                    PIList=Database.query(QuerySQL+FilterSQL+LimitSQL);
                } 
            }
        }else{
            total_size = 0;
        }
        
        //After Getting Data, handling data
        if(Status=='Pending'){
            for(ProcessInstanceWorkitem item :  LProcIns){
                ApprovalRecord appRec = new ApprovalRecord(item);
                appRec.id = item.processinstance.targetobjectid;
                system.debug('targetobjectid: '+item.processinstance.TargetObject.Type);
                appRec.DocumentType = (item.processinstance.targetobjectid).getSObjectType().getDescribe().getLabel();
                appRec.DocumentNo = item.processinstance.targetobject.Name;
                appRec.Status = item.processinstance.Status;
                appRec.approver = item.ActorId;
                appRec.approverName = item.Actor.Name;
                appRec.CDate = String.valueof(item.processinstance.CreatedDate);
                appRec.lastApprovedDate = String.valueof(item.CreatedDate);
                appRec.submitter = String.valueOf(item.processinstance.createdBy.id);
                appRec.submitterName =  item.processinstance.createdBy.Name;
                LApproval.add(appRec);
            }//end of for loop
        }else{
            //system.assertEquals(null,QuerySQL+FilterSQL+LimitSQL);         //system.assertEquals(null,PIList);
            for(ProcessInstance item :  PIList){
                ApprovalRecord appRec = new ApprovalRecord(item);
                appRec.id = item.targetobjectid;
                appRec.DocumentType = (item.targetobjectid).getSObjectType().getDescribe().getLabel();
                appRec.DocumentNo = item.targetobject.Name;
                if(item.Status=='Removed'){
                    appRec.Status ='Recalled';
                }else{
                    appRec.Status = item.Status;
                }
                
                appRec.approver =  item.StepsAndWorkitems.size()>0 ?item.StepsAndWorkitems[0].OriginalActorId:null;// system.assertEquals(null, item.StepsAndWorkitems.size());
                appRec.approverName = item.StepsAndWorkitems.size()>0? item.StepsAndWorkitems[0].OriginalActor.Name:null;// item.StepsAndWorkitems[0].OriginalActor.Name;//system.debug('Test StepsAndWorkitems '+item.StepsAndWorkitems[0].OriginalActor.Name);
            
                appRec.CDate = String.valueof(item.CreatedDate);
                appRec.lastApprovedDate = String.valueof(item.CompletedDate);
                appRec.submitter = String.valueOf(item.createdBy.id);
                appRec.submitterName =  item.createdBy.Name;
                LApproval.add(appRec);
            }
        }
        if(!test.isRunningTest()){
            totalPages=getTotalPages();
        }
        
        
        if (total_size > 0 && total_size != null){
            if ( counter + list_size > total_size){
                end_index = total_size;
            }else{
                end_index = counter + list_size;
            }
            start_index = counter +1;
        }
        
    }
    
    
    
    //Search result
    public void runSearch(){ //
        isProcess=true;
        Msg='';
        FilterSQL=' ';
        if(Status=='Pending'){
            if(SubmitterId!=null && SubmitterId.length()>0){
                if(ObjectOptions!=null && ObjectOptions.length()>0 && ObjectOptions=='ASI_MFM_PO__c'){
                    List<ASI_MFM_Purchase_Request__c> PRList= [select id,(select id,ownerId from POs__r) from ASI_MFM_Purchase_Request__c where ownerId=:SubmitterId];
                    set<String> POOwnerSet= new set<String>();
                    for(ASI_MFM_Purchase_Request__c pr:PRList){
                        for(ASI_MFM_PO__c po:pr.POs__r){
                            POOwnerSet.add(po.ownerId);
                        }
                    }
                    if(POOwnerSet.size()>0){
                         FilterSQL+=ConstructSQLPO(POOwnerSet);
                    }else{
                      FilterSQL +='And processinstance.createdBy.id= \''+SubmitterId+'\' ';   
                    } //FilterSQL +='And processinstance.targetobject.ASI_MFM_Purchase_Request__r.ownerId= \''+SubmitterId+'\' ';
                }else{
                    FilterSQL +='And processinstance.createdBy.id= \''+SubmitterId+'\' '; 
                }
               
            }
            if(ApproverId!=null && ApproverId.length()>0){
                FilterSQL +='And ActorId= \''+ApproverId+'\' ';
            }
            
            if(ObjectOptions!=null && ObjectOptions.length()>0){
                //
                FilterSQL +=' And processinstance.TargetObject.Type= \''+ObjectOptions+'\' ';
            }else{
                FilterSQL +=GetObjectSQL();
            }
            
            List<user> UserResult=new List<user> ();
            //Region Name
            if(RegionName!=null && RegionName.length()>0){
                UserResult=new List<user> ();
                String SQLStr='Select Id from user where IsActive = true and CompanyName like  \'%Korea%\' and ASI_KOR_User_Region_Name__c= \''+RegionName+'\'';
                UserResult= Database.query(SQLStr);
                FilterSQL +=ConstructSQL(UserResult);
            }
            
            //Branch Name
            if(BranchName!=null && BranchName.length()>0){
                UserResult=new List<user>();
                String SQLStr='Select Id from user where IsActive = true and CompanyName like  \'%Korea%\' and ASI_KOR_User_Branch_Name__c = \''+BranchName+'\'';
                UserResult= Database.query(SQLStr);
                if(ObjectOptions!=null && ObjectOptions.length()>0 && ObjectOptions=='ASI_MFM_PO__c'){//FilterSQL +=ConstructSQLPO(UserResult);
                    set<id> UIDSet = new set<id>();
                    for(user u: UserResult){
                        UIDSet.add(u.Id);
                    }
                    
                    List<ASI_MFM_Purchase_Request__c> PRList= [select id,(select id,ownerId from POs__r) from ASI_MFM_Purchase_Request__c where ownerId IN : UIDSet];
                    set<String> POOwnerSet= new set<String>();
                    for(ASI_MFM_Purchase_Request__c pr:PRList){
                        for(ASI_MFM_PO__c po:pr.POs__r){
                            POOwnerSet.add(po.ownerId);
                        }
                    }
                    FilterSQL+=ConstructSQLPO(POOwnerSet);
                    
                    
                }else{
                 
                    FilterSQL +=ConstructSQL(UserResult);
                }
            }
            
            if (fromDate.ASI_MFM_Invoice_Date__c != null) {
                String fromDate_s = DateTime.newInstance(fromDate.ASI_MFM_Invoice_Date__c.year(),fromDate.ASI_MFM_Invoice_Date__c.month(),fromDate.ASI_MFM_Invoice_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                FilterSQL += ' AND processinstance.CreatedDate >= ' + fromDate_s + 'T00:00:00Z '; 
            }else{
                isProcess=false;
                Msg+='Please input Submitted Date From.<br/>';
            }
            
            if (toDate.ASI_MFM_Invoice_Date__c != null) {
                String toDate_c = DateTime.newInstance(toDate.ASI_MFM_Invoice_Date__c.year(),toDate.ASI_MFM_Invoice_Date__c.month(),toDate.ASI_MFM_Invoice_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                FilterSQL += ' AND processinstance.CreatedDate <= ' + toDate_c + 'T00:00:00Z '; 
            }else{
                isProcess=false;
                Msg+='Please input Submitted Date To.<br/>';
            }
            
            
            if(toDate.ASI_MFM_Invoice_Date__c !=null && fromDate.ASI_MFM_Invoice_Date__c != null){
                if(toDate.ASI_MFM_Invoice_Date__c <fromDate.ASI_MFM_Invoice_Date__c){
                    isProcess=false;
                    Msg+='To Date< From Date.<br/>';
                }
                /*
                if(toDate.ASI_MFM_Invoice_Date__c >system.today()){
                    isProcess=false;
                    Msg+='To Date cannot greater than today.';
                }
                if(fromDate.ASI_MFM_Invoice_Date__c >system.today()){
                    isProcess=false;
                    Msg+='From Date cannot greater than today.';
                }
                */
            }
            
            /*if(SubmitterId.length()==0 &&  BranchName==null ){
                isProcess=false;
                Msg+='Please input Submitter or select one Team.';
            }*/ //20170224, Leo
            if(ObjectOptions==null)
            {
                isProcess=false;
                Msg+='Please select Type.';
            } //20170224, Leo
        }else{
            if(SubmitterId!=null && SubmitterId.length()>0){
                if(ObjectOptions!=null && ObjectOptions.length()>0 && ObjectOptions=='ASI_MFM_PO__c'){//FilterSQL +='And targetobject.ASI_MFM_Purchase_Request__r.ownerId= \''+SubmitterId+'\' ';
                    List<ASI_MFM_Purchase_Request__c> PRList= [select id,(select id,ownerId from POs__r) from ASI_MFM_Purchase_Request__c where ownerId=:SubmitterId];
                    set<String> POOwnerSet= new set<String>();
                    for(ASI_MFM_Purchase_Request__c pr:PRList){
                        for(ASI_MFM_PO__c po:pr.POs__r){
                            POOwnerSet.add(po.ownerId);
                        }
                    }
                     if(POOwnerSet.size()>0){
                         FilterSQL+=ConstructSQLPO(POOwnerSet);
                    }else{
                      FilterSQL +='And processinstance.createdBy.id= \''+SubmitterId+'\' ';   
                    }                    
                }else{
                    FilterSQL +='And createdBy.id= \''+SubmitterId+'\' '; 
                }
            }
            
            if(ApproverId!=null && ApproverId.length()>0){
                FilterSQL +='And ActorId= \''+ApproverId+'\' ';
            }
            
            if(ObjectOptions!=null && ObjectOptions.length()>0){
                FilterSQL +='And TargetObject.Type= \''+ObjectOptions+'\' ';
            }else{
                FilterSQL +=GetObjectSQL();
            }
            
            List<user> UserResult=new List<user> ();
            //Region Name
            if(RegionName!=null && RegionName.length()>0){
                UserResult=new List<user> ();
                String SQLStr='Select Id from user where IsActive = true and CompanyName like  \'%Korea%\' and ASI_KOR_User_Region_Name__c= \''+RegionName+'\'';
                UserResult= Database.query(SQLStr);
                FilterSQL +=ConstructSQL(UserResult);
            }
            
            //Branch Name
            if(BranchName!=null && BranchName.length()>0){
                UserResult=new List<user> ();
                String SQLStr='Select Id from user where IsActive = true and CompanyName like  \'%Korea%\' and ASI_KOR_User_Branch_Name__c = \''+BranchName+'\'';
                UserResult= Database.query(SQLStr);
                if(ObjectOptions!=null && ObjectOptions.length()>0 && ObjectOptions=='ASI_MFM_PO__c'){
                    set<id> UIDSet = new set<id>();
                    for(user u: UserResult){
                        UIDSet.add(u.Id);
                    }
                    
                    List<ASI_MFM_Purchase_Request__c> PRList= [select id,(select id,ownerId from POs__r) from ASI_MFM_Purchase_Request__c where ownerId IN : UIDSet];
                    set<String> POOwnerSet= new set<String>();
                    for(ASI_MFM_Purchase_Request__c pr:PRList){
                        for(ASI_MFM_PO__c po:pr.POs__r){
                            POOwnerSet.add(po.ownerId);
                        }
                    }
                    FilterSQL+=ConstructSQLPO(POOwnerSet);
                }else{
                    FilterSQL +=ConstructSQL(UserResult);
                }
                
               
            }
            if(!String.isEmpty(Status)){
                FilterSQL +='and Status = \''+Status+'\'';
            }
            
            if (fromDate.ASI_MFM_Invoice_Date__c != null) {
                String fromDate_s = DateTime.newInstance(fromDate.ASI_MFM_Invoice_Date__c.year(),fromDate.ASI_MFM_Invoice_Date__c.month(),fromDate.ASI_MFM_Invoice_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                FilterSQL += ' AND CreatedDate >= ' + fromDate_s + 'T00:00:00Z '; 
            }else{
                isProcess=false;
                Msg+='Please input Submitted Date From.<br/>';
            }
            
            if (toDate.ASI_MFM_Invoice_Date__c != null) {
                String toDate_c = DateTime.newInstance(toDate.ASI_MFM_Invoice_Date__c.year(),toDate.ASI_MFM_Invoice_Date__c.month(),toDate.ASI_MFM_Invoice_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                FilterSQL += ' AND CreatedDate <= ' + toDate_c + 'T00:00:00Z '; 
            }else{
                isProcess=false;
                Msg+='Please input Submitted Date To.<br/>';
            }
            
            /*if(SubmitterId.length()==0 &&  BranchName==null){
                isProcess=false;
                Msg='Please input Submitter or select one Team.';
            }*/ //20170224, Leo
            if(ObjectOptions==null)
            {
                isProcess=false;
                Msg+='Please select Type.';
            } //20170224, Leo
          
        }
        
        //system.assertEquals(FilterSQL, null);
        if(isProcess){
            queryRecord();    
        }
        
    }
    
    
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    
    public Integer getTotalPages() {
        //system.debug(list_size+' || '+total_size+'Current Page:' + math.mod(total_size, list_size) );
        if (math.mod(total_size, list_size) > 0) {
            
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    
    
    
    
    
    //Reset result
    public void Reset(){
        init();
    }
    
    public String ConstructSQL( List<user> UserList){
        String AddOnSql='',SubmitterSQL='',ApproverSQL='';
        Boolean FirstFind= false;
        for(user u:UserList){
            if(!FirstFind){
                FirstFind=true;
                SubmitterSQL +=' processinstance.createdBy.id IN (\''+u.Id+'\'';
                ApproverSQL +=' ActorId IN (\''+u.Id+'\'';
            }else{
                SubmitterSQL+=',\''+u.Id+'\'';
                ApproverSQL+=',\''+u.Id+'\'';
            }
        }//end of for loop
        
        if(FirstFind){
            SubmitterSQL+=' ) ';
            ApproverSQL+=' ) ';
        }
        
        AddOnSql='And '+SubmitterSQL+' ';  //AddOnSql='And ( '+SubmitterSQL+' or '+ApproverSQL +' ) ';
        return AddOnSql;
    }
    
    public String ConstructSQLPO( Set<String> UserList){
        String AddOnSql='',SubmitterSQL='',ApproverSQL='';
        Boolean FirstFind= false;
        if(UserList.size()>0){
             for(String u:UserList){
            if(!FirstFind){
                FirstFind=true;
                SubmitterSQL +=' processinstance.createdBy.id IN (\''+u+'\'';
            }else{
                SubmitterSQL+=',\''+u+'\'';
            }
        }//end of for loop
        
        if(FirstFind){
            SubmitterSQL+=' ) ';
        }
        
        AddOnSql='And '+SubmitterSQL+' ';
        }else{
            AddOnSql='';
        }
       
        
        return AddOnSql;
    }
    
    
    //sort
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        queryRecord();
    }
    
    
    @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try
        {
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }
    
}
public without sharing class ASI_CRM_PendingApprovalListController {
    public integer counter=0;  //keeps track of the offset
    public integer list_size=10; //sets the page size or number of rows
    public integer total_size{get;set;} //used to show user the total size of the list
    public integer start_index{set;get;}
    public integer end_index{set;get;}
    public list<ApprovalRecord> LApproval {set;get;}
    public string statusSelected {set;get;}
    public String currentUserID = userInfo.getUserID();
    
    public ASI_CRM_PendingApprovalListController(){
        init();
    }
    
    public void init(){
        
        statusSelected = 'Pending';
        counter=0;
        end_index = list_size;
        start_index=1;
        queryRec();
    }
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        queryRec();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        queryRec();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        queryRec();
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        queryRec();
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    public void changeStatus(){
        counter = 0;
        start_index = 0;
        end_index = 0;
        queryRec();
    }
    
    public void changeStatus2(){
        counter = 0;
        start_index = 0;
        end_index = 0;
        queryRec();
    }
    
    public void queryRec(){
        
        LApproval = new list<ApprovalRecord>();
        List<ProcessInstanceWorkitem> LProcIns = new list<ProcessInstanceWorkitem>();
        
        total_size = [SELECT count() FROM ProcessInstanceWorkitem 
                      where processinstance.createdBy.id = : currentUserId AND processinstance.status = :StatusSelected
                      AND processinstance.status != null
                      AND processinstance.targetobjectid != null
                     ];
        system.debug('total_size: ' + total_size);
        
        if (total_size > 0){
            LProcIns = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid, processinstance.createdBy.id, processinstance.createdBy.Name,
                        processinstance.Status, Actor.Name, CreatedDate, processinstance.CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id
                        FROM ProcessInstanceWorkitem
                        where processinstance.createdBy.id = : currentUserId AND processinstance.status = :StatusSelected AND
                        processinstance.targetobjectid != null AND processinstance.status != null
                        order by processinstance.targetobjectid ASC, Actor.Name ASC limit :list_size offset :counter ];
            system.debug('LProcIns.size(): ' + LProcIns.size());
        }
            
        if (LProcIns.size() >0){
            for(ProcessInstanceWorkitem item :  LProcIns){
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
                LApproval.add(appRec);
            }
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
    
    
    public class ApprovalRecord{
        public ProcessInstanceWorkitem ApprovalItem {set;get;}
        public ProcessInstanceStep ApprovalItem1 {set;get;}
        public string id {set;get;}
        public String PONo {set;get;}
        public String POType {set;get;}
        public String Status {set;get;}
        public string CDate {set;get;}
        public string approver {set;get;}
        public string approverName {set;get;}
        public string submitter {get;set;}
        public string submitterName {get;set;}
        public string lastApprovedDate {get;set;}
        
        public ApprovalRecord(ProcessInstanceWorkitem item){
            ApprovalItem = item;     
        }
        public ApprovalRecord(ProcessInstanceStep item1){
            ApprovalItem1 = item1;     
        }
        
        public ApprovalRecord(){
        }
    }
}
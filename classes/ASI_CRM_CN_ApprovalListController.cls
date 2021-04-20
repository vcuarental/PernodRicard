/* Filename:  ASI_CRM_CN_ApprovalListController.cls
* Author:    Stella Sing (Introv Limited)
* Purpose:  Show all Awaiting approval record submitted
*
* History
* -----------------------------------------------------------------------------
* 2014-02-27  stella.sing@introv.com    Created
* 2014-02-28  stella.sing@introv.com    Add Pagination
*/

public without sharing class ASI_CRM_CN_ApprovalListController{
    public integer counter=0;  //keeps track of the offset
    public integer list_size=10; //sets the page size or number of rows
    public integer total_size{get;set;} //used to show user the total size of the list
    public integer start_index{set;get;}
    public integer end_index{set;get;}
    public integer pageNumber=1;
    public list<ApprovalRecord> LApproval {set;get;}
    public string statusSelected {set;get;}
    public integer totalrecords{set;get;}
    public integer totalpage{set;get;}
    
    public ASI_CRM_CN_ApprovalListController(){
        init();
    }
    
    public List<SelectOption> getStatusItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Pending','Pending'));
        options.add(new SelectOption('Approved','Approved'));
        options.add(new SelectOption('Rejected','Rejected'));
        return options;
    }
    
    public void init(){
        statusSelected = 'Pending';
        counter=0;
        end_index = list_size;
        start_index=1;
        queryRec();
        //getResult();
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
        pageNumber=1;
        queryRec();
    }
    
    public void queryRec(){
        LApproval = new list<ApprovalRecord>();
        id CUserId = userinfo.getUserId();
        if (StatusSelected == 'Pending'){
            List<ProcessInstanceWorkitem> LProcIns = new list<ProcessInstanceWorkitem>();
            total_size =             [SELECT count() FROM ProcessInstanceWorkitem 
                                      where  createdBy.id = :CUserId AND processinstance.status = :StatusSelected
                                      AND processinstance.status != null
                                      AND processinstance.targetobjectid != null   ];
            if (total_size > 0){    
                LProcIns = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid,
                            processinstance.Status, Actor.Name, CreatedDate, processinstance.TargetObject.Name, OriginalActor.Name, CreatedBy.name, CreatedBy.id
                            FROM ProcessInstanceWorkitem
                            where createdBy.id = :CUserId AND processinstance.status = :StatusSelected AND
                            processinstance.targetobjectid != null AND processinstance.status != null
                            order by processinstance.CreatedDate DESC limit :list_size offset :counter ]; 
            }
            if (LProcIns.size() >0){
                for(ProcessInstanceWorkitem item :  LProcIns)
                {
                    system.debug(item);
                    ApprovalRecord appRec = new ApprovalRecord(item);
                    appRec.id = item.processinstance.targetobjectid;
                    //if (item.processinstance.targetobjectid != null){
                    appRec.POType = (item.processinstance.targetobjectid).getSObjectType().getDescribe().getLabel();
                    appRec.PONo = item.processinstance.targetobject.Name;
                    //}
                    appRec.Status = item.processinstance.Status;
                    appRec.approver = item.ActorId;
                    appRec.approverName = item.Actor.Name;
                    appRec.CDate = String.valueof(item.CreatedDate);
                    LApproval.add(appRec);
                }
                
            }
        }else{
            List<ProcessInstanceStep> LProcIns = new list<ProcessInstanceStep>();
            total_size  = [SELECT count()
                           FROM ProcessInstanceStep where createdBy.id = :userinfo.getUserId() 
                           AND Stepstatus = :StatusSelected ];
            system.debug('total_size: ' + total_size);
            if (total_size > 0){
                LProcIns = [SELECT processinstance.targetobjectid ,processinstance.TargetObject.Name, processinstance.CreatedDate ,
                            StepStatus, Comments  , actorid, actor.name
                            FROM ProcessInstanceStep where createdBy.id = :userinfo.getUserId() 
                            AND Stepstatus = :StatusSelected AND processinstance.targetobjectid != null
                            order by createdDate DESC limit :list_size offset :counter ]; //
                system.debug('LProcIns.size(): ' + LProcIns.size());
            }
            if (LProcIns.size()>0){
                for(ProcessInstanceStep item1 :  LProcIns )
                {
                    system.debug(item1);
                    ApprovalRecord appRec = new ApprovalRecord(item1);
                    appRec.id = item1.processinstance.targetobjectid;
                    system.debug('appRec.id: ' + appRec.id);
                    //if (item1.processinstance.targetobjectid != null){
                    appRec.POType = (item1.processinstance.targetobjectid).getSObjectType().getDescribe().getLabel();
                    appRec.PONo = item1.processinstance.targetobject.Name;
                    //}
                    appRec.Status = item1.StepStatus;
                    appRec.approver = item1.ActorId;
                    appRec.approverName = item1.Actor.Name;
                    appRec.CDate = String.valueof(item1.processinstance.CreatedDate);
                    LApproval.add(appRec);
                    
                }
            }
            
        }
        if (total_size > 0 && total_size != null){
            if (math.mod(total_size, list_size) > 0) {
                totalpage = total_size/list_size + 1;
            } else {
                totalpage = (total_size/list_size);
            }
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
        public sObject ApprovalRecord {set;get;}
        public string id {set;get;}
        public String PONo {set;get;}
        public String POType {set;get;}
        public String InputBy {set;get;}
        public String PORemarks {set;get;}
        public String Amount {set;get;}
        public String Status {set;get;}
        public String comments {set;get;}
        public string CDate {set;get;}
        public Boolean selected {get; set;}
        public string approver {set;get;}
        public string approverName {set;get;}
        
        
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
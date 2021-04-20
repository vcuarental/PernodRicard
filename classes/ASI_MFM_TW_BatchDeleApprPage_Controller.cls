/* Filename:    ASI_HK_Batch_Dele_Appr_Page_Controller .cls
 * Author:      Steve Wan (Introv Limited)
 * Purpose: 
 *
 *
 * History: copied from ASI_HK_Batch_Dele_Appr_Page_Controller
 * -----------------------------------------------------------------------------
 * 2014-08-06   steve.wan@introv.com      Created
 * 
 */

public with sharing class ASI_MFM_TW_BatchDeleApprPage_Controller {
    public list<ApprovalRecord> LApproval {set;get;}
    public map<id, user> MUser {set;get;}
    public boolean showCheckbox {set;get;}
    public boolean showPO {set;get;}
    public boolean showSO {set;get;}
    public boolean showPAF {set;get;}
    public boolean showPlan {set;get;}
    public string objectSelected {set;get;}
    public string statusSelected {set;get;}
    public string objectHeader {set;get;}
    public integer appCount {set;get;}
    
    public ASI_MFM_TW_BatchDeleApprPage_Controller (){
        init();
    }
    
    public void testdata(){
        /*ApprovalRecord dummy = new ApprovalRecord();
        dummy.PONo = '22120001';
        dummy.InputBy = 'Deo LIN';
        dummy.PORemarks = 'RS 2012 Polo Press Conference';
        dummy.Amount = '100,000.00';
        dummy.Status = 'Await Approval';
        LApproval.add(dummy);         
        
        dummy = new ApprovalRecord();
        dummy.PONo = '22120003';
        dummy.InputBy = 'Deo LIN';
        dummy.PORemarks = 'RS 2012 OOH Oct to Nov in Xin Tian Di';
        dummy.Amount = '300,000.00';
        dummy.Status = 'Await Approval';
        LApproval.add(dummy);   
        
        ValidationRecord dummyValidation = new ValidationRecord();
        dummyValidation.PONo = 'TEST0002';
        dummyValidation.Comment = 'Comments';
        dummyValidation.Owner = 'Introv Admin';        
        LValidation.add(dummyValidation);*/
    }
    
    public void init(){
        showCheckbox = true;
        objectselected = 'ASI_MFM_Plan__c';
        objectHeader = 'Plan';
        statusSelected = 'Pending'; 
        appCount = 0;   
        queryRec();
        testdata();   
                      
    }
    
    public void queryRec(){
        if(objectselected == 'ASI_MFM_Plan__c'){
            objectHeader = 'Plan';
            showPO = false;
            showSO = false;
            showPAF = false;
            showPlan = true;
        }
        LApproval = new list<ApprovalRecord>();
        Set<id> RecID = new set<id>();
        Map<id, ProcessInstanceWorkitem> MProcIns = new Map<id, ProcessInstanceWorkitem>();

        //Get All users which is delegated to the Logon User
        List<User> LUsers = [SELECT IsActive, Country, Email, FirstName, Name, LastName, ManagerId, Title, Id, Username, DelegatedApproverId, CompanyName 
                FROM User
                where IsActive = true and DelegatedApproverId = :userinfo.getUserId() 
               ];
                system.debug('User Size:' + LUsers.size());
                //Retrieve All pending Status
        List<ProcessInstanceWorkitem> LProcIns = [SELECT ActorId, OriginalActorId, ProcessInstanceId, Id, processinstance.targetobjectid,
                processinstance.Status 
                FROM ProcessInstanceWorkitem
                where processinstance.Status = :statusSelected and (actorId in :LUsers or actorId = :userinfo.getUserId())
                order by processinstance.targetobjectid];
        for(ProcessInstanceWorkitem item :  LProcIns){
                    system.debug(item);
                    system.debug(GetKeyPrefix(item.processinstance.targetobjectid));
                    if(GetKeyPrefix(item.processinstance.targetobjectid)== objectSelected ){
                        RecID.add(item.processinstance.targetobjectid);
                        //LApproval.add(new ApprovalRecord(item));
                        MProcIns.put(item.processinstance.targetobjectid, item);
                    }
        }
        if(objectselected == 'ASI_MFM_Plan__c'){
           for(ASI_MFM_Plan__c rec : [Select id, name, createdby.name,ASI_MFM_Plan_Name__c, ASI_MFM_Plan_Amount__c, Owner.Id, Owner.Name from ASI_MFM_Plan__c WHERE id in:RecID]){
                 ApprovalRecord appRec = new ApprovalRecord(MProcIns.get(rec.id));
                    appRec.ApprNo= rec.name;
                    appRec.InputBy = rec.Owner.Name;
                    //appRec.Amount = String.valueof(rec.ASI_MFM_Plan_Amount__c);
                    appRec.Amount = rec.ASI_MFM_Plan_Amount__c.format();
                    appRec.Remarks = rec.ASI_MFM_Plan_Name__c;
                    appRec.Status = statusSelected;
                    appRec.id = rec.id;
                    if(MProcIns.get(rec.id).actorId == userinfo.getUserId())
                        appRec.Delegation = 'Non-delegated';
                    else
                        appRec.Delegation = 'Delegated';
                    LApproval.add(appRec);
            }
        }
    }
    
    public void selectAll(){
        for(ApprovalRecord r : LApproval){
            r.selected = true;
        }
    }
    public void deSelectAll(){
        for(ApprovalRecord r : LApproval){
            r.selected = false;
        }
    }
    
    public void approve(){
        appCount = processApproval(true);
        queryRec();
    }
    
    public void reject(){
        appCount = processApproval(false);
        queryRec();
    }
    
    public integer processApproval(boolean approve){
        String msg = ' Record(s) Rejected';
        String action = 'Reject';
        if(approve){
            action = 'Approve';
            msg = ' Record(s) Approved';
        }
        integer appCount = 0;
        for(ApprovalRecord rec : LApproval){
            if(rec.selected){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction(action);
                req.setComments(rec.comments);
                req.setWorkitemId(rec.ApprovalItem.id);
                Approval.ProcessResult result = Approval.process(req);
                appCount++;
            }
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueof(appCount) + msg));
        return appCount;
    }
    
    public List<SelectOption> getObjItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ASI_MFM_Plan__c','Plan'));
       return options;
    }
    
    public List<SelectOption> getStatusItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Pending','Pending'));
        options.add(new SelectOption('Approved','Approved'));
        options.add(new SelectOption('Rejected','Rejected'));
        return options;
    }
    
     
        
          
        public String GetKeyPrefix(String ObjId)  
        {  
            // get all objects from the org  
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();  
              
            // to store objects and their prefixes  
            Map<String, String> keyPrefixMap = new Map<String, String>{};  
              
            //get the object prefix in IDs  
            Set<String> keyPrefixSet = gd.keySet();  
              
            // fill up the prefixes map  
            for(String sObj : keyPrefixSet)  
            {  
                Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();  
                String tempName = r.getName();  
                String tempPrefix = r.getKeyPrefix();  
                keyPrefixMap.put(tempPrefix, tempName);  
            }   
            String tPrefix = ObjId;  
            tPrefix = tPrefix.subString(0,3);  
              
            //get the object type now  
            String objectType = keyPrefixMap.get(tPrefix);  
            return objectType;  
        }  
    
    
    public class ApprovalRecord{
        public ProcessInstanceWorkitem ApprovalItem {set;get;}
        public sObject ApprovalRecord {set;get;}
        public string id {set;get;}
        public String ApprNo{set;get;}
        public String InputBy {set;get;}
        public String Remarks {set;get;}
        public String Amount {set;get;}
        public String Status {set;get;}
        public String comments {set;get;}
        public Boolean selected {get; set;}
        public String Delegation {get;set;}
        
        public ApprovalRecord(ProcessInstanceWorkitem item){
            ApprovalItem = item;
            selected = false;           
        }
        
        public ApprovalRecord(){
        
        }
    }
    
    public class ValidationRecord{          
        public String PONo {set;get;}
        public String Comment {set;get;}
        public String Owner {set;get;}
        public string id {set;get;}     
        public Boolean selected {get; set;}         
        
        public ValidationRecord(){
        
        }
    }

}
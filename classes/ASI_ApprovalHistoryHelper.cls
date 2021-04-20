/*
====================================================================
Author:    Steve Wan (Introv Limited)
Usage: Use it to get the Approval History for an object

Step1: First need to initialize the class approvalHistoryHelper and pass the object parameter you would like to retrieve
Example: ASI_ApprovalHistoryHelper appHistHelper = new ASI_ApprovalHistoryHelper ('ASI_MFM_PO__c', 'a9AM00000004CIM' );
   
Step2: Get the retrived list by appHistHelper.appHistorySObjList; 

History
-----------------------------------------------------------------------------
2014-01-14  steve.wan@introv.com    Created
====================================================================
*/
public class ASI_ApprovalHistoryHelper {

    public List<sObject> parentSObjList {get;set;}
    public List<ProcessInstanceHistory> appHistorySObjList{get;set;}
    
    public String sObjObjectStr{ get; set;}
    public String sObjObjectIdStr{ get; set;}
     
    public ASI_ApprovalHistoryHelper (String sObjObjectStr, String sObjObjectIdStr){
    this.sObjObjectStr= sObjObjectStr;
    this.sObjObjectIdStr= sObjObjectIdStr;
  
    System.debug('ahh1' + sObjObjectStr);
    System.debug('ahh2' + sObjObjectIdStr);
    init(); 
    }
     private void init(){
        String queryStr = '';
        
        queryStr = 'Select Name, Id, (Select Id,ProcessInstanceId, StepStatus, Comments, CreatedDate, OriginalActor.Id , OriginalActor.Name, OriginalActor.Title , Actor.Id, Actor.Name, Actor.Title From ProcessSteps order by Id Desc) From '+ sObjObjectStr;
        queryStr += ' where id =\'' +sObjObjectIdStr + '\'';
        System.debug('ahh3' + queryStr);    
        parentSObjList = Database.query(queryStr);
                
        for(sObject sobj: parentSObjList  ){
            appHistorySObjList = sobj.getSObjects('ProcessSteps');
            if (appHistorySObjList  != null)
                for(ProcessInstanceHistory ps: appHistorySObjList )
                {
                    System.debug('ahh4 CreateDate' + ps.CreatedDate +  'Comment:' + ps.Comments + 'Step:' + ps.StepStatus);    
                }
        }
     
         
     }
     
     

}
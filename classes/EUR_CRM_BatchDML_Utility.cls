/**
Utility class to batch
*/
global without sharing   class EUR_CRM_BatchDML_Utility implements Database.Batchable<sObject>{
    global enum Operation {INSERT_RECORDS, UPDATE_RECORDS, UPSERT_RECORDS, DELETE_RECORDS}
    Iterable<sObject> sObjectList;
    String entity; 
    Boolean sendEmail;
    Operation op;
    List<PostDML> postDMLs;
    global EUR_CRM_BatchDML_Utility(Iterable<sObject> sObjectList, String entity, Operation operation, Boolean sendEmail,List<PostDML> postDMLs){
        this.sObjectList = sObjectList == null ? new List<sObject>() : sObjectList;
        this.entity = entity == null ? 'sObject' : entity;
        this.op = operation;
        this.sendEmail = sendEmail == null ? false : sendEmail;
        this.postDMLs = postDMLs;
    }
    global  Iterable<sObject> start(Database.BatchableContext bc) {

        return sObjectList;
    }
    global void execute(Database.BatchableContext BC, List<sObject> l){
        try{
            if(op == Operation.INSERT_RECORDS){
                insert l;
            }else if(op == Operation.UPDATE_RECORDS){
                update l;
            }else if(op == Operation.UPSERT_RECORDS){
                upsert l;
            }else if(op == Operation.DELETE_RECORDS){
                delete l;        
            }
        }catch(DMLException e){
            system.debug('DML Exception: ' + e);
        }
    }

    global void finish(Database.BatchableContext BC){
            system.debug('finish');
            
        AsyncApexJob apexjob = [Select Id,status From AsyncApexJob WHERE Id =:BC.getJobId()];
        if(postDMLs != null && postDMLs.size() > 0){
            Savepoint sp = Database.setSavepoint();
            system.debug('POST DML: ' + postDMLs);
            try{
                for(PostDML pd : postDMLs){
                    system.debug('operation: ' + pd.op + '    ' + Operation.INSERT_RECORDS);
                    if(pd.op == Operation.INSERT_RECORDS){
                        system.debug('operation inserting' + pd.op);
                        insert pd.sObjectList;
                    }else if(pd.op == Operation.UPDATE_RECORDS){
                        update pd.sObjectList;
                    }else if(pd.op == Operation.UPSERT_RECORDS){
                        upsert pd.sObjectList;
                    }else if(pd.op == Operation.DELETE_RECORDS){
                        delete pd.sObjectList;       
                    }
                }
            }catch(Exception e){
                system.debug('Error in POST DML : ' + e);
                Database.rollback( sp );
            }
        }
        postProcess();
        if(sendEmail){
            EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {});
        }
    }
    
    global class PostDML{
        global PostDML( Operation op, List<sObject> s){
            this.sObjectList = s == null ? new List<sObject>() : s;
            this.op = op; 
        
        }
        global Operation op {get;set;}
        global List<sObject> sObjectList {get;set;}
        
    }
    /*
    
    */
    global void postProcess(){
    
    }
    
    /*
    
    Integer MAX_BATCHES = 5;
Integer runningBatchJobs = [
  select count()
  from AsyncApexJob
  where JobType = 'BatchApex'
  and status in ('Queued','Processing','Preparing')
];

if(runningBatchJobs >= MAX_BATCHES) {
  ApexPages.addMessage(new ApexPages.Message(
    ApexPages.Severity.WARNING, 'No resources available.  Please try again later.'
  ));
} else {
  Database.executeBatch(new AutobotBatch());
}
*/
}
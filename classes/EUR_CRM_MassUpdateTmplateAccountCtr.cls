/**

SEPT.22.2014
    - added a filter for Germany.
        if germany use the EUR_CRM_Template_Mass_Update_Accounts with Country code as parameter.
    - 
*/
public with sharing class EUR_CRM_MassUpdateTmplateAccountCtr {
    public boolean isUpdateAvailable {get;set;}{isUpdateAvailable=true;}
    
    
    public String countryCodeFilter {get;set;}
    
    public List<BatchJob> batchJobs;
    public Integer numberOfJobs {get; set;}
    
    private final String BATCH_APEX_CLASS_NAME = 'EUR_CRM_Template_Mass_Update_Accounts';
    private final String BATCH_JOB_TYPE = 'BatchApex';
    private final Set<String> BATCH_OPEN_STATUSES =  new Set<String>{'Queued', 'Processing', 'Preparing'};
    
    private Id defaultTemplateRecordType{get;set;}
        
        public EUR_CRM_MassUpdateTmplateAccountCtr(){

        }
        
        private void initRecordType(){
                for (Schema.RecordTypeInfo rtInfo : EUR_CRM_JB_Template__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                  if(countryCodeFilter != null){
                      defaultTemplateRecordType = rtInfo.getRecordTypeId();
                      break;
                  }else{
                      if (rtInfo.isDefaultRecordTypeMapping()) {
                        System.debug('Flag Template RecordType:'+rtInfo);
                        defaultTemplateRecordType = rtInfo.getRecordTypeId();
                      }
                  }
                }
        }
        
        public PageReference processBatchUpdate(){
                initRecordType();
                PageReference pageRef = null;
                Id batchInstanceId = null;
                System.debug('Flag - Process Batch Update:' + defaultTemplateRecordType);
                if(countryCodeFilter != null && countryCodeFilter == 'DE')     
                    batchInstanceId = Database.executeBatch(new EUR_CRM_Template_Mass_Update_Accounts(countryCodeFilter), 150); 
                else
                    batchInstanceId = Database.executeBatch(new EUR_CRM_Template_Mass_Update_Accounts(defaultTemplateRecordType), 150); 
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Executed EUR Account template batch update, please wait for email of execution result.'));
                
                return pageRef;
        }
        
    public List<BatchJob> getBatchJobs(){
            //Create new list of BatchJobs, a wrapper class that includes the job and percent complete.
            batchJobs = new List<BatchJob>();
        
            //If number of jobs was not defined, default to 20
            if(numberOfJobs== null || numberofJobs <= 0){
                numberofJobs = 20;
            }
        
            map<string,string> bgColorMap=new map<string,string>();
            bgColorMap.put('Queued','#f8f8f8');
            bgColorMap.put('Processing','#f8f8f8');
            bgColorMap.put('Aborted','#551A8B');
            bgColorMap.put('Completed','#f8f8f8');
            bgColorMap.put('Failed','#9E0508');
            bgColorMap.put('Preparing','#f8f8f8');
        
            map<string,string> fgColorMap=new map<string,string>();
            fgColorMap.put('Queued','#F7B64B');
            fgColorMap.put('Processing','#F7B64B');
            fgColorMap.put('Aborted','#B23AEE');
            fgColorMap.put('Completed','#20F472');
            fgColorMap.put('Failed','#FFB6C1');
            fgColorMap.put('Preparing','#F7B64B');
        
            //Query the Batch apex jobs
            for(AsyncApexJob a : [select TotalJobItems, Status, NumberOfErrors, 
                                                MethodName, JobType, JobItemsProcessed, ExtendedStatus, 
                                                Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name 
                                                From AsyncApexJob 
                                                WHERE JobType=:BATCH_JOB_TYPE
                                                AND  ApexClass.Name=:BATCH_APEX_CLASS_NAME
                                                //AND Status IN: BATCH_OPEN_STATUSES
                                                AND CreatedById=: UserInfo.getUserId()
                                                order by CreatedDate DESC
                                                limit :numberOfJobs]){
                                                        
                Double itemsProcessed = a.JobItemsProcessed;
                Double totalItems = a.TotalJobItems;
        
                BatchJob j = new BatchJob();
                j.job = a;
        
                //Determine the pecent complete based on the number of batches complete
                if(totalItems == 0){
                    //A little check here as we don't want to divide by 0.
                    j.percentComplete = 0;
                }else{
                    j.percentComplete = ((itemsProcessed  / totalItems) * 100.0).intValue();
                }
                j.bgStatusColor=bgColorMap.get(a.Status);
                j.fgStatusColor=fgColorMap.get(a.Status);
        
                batchJobs.add(j);
                //Check for open jobs
                if (BATCH_OPEN_STATUSES.contains(a.Status)){
                        isUpdateAvailable = false;
                }
            }

            return batchJobs;
        }
        
        public Class BatchJob{
    public AsyncApexJob job {get; set;}
    public Integer percentComplete {get; set;}
    public string bgStatusColor {get;set;}
    public string fgStatusColor {get;set;}

            public BatchJob(){
                this.job=null;
                this.percentComplete=0;
                bgStatusColor='';
                fgStatusColor='';
            }
        }

}
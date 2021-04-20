public class ASI_MFM_KR_PORC_Controller3 {
    Public datetime LastCalTime {set;get;}
    public String LCT {set;get;}
    public Id BatchId {set;get;}
    public Id BatchId1 {set;get;}    // [SH] 2018-10-15
    public string Msg {set;get;}
    Public Boolean RunningJob {set;get;}
    Public String status {set;get;}
    
    public ASI_MFM_KR_PORC_Controller3(){
        init();
    }
    public void init(){
        RunningJob=true;
        LastCalTime=datetime.valueOf(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_KR_PORC_Data_Last_Cal_Time__c) ;
        LCT=LastCalTime.format();
        status='';
    }
    public string[] statusMsgs {
        get {
            string s = Msg==null? '': Msg;
            if(BatchId!=null) {
                RunningJob=false;
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = aajs[0].Status;
                    status = aajs[0].Status;
                    if(aajs[0].Status=='Queued' && !Test.isRunningTest()){
                        s='Waiting, there are other jobs are running now.....';
                    }else if(aajs[0].Status=='Holding' && !Test.isRunningTest() ){
                      s='Waiting,the job is running now....';
                    }else if(aajs[0].Status=='Completed' || Test.isRunningTest() ){
                         LastCalTime=datetime.valueOf(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_KR_PORC_Data_Last_Cal_Time__c) ;
                         LCT=LastCalTime.format();
                         string link=System.URL.getSalesforceBaseURL().toExternalForm()+'/apex/ASI_MFM_KR_POReceiptClosing_Page2';
                        s='The Calculation Job has completed! Please refer: <a href='+link+'  style="font-weight: bold;font-size: 150%;color:red;"  >Link</a>';
                        if(aajs[0].ExtendedStatus!=null){
                         s+=aajs[0].ExtendedStatus;   
                        }
                    }else{
                         s = aajs[0].Status;
                    }
                   
                }
            }
            return s.split('\n');
        }
    }
    
    
    public void RunJob(){
        BatchId= Database.executeBatch(new ASI_MFM_KR_PORCProcess(),200);
        BatchId1= Database.executeBatch(new ASI_MFM_KR_PORCProcess_Validate(),200);
         RunningJob=false;
    }
    
}
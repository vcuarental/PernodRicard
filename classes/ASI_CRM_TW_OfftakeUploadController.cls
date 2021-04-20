/*********************************************************************************
* Project : TW CRM Offtake upload system
* Test class : ASI_CRM_TW_Function_Test
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 08/12/2020       PRA COE               Created

*********************************************************************************/

public class ASI_CRM_TW_OfftakeUploadController {
    public Id BatchId {get;set;}
    
    public String channelstr {get;set;}{channelstr=null;}
    
    public string msgEmail {set;get;}{msgEmail ='Email Notification will be sent when upload process is completed';}
    public string msg {set;get;}
    public Id LogId {get;set;}
    public Blob contentFile {set;get;}
    public string nameFile {set;get;}
    public integer fileSize {set;get;}
    public String contentType { get; set; }
    
    public void uploadCSVByBatch(){
        
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        system.debug('-----current page name----'+pageName);
        system.debug('channelstr : '+channelstr);

        if( pageName=='ASI_CRM_TW_Offtake_UploadPage'){
            channelstr='Subwholesaler';
        }
        
        if(fileSize >= 10485760){ // 10 Megabytes (MB)=10,485,760 Bytes (B)
            msg = 'Error: File too large';
        }else if(namefile.toLowerCase().right(3)!='csv'){
            msg = 'Error: Please select csv file only!';
        }else{
            // start working
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c(ASI_MFM_Error_Message__c='',ASI_MFM_Configuration__c = channelstr,ASI_CRM_File_Name__c=namefile,ASI_CRM_Remark__c=contentType,
                                                                                  ASI_CRM_Result__c=' ',ASI_MFM_Name__c='ASI_CRM_TW_Offtake_UploadPage');
            insert uploadLog;
            LogId = uploadLog.Id;
            Attachment att = new Attachment(ParentId = uploadLog.Id, name = namefile, body=contentFile, ContentType ='text/plain; charset=ks_c_5601-1987'); //ks_c_5601-1987
            insert att;
            BatchId = Database.executeBatch(new ASI_CRM_TW_OfftakeUploadBatch(contentFile ,uploadLog.Id, channelstr,pageName) ,200 );
            
        }
    }
    
    public string[] StatusMsgs {
        get {
            string s = msg==null? '': msg; //string s = ''; //string s = msg==null? '': msg;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus,JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = aajs[0].Status;
                    if((aajs[0].Status=='Completed' && LogId!=null)  || Test.isRunningTest() ) {
                        if(aajs[0].ExtendedStatus!=null && aajs[0].ExtendedStatus=='First error: Regex too complicated'){
                            s='Upload Failed. The file is too large, please cut the file sizes down';
                        }else{
                            ASI_MFM_Mass_Upload_Log__c UploadLog = [SELECT Id, Name,ASI_MFM_Status__c,ASI_CRM_Number_of_Failed_Records__c,ASI_MFM_Error_Message__c,ASI_CRM_Result__c FROM ASI_MFM_Mass_Upload_Log__c WHERE ID =:LogId];
                            if(UploadLog!=null){
                                if(UploadLog.ASI_CRM_Number_of_Failed_Records__c>0){// failed;
                                    s='Status' + UploadLog.ASI_CRM_Result__c +'<br/>';// +UploadLog.ASI_MFM_Error_Message__c
                                    /*if(UploadLog.ASI_MFM_Error_Message__c.length()>10){
                                        s+=UploadLog.ASI_MFM_Error_Message__c;
                                    }*/
                                }else{
                                    s=UploadLog.ASI_CRM_Result__c;
                                    //s = UploadLog.ASI_MFM_Status__c + ' Log Id:'+UploadLog.Name; 
                                }
                                
                            }   
                        }
                        
                    }else if(aajs[0].Status=='Failed' && aajs[0].ExtendedStatus!=null){
                        s = aajs[0].Status+'<br/>'+aajs[0].ExtendedStatus;
                    }
                    /*else if(aajs[0].Status=='Processing' && aajs[0].TotalJobItems>0){
                        decimal progress = ((aajs[0].JobItemsProcessed/aajs[0].TotalJobItems)*100);
                        progress=progress.setScale(2);
                        s += ':'+string.valueof(progress)+'%';
                    }*/
                }
            }
            if(Test.isRunningTest()){
                return null;
            }else{
                return s.split('<br/>');
            }
            
            
        }
    }
    
    public ASI_CRM_TW_OfftakeUploadController(){
        
    }
    
    
}
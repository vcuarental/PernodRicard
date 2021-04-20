global class ASI_MFM_GenPOPDF_Batch implements Database.AllowsCallouts, Database.Batchable<sObject>{
/*********************************
 * Created by: Linus @introv
 * Created Date: 2018-03-13
 * Obejctive: Batch job to generate PO PDF as atachment
 * Module: MFM HK, MFM TR
*********************************/        
    global string queryFieldList = 'Select id, name from ASI_MFM_PO__c ';
   
    global string fiscal;
    global string PORT;

    global ASI_MFM_GenPOPDF_Batch(String input_fiscal, String input_module){        
        fiscal = input_fiscal;
        PORT = input_module == 'HK'? 'HK':'TR';

        system.debug('Start Batch Job');                        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String queryStr;
        String whereStam = Test.isRunningTest() == true? '' :
                                                         'where ASI_MFM_Status__c = \'Final\' and ASI_MFM_Fiscal_Year__c =: fiscal and recordtype.name like \'%' + PORT + '%\'';
        queryStr = queryFieldList + whereStam;

        system.debug('queryStr: ' + queryStr);
        return Database.getQueryLocator(queryStr);
    } 
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        if(Scope == NULL){
            return;
        }
        
        List<ASI_MFM_PO__c> polist = new List<ASI_MFM_PO__c>();
        List<Attachment> PDFlist = new List<Attachment>();
        
        
        for(SObject s: Scope){
            ASI_MFM_PO__c po = (ASI_MFM_PO__c)s;
            POlist.add(po);
        }
        
        system.debug('POlist Size: ' + POlist.size());
        
        for(ASI_MFM_PO__c po: POlist){
        
            PageReference pdf = PORT == 'HK' ? Page.ASI_MFM_HK_PO_PDF_Page: Page.ASI_MFM_TR_PO_PDF_Page;        
            pdf.getParameters().put('id', po.Id);
            pdf.setRedirect(true);
            
            Blob body;
            String debugText;
            try{
                body = pdf.getContent();            
            }catch (VisualforceException e){
                body = Blob.valueOf('Error');   
                System.debug('Error: ' + e.getMessage());                                         
            }
            
            Attachment att = new Attachment();
            att.Name = po.name + '_' + System.today().year() + '_' + System.today().month() + '_' + System.today().day() + '.pdf';
            att.ParentId = po.id;
            att.Body = body;
            
            PDFlist.add(att);
        }
        
        Savepoint sp = Database.setSavepoint();
        
        if(!Test.isRunningTest())
            insert PDFlist;
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Finish Batch Generation');
    }
}
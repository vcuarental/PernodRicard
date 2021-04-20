global with sharing class RIC_ImportProject_FromProject_Controller {  
    global list <Milestone1_Project__c> projs {get;set;}  
    global string searchstring {get;set;}
    global list <Milestone1_Project__c> selectedproj {get;set;} 
    global string recstring {get;set;}
    global Milestone1_Project__c project {get; set;}
    global String searchRecordType {get;set;}
    global List<SelectOption> projOptions {get;set;}
    global List<Milestone1_Project__c> projDetails {get;set;}
    global String currentRecordId {get;set;}
    global String targetProjectId {get;set;}
    global Milestone1_Project__c rec {get;set;}
    global String errorMessage {get; private set;}
    global Document doc{get;set;}
    private final String ERROR_STRING_FILE_TOO_LONG = 
        system.label.Milestone1_ProjectIsTooLarge + Milestone1_Import_Project_Controller.MAX_FILE_SIZE + 
        system.label.Milestone1_CurrentExport; 
    global Document docDel{get;set;} 
    
    
    global RIC_ImportProject_FromProject_Controller(ApexPages.StandardController controller) {  
        targetProjectId  = ApexPages.CurrentPage().getparameters().get('id');
    }  
    
    global void search(){  
        projOptions = new List<SelectOption>();
        
        string searchquery='select name, id, Status__c, Description__c, Kickoff__c from Milestone1_Project__c where name like \'%'+searchstring+'%\'  Limit 20';  
        
        projs= Database.query(searchquery);  
        
        for (Milestone1_Project__c proj : projs)
        {
            projOptions.add(new SelectOption(proj.Id,proj.Name));
            
        }    
    }  
    
    public PageReference choose() {
        return null;
    }
    
    public void clear(){  
        projs.clear();  
    }  
    
    public PageReference exportImport(){
        
        errorMessage = null;
        
        rec = [SELECT Id, Name, Description__c FROM Milestone1_Project__c WHERE Id = :currentRecordId];
        
        createExportXML();
        system.debug(rec.Id);
        
        String xml = doc.body.toString();
        
        RIC_XML_Import_Utility importUtility = new RIC_XML_Import_Utility();
        
        Milestone1_Project__c project2 = [Select Id, RIC_MAD_Date__c, RIC_MAD_Date_Real__c, RIC_MAD_Date_Approved__c, RIC_Duree_projet__c, RIC_Date_debut_Planning__c,
                                          RIC_Request_Date__c
                                          from Milestone1_Project__c  
                                          where id = :targetProjectId];
        
        project = importUtility.importProject(xml,project2);
        
        deleteFromDocument(doc); 
        
        return new ApexPages.StandardController(project).view();
        
    }
    
    global void createExportXML(){
        
        Milestone1_XML_Export_Utility xmlUtil = new Milestone1_XML_Export_Utility();
        String xmlString = xmlUtil.buildProjectXmlString(rec.Id);
        
        if( xmlString.length() > Milestone1_Import_Project_Controller.MAX_FILE_SIZE ){
            errorMessage = ERROR_STRING_FILE_TOO_LONG.replace('$1', xmlString.length().format());
        }
        else{
            String exportName = rec.Name;
            String description = rec.Description__c;
            if (description != null && description.length() > 250) {
                description=description.substring(0,250);
            }
            doc = saveToDocument(exportName,xmlString,description); 
        }
    }
    
    global Document saveToDocument(String name, String xml, String description) {
        Document d = new Document();
        d.body = Blob.valueOf(xml);
        d.ContentType = 'text/xml';
        d.name = 'Export - ' + name + ' - ' + System.now() + '.xml';
        d.Description = description;
        d.FolderId = UserInfo.getUserId();
        insert d;
        return d;
    }
    
    global void deleteFromDocument(Document doc2){
        delete doc2 ;
    }
    
}
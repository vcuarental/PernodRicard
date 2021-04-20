public with sharing class ASI_LUX_TW_UploadImageController
{
    public Account acc {get;set;}
    public Contact ctnt {get;set;}
    private Set<String> ALLOWED_EXTENSION_SET {get;set;}
    
    public Id recId  
    {    get;set;    }  
      
    public ASI_LUX_TW_UploadImageController(ApexPages.StandardController ctlr)  
    {
       this.ALLOWED_EXTENSION_SET = new Set<String>{'png', 'jpeg', 'jpg', 'gif', 'bmp'};
       recId = ctlr.getRecord().Id;
       this.acc = [SELECT ID, Name, ASI_LUX_Sys_Profile_Picture_URL__pc FROM Account WHERE ID = : recId ]; 
       this.ctnt = [SELECT ID, Name,  ASI_LUX_Sys_Profile_Picture_URL__c, ASI_LUX_Profile_Picture__c FROM Contact WHERE accountID = :recId];   
    }  
      
    public string fileName   
    {    get;set;    }  
      
    public Blob fileBody   
    {    get;set;    }  
    
    public PageReference UploadFile()  
    {  
        PageReference pr;  
        if(fileBody != null && fileName != null && this.acc != null)  
        {
            String[] splitName = fileName.split('\\.');
            Integer splitSize = splitName.size();
            String fileEXT = 'null';
            if (splitSize != 0)
                fileEXT = splitName[splitSize-1];

            if (!ALLOWED_EXTENSION_SET.contains(fileEXT))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, fileEXT + ' is not a valid Image File extension.');//Same old drama 
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            if (this.acc.ASI_LUX_Sys_Profile_Picture_URL__pc == null)
            {
                return insertNewAttachments();
            }
            else 
            {
                String attachmentURL = this.acc.ASI_LUX_Sys_Profile_Picture_URL__pc;
                String[] attachmentURLSplit = attachmentURL.split('file=');
                ID URLID = attachmentURLSplit[1];
                List<Attachment> myAttachments = [SELECT ID, name, body, ParentID FROM Attachment WHERE ID = :URLID];
                Attachment MyAttachment; 
                if (myAttachments.size() == 0)
                    return insertNewAttachments();
                else
                    myAttachment = myAttachments.get(0);
                    
                myAttachment.Body = fileBody;  
                myAttachment.Name = fileName;  
                //myAttachment.ParentId = recId;  
                update myAttachment;
                this.ctnt.ASI_LUX_Profile_Picture__c = '<img src="'+this.ctnt.ASI_LUX_Sys_Profile_Picture_URL__c+'" alt="" width="200">';
                update ctnt;
                pr = new PageReference('/' + recId);  
                pr.setRedirect(true);  
                return pr;
            }  
        }  
        return null;  
    }
    
    public PageReference insertNewAttachments()
    {
        PageReference pr;  
        Attachment myAttachment  = new Attachment();  
        myAttachment.Body = fileBody;  
        myAttachment.Name = fileName;  
        myAttachment.ParentId = recId;  
        insert myAttachment;
        PageReference dlURL = new PageReference('/servlet/servlet.FileDownload?file=' + myAttachment.Id);
        this.ctnt.ASI_LUX_Sys_Profile_Picture_URL__c = dlURL.getUrl();
        this.ctnt.ASI_LUX_Profile_Picture__c = '<img src="'+dlURL.getUrl()+'" alt="" width="200">';
        update ctnt;
        pr = new PageReference('/' + recId);  
        pr.setRedirect(true);  
        return pr;
    }
    
    public PageReference cancel(){
        PageReference thePage = new PageReference( '/'+ recId);
        thePage.setRedirect( true );
        return thePage;
    }     
}
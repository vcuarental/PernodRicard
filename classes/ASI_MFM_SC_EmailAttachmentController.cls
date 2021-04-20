public with sharing class ASI_MFM_SC_EmailAttachmentController {

public String currentHeaderId {get;set;}
public Boolean hasListValue {get;set;}
 
public ASI_MFM_SC_EmailAttachmentController (){      }   
 
    public List<Attachment> getFileAttachments(){
       List<Attachment> fileAttachments= new List<Attachment>();
       if (currentHeaderId != null)   {
            
        fileAttachments= [Select id, Name from Attachment where ParentId = :currentHeaderId order by id];         
        
        if(fileAttachments.size()>0)    
            hasListValue = true;
                            
       }
       return fileAttachments;   
    }
      
}
public with sharing class ASI_MFM_CAP_EmailAttachmentController {

public String currentHeaderId {get;set;}
//private List<ASI_MFM_CAP_Attachment__Feed> attachments;
//private Map<String,List<ASI_MFM_CAP_Attachment__c>> fileAttachments;
//private Map<String,List<ASI_eForm_ITPSR_Attachment__c>> fileAttachmentsITPSR;
private Map<String,List<ASI_MFM_CAP_Plan_Attachment__c>> fileAttachmentsPlanCAP;
private List<String> categoriesFiltered;
public Boolean hasListValue {get;set;}
 
public ASI_MFM_CAP_EmailAttachmentController ()
{
                
}   
 
public List<String> getCategories()
 {
     if (categoriesFiltered == null)
     {
      Schema.DescribeFieldResult fieldResult = ASI_MFM_CAP_Plan_Attachment__c.ASI_MFM_CAP_Category__c.getDescribe();
      List<Schema.PicklistEntry> categories = fieldResult.getPicklistValues();
      categoriesFiltered = new List<String>();
      
      Map<String,List<ASI_MFM_CAP_Plan_Attachment__c>> fileAttachmentsPlanCAP= getFileAttachments();
      
      for (Schema.PicklistEntry pickListEntry :categories)
      {
          if (fileAttachmentsPlanCAP.containsKey(pickListEntry.value))
          {
              categoriesFiltered.add(pickListEntry.value);
          }
      }
     } 
     return categoriesFiltered;
 }
 
 public Map<String,List<ASI_MFM_CAP_Plan_Attachment__c>> getFileAttachments()
 {
   if (currentHeaderId != null && fileAttachmentsPlanCAP == null)
   {
    
    fileAttachmentsPlanCAP = new Map<String,List<ASI_MFM_CAP_Plan_Attachment__c>>();
  
    List<ASI_MFM_CAP_Plan_Attachment__c> attachments = [Select id, 
    ASI_MFM_CAP_Category__c,ASI_MFM_CAP_File_Name__c,
    ASI_MFM_Plan__c,
    ASI_MFM_CAP_FileId__c
    from ASI_MFM_CAP_Plan_Attachment__c
    where ASI_MFM_CAP_Attach_in_Approval_Email__c = true 
    and ASI_MFM_Plan__c = :currentHeaderId
    order by ASI_MFM_CAP_Category__c, ASI_MFM_CAP_File_Name__c   
    ];         
    
    for (ASI_MFM_CAP_Plan_Attachment__c attachment : attachments )
    {
        if (fileAttachmentsPlanCAP.containsKey(attachment.ASI_MFM_CAP_Category__c))
        {
            fileAttachmentsPlanCAP.get(attachment.ASI_MFM_CAP_Category__c).add(attachment);        
        } else {
            String category = attachment.ASI_MFM_CAP_Category__c;
            List<ASI_MFM_CAP_Plan_Attachment__c> innerAttachments = new List<ASI_MFM_CAP_Plan_Attachment__c>();
            innerAttachments.add(attachment);        
            fileAttachmentsPlanCAP.put(category,innerAttachments);
        }    
        hasListValue = true;
    }
                        
   }
    return fileAttachmentsPlanCAP;   
 }
      
}
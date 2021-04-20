public with sharing class ASI_eForm_EmailAttachmentController {

public String currentHeaderId {get;set;}
//private List<ASI_eForm_Attachment__Feed> attachments;
//private Map<String,List<ASI_eForm_Attachment__c>> fileAttachments;
private Map<String,List<ASI_eForm_ITCRF_Attachment__c>> fileAttachmentsITCRF;
private Map<String,List<ASI_eForm_ITPSR_Attachment__c>> fileAttachmentsITPSR;
private List<String> categoriesFiltered;
public Boolean hasListValue {get;set;}
 
public ASI_eForm_EmailAttachmentController ()
{
                
}   
 
public List<String> getCategories()
 {
     if (categoriesFiltered == null)
     {
      Schema.DescribeFieldResult fieldResult = ASI_eForm_ITPSR_Attachment__c.ASI_eForm_Category__c.getDescribe();
      List<Schema.PicklistEntry> categories = fieldResult.getPicklistValues();
      categoriesFiltered = new List<String>();
      
      Map<String,List<ASI_eForm_ITPSR_Attachment__c>> fileAttachmentsITPSR = getFileAttachments();
      
      for (Schema.PicklistEntry pickListEntry :categories)
      {
          if (fileAttachmentsITPSR.containsKey(pickListEntry.value))
          {
              categoriesFiltered.add(pickListEntry.value);
          }
      }
     } 
     return categoriesFiltered;
 }
 
 public List<String> getCategoriesITCR()
 {
     if (categoriesFiltered == null)
     {
      Schema.DescribeFieldResult fieldResult = ASI_eForm_ITCRF_Attachment__c.ASI_eForm_Category__c.getDescribe();
      List<Schema.PicklistEntry> categories = fieldResult.getPicklistValues();
      categoriesFiltered = new List<String>();
      
      Map<String,List<ASI_eForm_ITCRF_Attachment__c>> fileAttachmentsITCRF = getITCRFileAttachments();
      
      for (Schema.PicklistEntry pickListEntry :categories)
      {
          if (fileAttachmentsITCRF.containsKey(pickListEntry.value))
          {
              categoriesFiltered.add(pickListEntry.value);
          }
      }
     } 
     return categoriesFiltered;
 }
 
 public Map<String,List<ASI_eForm_ITPSR_Attachment__c>> getFileAttachments()
 {
   if (currentHeaderId != null && fileAttachmentsITPSR == null)
   {
    
    fileAttachmentsITPSR = new Map<String,List<ASI_eForm_ITPSR_Attachment__c>>();
  
    List<ASI_eForm_ITPSR_Attachment__c> attachments = [Select id, 
    ASI_eForm_Category__c,ASI_eForm_File_Name__c,
    ASI_eForm_IT_Procurement_Service_Request__c,
    ASI_eForm_FileId__c
    from ASI_eForm_ITPSR_Attachment__c 
    where ASI_eForm_Attach_in_Approval_Email__c = true 
    and ASI_eForm_IT_Procurement_Service_Request__c = :currentHeaderId
    order by ASI_eForm_Category__c, ASI_eForm_File_Name__c   
    ];         
    
    for (ASI_eForm_ITPSR_Attachment__c attachment : attachments )
    {
        if (fileAttachmentsITPSR.containsKey(attachment.ASI_eForm_Category__c))
        {
            fileAttachmentsITPSR.get(attachment.ASI_eForm_Category__c).add(attachment);        
        } else {
            String category = attachment.ASI_eForm_Category__c;
            List<ASI_eForm_ITPSR_Attachment__c> innerAttachments = new List<ASI_eForm_ITPSR_Attachment__c>();
            innerAttachments.add(attachment);        
            fileAttachmentsITPSR.put(category,innerAttachments);
        }    
        hasListValue = true;
    }
                        
   }
    return fileAttachmentsITPSR;   
 }
 
 public Map<String,List<ASI_eForm_ITCRF_Attachment__c>> getITCRFileAttachments()
 {
   if (currentHeaderId != null && fileAttachmentsITCRF == null)
   {
    
    fileAttachmentsITCRF = new Map<String,List<ASI_eForm_ITCRF_Attachment__c>>();
  
    List<ASI_eForm_ITCRF_Attachment__c> attachments = [Select id, 
    ASI_eForm_Category__c,ASI_eForm_File_Name__c,
    ASI_eForm_IT_Change_Request__c,
    ASI_eForm_FileId__c
    from ASI_eForm_ITCRF_Attachment__c 
    where ASI_eForm_Attach_in_Approval_Email__c = true 
    and ASI_eForm_IT_Change_Request__c = :currentHeaderId
    order by ASI_eForm_Category__c, ASI_eForm_File_Name__c   
    ];         
    
    for (ASI_eForm_ITCRF_Attachment__c attachment : attachments )
    {
        if (fileAttachmentsITCRF.containsKey(attachment.ASI_eForm_Category__c))
        {
            fileAttachmentsITCRF.get(attachment.ASI_eForm_Category__c).add(attachment);        
        } else {
            String category = attachment.ASI_eForm_Category__c;
            List<ASI_eForm_ITCRF_Attachment__c> innerAttachments = new List<ASI_eForm_ITCRF_Attachment__c>();
            innerAttachments.add(attachment);        
            fileAttachmentsITCRF.put(category,innerAttachments);
        }
        hasListValue = true;    
    }
                        
   }
    return fileAttachmentsITCRF;   
 }
      
}
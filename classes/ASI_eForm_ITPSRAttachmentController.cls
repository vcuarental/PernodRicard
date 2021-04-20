public with sharing class ASI_eForm_ITPSRAttachmentController {

 public String currentHeaderId {get;set;}
 private ASI_TnE_ClaimHeader__c relatedTo;
 private ASI_eForm_IT_Procurement_Service_Request__c itpsrHeader;
 //private List<ASI_eForm_Attachment__Feed> attachments;
 private List<Attachment> standardAttachments;
 private Map<String,List<ASI_eForm_ITPSR_Attachment__c>> fileAttachments;
 private List<String> categoriesFiltered;
 
 public ASI_eForm_ITPSRAttachmentController ()
 {
                
 }   
 
 public List<String> getCategories()
 {
     if (categoriesFiltered == null)
     {
      Schema.DescribeFieldResult fieldResult = ASI_eForm_ITPSR_Attachment__c.ASI_eForm_Category__c.getDescribe();
      List<Schema.PicklistEntry> categories = fieldResult.getPicklistValues();
      categoriesFiltered = new List<String>();
      
      Map<String,List<ASI_eForm_ITPSR_Attachment__c>> fileAttachments = getFileAttachments();
      
      for (Schema.PicklistEntry pickListEntry :categories)
      {
          if (fileAttachments.containsKey(pickListEntry.value))
          {
              categoriesFiltered.add(pickListEntry.value);
          }
      }
     } 
     return categoriesFiltered;
 }
 
 public Map<String,List<ASI_eForm_ITPSR_Attachment__c>> getFileAttachments()
 {
   if (currentHeaderId != null && fileAttachments == null)
   {
    
    fileAttachments = new Map<String,List<ASI_eForm_ITPSR_Attachment__c>>();
  
    List<ASI_eForm_ITPSR_Attachment__c> attachments = [Select id, 
    ASI_eForm_Category__c,ASI_eForm_File_Name__c,
    ASI_eForm_IT_Procurement_Service_Request__c
    from ASI_eForm_ITPSR_Attachment__c 
    where ASI_eForm_Attach_in_Approval_Email__c = true 
    and ASI_eForm_IT_Procurement_Service_Request__c = :currentHeaderId
    order by ASI_eForm_Category__c, ASI_eForm_File_Name__c   
    ];         
    
    for (ASI_eForm_ITPSR_Attachment__c attachment : attachments )
    {
        if (fileAttachments.containsKey(attachment.ASI_eForm_Category__c))
        {
            fileAttachments.get(attachment.ASI_eForm_Category__c).add(attachment);        
        } else {
            String category = attachment.ASI_eForm_Category__c;
            List<ASI_eForm_ITPSR_Attachment__c> innerAttachments = new List<ASI_eForm_ITPSR_Attachment__c>();
            innerAttachments.add(attachment);        
            fileAttachments.put(category,innerAttachments);
        }    
    }
                        
   }
    return fileAttachments;   
 }
 
 
 public List<Attachment> getStandardAttachments()
 {
   if (currentHeaderId != null && standardAttachments == null)
   {
      standardAttachments = [Select Id,Name,ownerid,Description 
         from Attachment Where ParentID =:currentHeaderId];           
   }
    return standardAttachments;   
 }
 
 
 

     
}
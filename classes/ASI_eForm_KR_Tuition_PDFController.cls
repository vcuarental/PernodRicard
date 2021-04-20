public class ASI_eForm_KR_Tuition_PDFController {
          
    private ASI_eForm_Tuition__c header;
    private List<ASI_eForm_Tuition_Detail__c> details {get;set;}  
    public String currentHeaderID {get; set;}
    public ASI_eForm_KR_Tuition_PDFController() {}
    
    
    public ASI_eForm_Tuition__c getHeader()
    { if (header == null && currentHeaderID != null)
    { header = [Select
                Name,
                ASI_eForm_Beneficiary__c,
                ASI_eForm_Currency__c,
                ASI_eForm_Requester_Name__c,
                ASI_eForm_Requester_Company__c,
                ASI_eForm_Requester_Department__c,
                ASI_eForm_Requester_Record__r.Name,
                ASI_eForm_Requester_Title__c,
                ASI_eForm_Status__c,
                ASI_eForm_Total_Fee__c
                
          from ASI_eForm_Tuition__c
          where Id = :currentHeaderID];
     }
    return header;
    }       
       
     public List<ASI_eForm_Tuition_Detail__c> getDetails()
     {  
           if (details == null) {
                details = [SELECT 
                           ASI_eForm_Education_Level__c,
                           ASI_eForm_Fee__c,
                           ASI_eForm_Fee_Type__c,
                           ASI_eForm_Grade__c,
                           ASI_eForm_Name_of_Child__c,
                           ASI_eForm_School_Name__c,
                           ASI_eForm_Tuition__c,
                           Name,
                           ASI_eForm_Date_of_Birth__c                                
                    FROM ASI_eForm_Tuition_Detail__c
                    WHERE ASI_eForm_Tuition__c = :currentHeaderId 
                ];   
           }  
            return details;
        }
    
    
        public ASI_eForm_KR_Tuition_PDFController (ApexPages.StandardController stdController){
        }
}
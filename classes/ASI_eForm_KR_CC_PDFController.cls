public with sharing class ASI_eForm_KR_CC_PDFController {
    private ASI_eForm_CC_Request__c header;
    public String currentHeaderID {get; set;}
    public ASI_eForm_KR_CC_PDFController() {}
    public ASI_eForm_CC_Request__c getHeader() 
    { if (header == null && currentHeaderID != null)
    { header = [Select 
                Name,
                
                ASI_eForm_Requester_Name__c,
                ASI_eForm_Beneficiary__c,
                ASI_eForm_Rice_Wreath__c,
                ASI_eForm_Currency__c,
                ASI_eForm_Time__c,
                ASI_eForm_Replacement__c,
                ASI_eForm_Summary_Date_From__c,
                ASI_eForm_Summary_Date_To__c,
                ASI_eForm_Leave_Sub_Type__c,
                ASI_eForm_Leave_Type__c,
                ASI_eForm_Mobile_Phone__c,
                ASI_eForm_Days__c,
                ASI_eForm_Payment__c,
                ASI_eForm_Place__c,
                ASI_eForm_Requester_Company__c,
                ASI_eForm_Requester_Department__c,
                ASI_eForm_Requester_Record__r.Name,
                ASI_eForm_Requester_Title__c,
                ASI_eForm_Status__c,
                ASI_eForm_Amount__c,
                ASI_eForm_Support_Type__c,
                ASI_eForm_Telephone_No__c
                from ASI_eForm_CC_Request__c
                where Id = :currentHeaderID
                ];
    }
        return header;
    }
     public ASI_eForm_KR_CC_PDFController (ApexPages.StandardController stdController){}
}
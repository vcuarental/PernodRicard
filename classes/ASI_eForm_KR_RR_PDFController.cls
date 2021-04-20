public with sharing class ASI_eForm_KR_RR_PDFController {
         
    private ASI_eForm_Recruitment__c header;
    public String currentHeaderID {get; set;}
    public ASI_eForm_KR_RR_PDFController() {}
    public ASI_eForm_Recruitment__c getHeader()
    { 
        if (header == null && currentHeaderID != null)
    	{ header = [Select 
                Name,
                Owner.Name,
                ASI_eForm_Employee_Group__c,
                ASI_eForm_Job_Type__c,
                ASI_eForm_Employment_Status__c,
                ASI_eForm_School_Level__c,
                ASI_eForm_Major__c,
                ASI_eForm_Expected_Start_Date__c,
                ASI_eForm_Budget_Status__c,
                ASI_eForm_Budget_Status_reason__c,
                ASI_eForm_Report_Line__c,
                ASI_eForm_Report_Line__r.Name,
                ASI_eForm_Key_Competencies__c,
                ASI_eForm_Other_Reason__c,
                ASI_eForm_Period_of_Employment_From__c,
                ASI_eForm_Period_of_Employment_To__c,
                ASI_eForm_new_Position__c,
                ASI_eForm_Reason__c,
                ASI_eForm_Requester_Company__c,
                ASI_eform_Requester_Department__c,
                ASI_eForm_Requester_Record__r.Name,
                ASI_eform_Requester_Name__c,
                ASI_eform_Requester_Title__c,
                ASI_eForm_Requisition_Type__c,
                ASI_eForm_Status__c,
                ASI_eForm_Level__c,
                ASI_eForm_Perferred__c,
                ASI_eForm_YOS__c,
                ASI_eForm_Work_Hour__c,
                ASI_eForm_Work_Period_From__c,
                ASI_eForm_Work_Period_To__c,
                ASI_eForm_Dept_new__c,
                ASI_eForm_Department__c
          from ASI_eForm_Recruitment__c 
          where Id = :currentHeaderID];
     	}
   	 	return header;
    }
    public ASI_eForm_KR_RR_PDFController (ApexPages.StandardController stdController){}
}
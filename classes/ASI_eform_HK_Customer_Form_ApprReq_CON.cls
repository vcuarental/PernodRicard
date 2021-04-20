public class ASI_eform_HK_Customer_Form_ApprReq_CON {
public ASI_eForm_Customer_Form__c  header{get;set;}
    public Id headerId {get;set;} //current header Id
    public ASI_eForm_Customer_Form__c npl{get;set;} //current header
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }                   

	public boolean init()
    {
        npl = [SELECT Id, Name
               ,ASI_eForm_Customer_Name__c
               ,ASI_eForm_Contact_Person_1__c
               ,ASI_eForm_Default_Email__c
               ,CreatedDate
               ,ASI_eForm_Exceed_Credit_Limit__c
               ,ASI_eForm_Exceed_Credit_Period__c
               ,ASI_eForm_Exceed_Default_Credit_Hold__c
               ,ASI_eForm_Other_Remarks__c
               ,ASI_eForm_Original_Customer_Form__c
               ,ASI_eForm_Original_Customer_Form__r.Name
               ,ASI_eForm_Original_Customer_Form__r.ASI_eForm_Default_Email__c
               ,ASI_eForm_Original_Customer_Form__r.CreatedDate
               ,ASI_eForm_Original_Customer_Form__r.ASI_eForm_Exceed_Credit_Limit__c
               ,ASI_eForm_Original_Customer_Form__r.ASI_eForm_Exceed_Credit_Period__c
               ,ASI_eForm_Original_Customer_Form__r.ASI_eForm_Exceed_Default_Credit_Hold__c
               ,ASI_eForm_Original_Customer_Form__r.ASI_eForm_Other_Remarks__c
               ,ASI_eForm_Original_Customer_Form__r.ASI_eForm_Contact_Person_1__c
               ,ASI_eForm_Parent_Customer_Form__c
               ,ASI_eForm_Parent_Customer_Form__r.Name
               From ASI_eForm_Customer_Form__c
               WHERE Id =: headerId 
               LIMIT 1];
        
        return true;        
    }//end method: init

}
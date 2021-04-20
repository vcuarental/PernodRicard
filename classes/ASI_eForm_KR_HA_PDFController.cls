public with sharing class ASI_eForm_KR_HA_PDFController {
    
    private ASI_eForm_Home_Appliance__c Header;
    private List<ASI_eForm_HA_Detail__c> Details{get;set;}
    public String currentHeaderID {get; set;}
    public ASI_eForm_KR_HA_PDFController() {}
    public ASI_eForm_Home_Appliance__c getHeader(){
        if(header == null && currentHeaderID != null){
            header=[select
                    Name,
                    ASI_eForm_Currency__c,
                    ASI_eForm_Reason_for_Request__c,
                    ASI_eForm_Company_Subsidy_Price__c,
                    ASI_eForm_Requester_Company__c,
                    ASI_eForm_Requester_Department__c,
                    ASI_eForm_Requester_Record__r.Name,
                    ASI_eForm_Requester_Name__c,
                    ASI_eForm_Requester_Title__c,
                    ASI_eForm_Status__c,
                    ASI_eForm_Total_Price__c
                    from ASI_eForm_Home_Appliance__c
                    where ID = :currentHeaderID
                 ];
        }
        return Header;
               }       
    public list<ASI_eForm_HA_Detail__c> getDetails(){
         if (details == null) {
                details = [SELECT 
                          ASI_eForm_Home_Appliance__c,
                           ASI_eForm_Item_Name__c,
                           ASI_eForm_Model_No__c,
                           ASI_eForm_Price__c,
                           Name
                           from ASI_eForm_HA_Detail__c
                           where ASI_eForm_Home_Appliance__c = :currentHeaderID
                          ];
             }
        return Details;
    }
        public ASI_eForm_KR_HA_PDFController (ApexPages.StandardController stdController){
        }
}
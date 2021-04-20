public class ASI_eForm_KR_DonationRequestPDFCtrl {
    public ASI_eForm_Donation_Request__c DonationRequest {get;set;} {DonationRequest = new ASI_eForm_Donation_Request__c();}
    public id DonationRequestId {set;get;}
    public ASI_eForm_KR_DonationRequestPDFCtrl(ApexPages.StandardController controller) {
        this.DonationRequest = (ASI_eForm_Donation_Request__c)controller.getRecord();
    }
    public ASI_eForm_KR_DonationRequestPDFCtrl(){}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

    public List<ASI_eForm_Donation_Request_Line_Items__c> lineItem{get;set;} {lineItem = new List<ASI_eForm_Donation_Request_Line_Items__c>(); }
    
    public boolean init(){  
        DonationRequest=[ Select id,Name,ASI_eForm_Delivery_to_Team_Name__c,ASI_eForm_Promotion_Code__r.Name,ASI_eForm_Purpose__c,ASI_eForm_Request_Date__c,ASI_eForm_Status__c,
                         ASI_eForm_Sys_Approver_1__c,ASI_eForm_Team_Branch__c,ASI_eForm_Usage__c,ASI_eForm_Team_Branch__r.Name, ASI_eForm_Order_Type__c, ASI_eForm_Total_Amount__c
                         from ASI_eForm_Donation_Request__c where id =: DonationRequestId];
        lineItem = [select id,ASI_eForm_Qty_Btl__c,ASI_eForm_SKU__c,ASI_eForm_SKU_Code__c,ASI_eForm_SKU__r.ASI_KOR_SKU_Name__c, ASI_eForm_Unit_Cost__c, ASI_eForm_Total_Amount__c
                    from ASI_eForm_Donation_Request_Line_Items__c 
                    where ASI_eForm_Donation_Request__c =: DonationRequestId ];
        return true;   
    }
}
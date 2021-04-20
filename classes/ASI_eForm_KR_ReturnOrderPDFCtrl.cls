public class ASI_eForm_KR_ReturnOrderPDFCtrl {
    public ASI_eForm_Return_Order_Request__c ReturnOrderRequest {get;set;} {ReturnOrderRequest = new ASI_eForm_Return_Order_Request__c();}
    public id RecordId {set;get;}
    public Boolean IsR42 {set;get;} {IsR42 = False;}
    public ASI_eForm_KR_ReturnOrderPDFCtrl(ApexPages.StandardController controller) {
        this.ReturnOrderRequest = (ASI_eForm_Return_Order_Request__c)controller.getRecord();
    }
    public ASI_eForm_KR_ReturnOrderPDFCtrl(){}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public List<ASI_eForm_Return_Order_Request_Line_Item__c> lineItem{get;set;} {lineItem = new List<ASI_eForm_Return_Order_Request_Line_Item__c>(); }
    
    public boolean init(){  
        ReturnOrderRequest = [ Select id,Name ,ASI_eForm_Branch_Code__c , ASI_eForm_Remarks__c , ASI_eForm_Request_Date__c , ASI_eForm_Sales_Admin__r.Name ,
                            ASI_eForm_Customer_Wholesaler__c , ASI_eForm_Customer_Code__c ,  ASI_eForm_Reason__c , 
                            ASI_eForm_Status__c , ASI_eForm_Street__c , ASI_eForm_Sys_Approver_1__c , ASI_eForm_Total_amount__c,Owner.Name ,ASI_eForm_Customer_Wholesaler__r.Name
                            , ASI_eForm_Grade__c  
                            from ASI_eForm_Return_Order_Request__c where id =: RecordId];
        lineItem = [
            SELECT
                ASI_eForm_Amount_Replace__c,
                ASI_eForm_Amount_Return__c,
                ASI_eForm_Channel_Replace__c,
                ASI_eForm_Channel_Return__c,
                ASI_eForm_Complaint_Category__c,
                ASI_eForm_Complaint_Details__c,
                ASI_eForm_Item_Group_Replace__c,
                ASI_eForm_Item_Group_Replace__r.ASI_KOR_Name_Kor__c,
                ASI_eForm_Item_Group_Replace__r.Name,
                ASI_eForm_Item_Group_Return__c,
                ASI_eForm_Item_Group_Return__r.ASI_KOR_Name_Kor__c,
                ASI_eForm_Item_Group_Return__r.Name,
                ASI_eForm_Lot_Number__c,
                ASI_eForm_Production_Date__c,
                ASI_eForm_Production_Time__c,
                ASI_eForm_Quantity_Replace__c,
                ASI_eForm_Quantity_Return__c,
                ASI_eForm_Remarks__c,
                ASI_eForm_Return_Order_Request__c,
                ASI_eForm_Unit_Price_Replace__c,
                ASI_eForm_Unit_Price_Return__c,
                ASI_eForm_UOM_Replace__c,
                ASI_eForm_UOM_Return__c,
                ASI_eForm_Venue__r.Name,
                Id
            FROM ASI_eForm_Return_Order_Request_Line_Item__c
            WHERE ASI_eForm_Return_Order_Request__c = :RecordId
        ];
    for(ASI_eForm_Return_Order_Request_Line_Item__c i : lineItem){
      if(i.ASI_eForm_Production_Time__c != null) i.ASI_eForm_Production_Time__c = i.ASI_eForm_Production_Time__c.addHours(9);
    }
    if(ReturnOrderRequest.ASI_eForm_Reason__c.contains('R42')){
            IsR42=true;
        }
        return true;   
    }
}
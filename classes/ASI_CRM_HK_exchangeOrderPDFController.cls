/*********************************************************************************
 * Name:ASI_CRM_HK_exchangeOrderPDFController
 * Description: 
 * Test Class: ASI_HK_CRM_exchOrder_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/08/2018         Wilken        		[WL 1.0] Add Packing Description to item
*********************************************************************************/
public class ASI_CRM_HK_exchangeOrderPDFController {
    
    public ApexPages.StandardController standardController {get;set;}
    public ASI_CRM_Exchange_Order__c Header {get;set;}
    public List<ASI_CRM_Exchange_Order_Item__c> ReturnLines {get;set;}
    public List<ASI_CRM_Exchange_Order_Item__c> ReplaceLines {get;set;}
    public Boolean ShowReturn {get;set;}
    public Boolean ShowReplace {get;set;}
    public String currentHeaderId {get; set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public ASI_CRM_HK_exchangeOrderPDFController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_CRM_Exchange_Order__c) this.standardController.getRecord();
        /*ShowReturn = false;
        ShowReplace = false;
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_CRM_Exchange_Order__c exo : [Select id, Name, ASI_CRM_HK_Request_Date__c, ASI_CRM_Customer__r.Name, ASI_CRM_Address__c, ASI_CRM_Attention__c, ASI_CRM_Phone__c, ASI_CRM_Customer__r.ASI_HK_CRM_Customer_Code__c, ASI_CRM_Collection_Date__c, ASI_CRM_Collection_Time__c, ASI_CRM_Remarks__c, ASI_CRM_Reasons__c, ASI_CRM_FOC_Issue_Note_No__c, ASI_CRM_POS_Issue_Note_No__c, ASI_CRM_JDE_Order_No__c, ASI_CRM_PO_No__c, Owner.Name FROM ASI_CRM_Exchange_Order__c where Id =: this.Header.Id limit 1]){
                this.Header = exo;
            }
            //definitions of Return and Replacement changed
            //Return: Include the exchange type = (return, exhange)
            //Replacement: exchange type = exchange
            // Modified on 20151008: 1) adding type "exchange" to ReturnLines
            // 						 2) Select sales order no. 
            // Modified on 20151012: getting address info
            ReturnLines = [SELECT id, Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, ASI_CRM_Qty_Bt_PC__c, ASI_CRM_HK_Remark__c, ASI_CRM_HK_Sales_Order_Item__c, ASI_CRM_HK_Sales_Order_Item__r.id, ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.Name,ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Delivery_Address__c, ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_1__c, 
ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_2__c, ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_3__c, ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_4__c FROM ASI_CRM_Exchange_Order_Item__c WHERE ASI_CRM_Exchange_Order__c = :this.Header.id AND (ASI_CRM_Type__c = 'Return' Or ASI_CRM_Type__c = 'Exchange')];
            if (ReturnLines.size() > 0) {
                ShowReturn = true;
             }
            ReplaceLines = [SELECT id, Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, ASI_CRM_Qty_Bt_PC__c, ASI_CRM_HK_Remark__c FROM ASI_CRM_Exchange_Order_Item__c WHERE ASI_CRM_Exchange_Order__c = :this.Header.id AND ASI_CRM_Type__c = 'Exchange'];
            if (ReplaceLines.size() > 0) {
                ShowReplace = true;
            }
        }*/
    }
    
    public ASI_CRM_HK_exchangeOrderPDFController(){ }
    
    public boolean init(){
        ShowReturn = false;
        ShowReplace = false;
        //if(this.Header !=null && this.Header.Id !=null)
        //{
            for(ASI_CRM_Exchange_Order__c exo : [Select id, Name, 
                                                 ASI_CRM_HK_Request_Date__c, 
                                                 ASI_CRM_Customer__r.Name, 
                                                 ASI_CRM_Address__c, 
                                                 ASI_CRM_Attention__c, 
                                                 ASI_CRM_Phone__c, 
                                                 ASI_CRM_Customer__r.ASI_HK_CRM_Customer_Code__c, 
                                                 ASI_CRM_Collection_Date__c, ASI_CRM_Collection_Time__c, 
                                                 ASI_CRM_Remarks__c, ASI_CRM_Reasons__c, 
                                                 ASI_CRM_FOC_Issue_Note_No__c, 
                                                 ASI_CRM_POS_Issue_Note_No__c, 
                                                 ASI_CRM_JDE_Order_No__c, 
                                                 ASI_CRM_PO_No__c, 
                                                 Owner.Name,
                                                 ASI_CRM_HK_Channel_Manager__r.Name
                                                 //Owner.Manager.Name
                                                 FROM ASI_CRM_Exchange_Order__c 
                                                 where Id =: currentHeaderId limit 1])
            {
                this.Header = exo;
            }
            ReturnLines = [SELECT id, Name, 
                           ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, 
                           ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
                           ASI_CRM_Qty_Bt_PC__c, ASI_CRM_HK_Remark__c, ASI_CRM_Remark__c,
                           ASI_CRM_HK_Sales_Order_Item__c,
							/*[WL 1.0] BEGIN*/
						   ASI_CRM_Packing_Description__c,
						   /*[WL 1.0] END*/
                           ASI_CRM_HK_Sales_Order_Item__r.id, 
                           ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.Name,
                           ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Delivery_Address__c, 
                           ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_1__c, 
                           ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_2__c, 
                           ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_3__c, 
                           ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Alternate_Delivery_Address_4__c 
                           FROM ASI_CRM_Exchange_Order_Item__c 
                           WHERE ASI_CRM_Exchange_Order__c = :currentHeaderId
                           AND (ASI_CRM_Type__c = 'Return' Or ASI_CRM_Type__c = 'Exchange')];
                
            if (ReturnLines.size() > 0)
            {
                ShowReturn = true;
            }
            ReplaceLines = [SELECT id, Name, 
                            ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, 
                            ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
                            ASI_CRM_Qty_Bt_PC__c,
							/*[WL 1.0] BEGIN*/
						   ASI_CRM_Packing_Description__c,
						   /*[WL 1.0] END*/							
                            ASI_CRM_HK_Remark__c 
                            FROM ASI_CRM_Exchange_Order_Item__c 
                            WHERE ASI_CRM_Exchange_Order__c = :currentHeaderId
                            AND ASI_CRM_Type__c = 'Exchange'];
            
            if (ReplaceLines.size() > 0)
            {
                ShowReplace = true;
            }
        //}
        return true;
    }//end method: init
    
}
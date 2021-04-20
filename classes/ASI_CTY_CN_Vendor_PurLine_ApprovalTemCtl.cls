/*****************************************************************************************************************
* Name:        ASI_CTY_CN_Vendor_PurLine_ApprovalTemCtl       
* Test Class:  
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -----------------------------------------------------------------------------
* 2020-11-14       wangzhiqiang                  Create Class
*****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_PurLine_ApprovalTemCtl {

	 public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

	 public Id PageId {get;set;}

	 public boolean pdf {get;set;}

   public boolean isShowother {get;set;}

   public Decimal blanceFee {get;set;}

	 public ASI_MFM_Purchase_Request_Line__c line {get;set;}

	 public List<ASI_CRM_Address__c> addList {get;set;}

   public List<ASI_CRM_quotation__c> quoList{get;set;}

   public boolean init(){
        
        line = [SELECT ASI_CTY_CN_Vendor_All_Price__c,ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.Name,ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Plan_Balance__c,Id,Name,ASI_CTY_CN_Vendor_Supplier__r.Name,ASI_MFM_Purchase_Request__r.Name,ASI_CTY_CN_Vendor_Sample_Required__c,ASI_CTY_CN_Vendor_Status__c,ASI_CTY_CN_Vendor_Total_Quantity__c,
        ASI_CTY_CN_Vendor_Bidding_Deadline__c,ASI_CTY_CN_Vendor_Quantity__c,ASI_CTY_CN_Vendor_Unit_Price__c,ASI_CTY_CN_Vendor_Total_Freight__c,
        ASI_CTY_CN_Vendor_Total_Price__c,CreatedBy.Name,CurrencyIsoCode,ASI_CTY_CN_Vendor_Item_Group_Code__r.Name FROM ASI_MFM_Purchase_Request_Line__c WHERE Id =:PageId];
        
        System.debug(LoggingLevel.INFO, '*** line: ' + line);
        addList = [SELECT Id,ASI_CTY_CN_Vendor_Quantity_Required__c,ASI_CTY_CN_Vendor_Outlet__r.Name,ASI_CTY_CN_Vendor_Receipt_Phone__c,ASI_CTY_CN_Vendor_Warehouse__r.Name,
        ASI_CTY_CN_Vendor_Receipt_Owner__c,ASI_CTY_CN_Vendor_Note__c,ASI_CTY_CN_Vendor_Delivery_Address__c,ASI_CTY_CN_Vendor_ContactName__c FROM ASI_CRM_Address__c WHERE ASI_CTY_CN_Vendor_PurLine__c =:PageId];
        System.debug(LoggingLevel.INFO, '*** addList: ' + addList);

        quoList = [SELECT ASI_CTY_CN_Vendor_Confirmed_Price__c,ASI_CTY_CN_Vendor_Result_Status__c,Id,Name,ASI_CTY_CN_Vendor_Total_Price__c,ASI_CTY_CN_Vendor_Sample__c,ASI_CTY_CN_Vendor_Supplier__r.Name,ASI_CTY_CN_Vendor_Model__c,ASI_CTY_CN_Vendor_Unitl_Price__c,ASI_CTY_CN_Vendor_Total_Freight__c FROM ASI_CRM_quotation__c WHERE ASI_CTY_CN_Purchase_Request_Line__c = :PageId AND RecordType.Name ='CN Vendor Quotation' AND ASI_CTY_CN_Vendor_IsConfirmed__c = true];
        System.debug(LoggingLevel.INFO, '*** quoList: ' + quoList);
        isShowother = false;
        if(quoList.size()>0)
        {
          isShowother = true;
        }
        
        blanceFee = 0;
       
        blanceFee = line.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Plan_Balance__c;

        return true;
    }    
}
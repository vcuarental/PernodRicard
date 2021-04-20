/*********************************************************************************
 * Name: ASI_CRM_HK_SORelatedListCtrl
 * Description: Customized Sales Order related list on Account page layout
 * Test Class: ASI_CRM_HK_SalesOrderRelatedListCtrlTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-25       Wilken Lee             [WL 1.0] Created
 */
public class ASI_CRM_HK_SORelatedListCtrl {
    public ApexPages.StandardController standardController {get;set;}
    public ASI_HK_CRM_Sales_Order__c Header {get;set;}
    private String soql {get;set;} 
    public transient List<ASI_HK_CRM_Sales_Order_Item__c> LineItem{get;set;}
    public boolean isDraft {get;set;}
	public boolean hasStockReserve {get;set;}
	public boolean hasEDIPrice {get;set;}

    public ASI_CRM_HK_SORelatedListCtrl(ApexPages.StandardController controller){
        this.standardController = controller;
        this.Header = (ASI_HK_CRM_Sales_Order__c) this.standardController.getRecord();   
		system.debug('Header ID:' + Header.Id);
		
		ASI_HK_CRM_Sales_Order__c thisSO = [select ASI_HK_CRM_Order_Status_Name__c from  ASI_HK_CRM_Sales_Order__c where Id = :Header.Id];
		if (thisSO.ASI_HK_CRM_Order_Status_Name__c == 'Draft')
			isDraft = true;
		else 
			isDraft = false;
		
		hasStockReserve = false;
		hasEDIPrice = false;
		init(); 
    }

    public Set<id> SOItemSet {set; get;}
    public void init() {
        soql = 'Select ' + 
            'id, Name ' +
            ',ASI_HK_CRM_Sub_brand__c ' +
            ',ASI_HK_CRM_Item_Group__c ' +
            ',ASI_HK_CRM_SKU_Code__c ' +
            ',ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Description__c ' +
			',ASI_HK_CRM_SKU_Packing_Description__c ' +
            ',ASI_HK_CRM_Quantity__c ' +
			',ASI_HK_CRM_Cancel_Qty__c ' +
			',ASI_HK_CRM_Free_Issue__c ' +
			',ASI_HK_CRM_Price__c ' +
			',ASI_HK_CRM_Amount__c ' +
			',ASI_HK_CRM_Stock_Reserve_Status__c ' +
			',ASI_HK_CRM_Reserve_Stock_No__c ' +
			',ASI_CRM_Released_Quantity__c ' +
			',ASI_HK_CRM_EDI_Price__c ' +			
			
            'FROM ASI_HK_CRM_Sales_Order_Item__c ' +
            'WHERE ASI_HK_CRM_Sales_Order__c = \'' + Header.Id + '\''
            +
            ' Order by Name ASC'
            ;
        system.debug('soql:::' + soql);
        runQuery();
        
    }
	
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                try{
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                }catch(Exception e){
                    System.debug('---------------SetCon:------'+e);
                }
            }
            setCon.setPageSize(1000);
            return setCon;
        }
        set;
    }

    public List<ASI_HK_CRM_Sales_Order_Item__c> getSOItem() {
         return (List<ASI_HK_CRM_Sales_Order_Item__c>) setCon.getRecords();
    }    

    public PageReference editItem() {
		 PageReference pageRef = new PageReference('/apex/ASI_HK_CRM_SalesOrderRequestDtEdPage?id=' + Header.Id);
        return pageRef;
    }
    
    public void runQuery() {
            
            LineItem = new  List<ASI_HK_CRM_Sales_Order_Item__c>();            
            LineItem = getSOItem();  
			
			for (ASI_HK_CRM_Sales_Order_Item__c item:LineItem){
				if (item.ASI_HK_CRM_Reserve_Stock_No__c != null)
					hasStockReserve = true;
				if (item.ASI_HK_CRM_EDI_Price__c != null)
					hasEDIPrice = true;
			}
    }    
}
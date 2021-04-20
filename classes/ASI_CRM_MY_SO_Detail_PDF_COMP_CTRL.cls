public without sharing class ASI_CRM_MY_SO_Detail_PDF_COMP_CTRL {
	public Id recordId {get;set;}
    public ASI_HK_CRM_Sales_Order__c sales_order {get;set;}
    public Address address {get;set;}
    public List<ASI_HK_CRM_Sales_Order_Item__c> sales_order_items {get;set;}
    public List<ASI_CRM_MY_SOI> l_sales_order_item {get;set;}
    public Decimal Extended_Price {get;set;}
    
    public ASI_CRM_MY_SO_Detail_PDF_COMP_CTRL(){}
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
     
    public boolean init(){ 
     	sales_order = [SELECT 
                       Name, 
                       Owner.Name,
                       Owner.Phone,
                       ASI_HK_CRM_Account_PA__r.Name,
                       ASI_HK_CRM_Customer_DA__r.Name,
                       ASI_HK_CRM_Total_Order_Amount__c,
                       ASI_HK_CRM_Order_Date__c,
                       ASI_HK_CRM_Delivery_Date__c,
                       ASI_HK_CRM_JDE_Status__c,
                       ASI_HK_CRM_Reason_For_Change__c,
                       ASI_HK_CRM_Delivery_Address__c,
                       ASI_HK_CRM_Credit_Limit__c,
                       ASI_HK_CRM_Payment_Term_Code__c,
                       ASI_HK_CRM_Payment_Term_Description__c,
                       ASI_HK_CRM_Current_Amount__c,
                       ASI_HK_CRM_X1_30__c,
                       ASI_HK_CRM_X31_60__c,
                       ASI_HK_CRM_X61_90__c,
                       ASI_HK_CRM_Over_91__c,
                       ASI_HK_CRM_Exceeded_Credit_Limit__c,
                       ASI_HK_CRM_Exceeded_Limit_Value_Percent__c,
                       ASI_HK_CRM_Total_Order_Amount_of_PA__c,
                       ASI_HK_CRM_Total_Exposure__c,
                       ASI_HK_CRM_Overdue_30_days__c,
                       ASI_HK_CRM_AR_Info_Last_Updated_By__c,
                       ASI_CRM_Customer_Address__c,
                       ASI_CRM_Delivery_Address__c,
                       ASI_HK_CRM_Phone_Number__c,
                       ASI_HK_CRM_Cust_PO__c,
                       ASI_CRM_Sold_To__r.ASI_CRM_MY_CustomerCode__c,
                       ASI_HK_CRM_JDE_Order_No__c,
                       ASI_HK_CRM_JDE_Order_Type_Code__c,
                       ASI_CRM_Source_No__c,
                       ASI_CRM_Branch_Plant__c,
                       ASI_CRM_Sold_To__r.Name,
                       ASI_CRM_Ship_To__r.Name,
                       ASI_CRM_MFM_No__c,
                       ASI_CRM_Orignator__c,
                       ASI_CRM_Media_Object_Text__c,
                       ASI_CRM_Delivery_Instruction_1__c,
                       ASI_CRM_Delivery_Instruction_2__c
                       FROM ASI_HK_CRM_Sales_Order__c 
                       WHERE Id = :recordId];
        
        sales_order_items = [SELECT 
                             ASI_HK_CRM_SKU_Code__c,
                             ASI_HK_CRM_SKU__r.ASI_HK_CRM_English_Name__c,
                             ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,
                             ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM1__c,
                             ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM2__c,
                             ASI_HK_CRM_SKU_Packing_Description__c,
                             ASI_HK_CRM_Quantity__c,
                             ASI_HK_CRM_Price__c,
                             ASI_CRM_Extended_Price__c,
                             ASI_HK_CRM_Amount__c,
                             ASI_CRM_System_Item_Type__c,
                             ASI_HK_CRM_UOM__c,
                             ASI_CRM_Pricing_UOM__c,
                             ASI_CRM_GL_Class__c,
                             ASI_HK_CRM_SKU__c
                             FROM ASI_HK_CRM_Sales_Order_Item__c 
                             WHERE ASI_HK_CRM_Sales_Order__c = :sales_order.Id
                             ORDER BY ASI_CRM_Line_ID__c];
        
        l_sales_order_item = new List<ASI_CRM_MY_SOI>(); 
        
        Extended_Price = 0;
        for(ASI_HK_CRM_Sales_Order_Item__c sales_order_item : sales_order_items){
            ASI_CRM_MY_SOI soi = new ASI_CRM_MY_SOI();
            soi.SKU_Code = sales_order_item.ASI_HK_CRM_SKU_Code__c;
            soi.SKU_Name = (sales_order_item.ASI_HK_CRM_SKU__c != null && sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_English_Name__c != null) ? sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_English_Name__c : '';
            soi.SKU_UOM1 = (sales_order_item.ASI_HK_CRM_SKU__c != null && sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM1__c != null) ? sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM1__c : '';
            soi.SKU_UOM2 = (sales_order_item.ASI_HK_CRM_SKU__c != null && sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM2__c != null) ? sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM2__c : '';
            soi.SKU_Packing_Description = sales_order_item.ASI_HK_CRM_SKU_Packing_Description__c;
            soi.Quantity = sales_order_item.ASI_HK_CRM_Quantity__c != null ? sales_order_item.ASI_HK_CRM_Quantity__c : 0;
            soi.Extended_Price = sales_order_item.ASI_CRM_Extended_Price__c != null ? sales_order_item.ASI_CRM_Extended_Price__c : 0;
            soi.Price = sales_order_item.ASI_HK_CRM_Price__c;
            soi.System_Item_Type = sales_order_item.ASI_CRM_System_Item_Type__c;
            soi.UOM = sales_order_item.ASI_HK_CRM_UOM__c;
			soi.Pricing_UOM = sales_order_item.ASI_CRM_Pricing_UOM__c;
            soi.GL_Class = sales_order_item.ASI_CRM_GL_Class__c;
            soi.Packaging_Size = (sales_order_item.ASI_HK_CRM_SKU__c != null && sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null) ? sales_order_item.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
			
            Extended_Price += soi.Extended_Price;
            
            system.debug('@@@Quantity: '+soi.Quantity);
            system.debug('@@@Packaging_Size: '+soi.Packaging_Size);
            
            if(soi.UOM == soi.SKU_UOM1){
                soi.ct_Quantity = soi.Packaging_Size > 0 ? (soi.Quantity / soi.Packaging_Size).round(System.RoundingMode.DOWN) : 0;
                soi.bt_Quantity = soi.Packaging_Size > 0 ? math.mod( Integer.valueOf(soi.Quantity), Integer.valueOf(soi.Packaging_Size) ) : 0;
            }
            else if(soi.UOM == soi.SKU_UOM2){
                soi.ct_Quantity = Integer.valueOf(soi.Quantity);
                soi.bt_Quantity = 0;
            }
            else{
                soi.ct_Quantity = 0;
                soi.bt_Quantity = Integer.valueOf(soi.Quantity);
            }
			
            /*
            if(soi.UOM == 'CT'){
                soi.ct_Quantity = Integer.valueOf(soi.Quantity);
                soi.bt_Quantity = 0;
            }
            else if(soi.UOM == 'BT'){
                soi.ct_Quantity = soi.Packaging_Size > 0 ? (soi.Quantity / soi.Packaging_Size).round(System.RoundingMode.DOWN) : 0;
                soi.bt_Quantity = soi.Packaging_Size > 0 ? math.mod( Integer.valueOf(soi.Quantity), Integer.valueOf(soi.Packaging_Size) ) : 0;
            }
            else{
                soi.ct_Quantity = 0;
                soi.bt_Quantity = 0;
            }
			*/
			  
            l_sales_order_item.add(soi);
        }
        
        
        
               
        
        return true;
    }
 
    
}
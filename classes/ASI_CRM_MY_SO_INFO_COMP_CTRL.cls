public without sharing class ASI_CRM_MY_SO_INFO_COMP_CTRL {
	public Id recordId {get;set;}
    public String headerdata{get;set;}
    public String url{get;set;}
    public ASI_HK_CRM_Sales_Order__c sales_order {get;set;}
    public Map<String, integer> m_sales_order_item_index {get;set;} 
    public Map<String, integer> m_sales_order_item_pmm_index {get;set;} 
    //public List<ASI_HK_CRM_Sales_Order_Item__c> sales_order_items {get;set;}
    public Set<String> s_Sub_brand_Description {get;set;}
    public Set<String> s_pmm_Sub_brand_Description {get;set;}
    public integer lastindexofaccount {get;set;}
    public integer lastindexofpmm {get;set;}
    public Decimal pmm_total_order_quantity {get;set;}
    public List<Attachment> l_Attachment {get;set;}
    public String sfdcBaseURL {get{
        return System.URL.getSalesforceBaseURL().toExternalForm();
    }set;} 
    public List<String> l_HYPERLINK {get;set;}
    
    public ASI_CRM_MY_SO_INFO_COMP_CTRL(){
    }
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public boolean init(){ 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        //headerdata= ApexPages.currentPage().getHeaders().get('Host');
        url = baseUrl+'/'+recordId;
        //url='https://' + headerdata+'/'+recordId;
        
        sales_order = [SELECT 
                       Name, 
                       Owner.Name,
                       ASI_CRM_Sold_To__r.Name,
                       ASI_CRM_Ship_To__r.Name,
                       ASI_CRM_Order_Gross_Amount__c,
                       ASI_CRM_Total_Additional_FOC__c,
                       ASI_HK_CRM_Order_Date__c,
                       ASI_HK_CRM_Delivery_Date__c,
                       ASI_CRM_Order_Status__c,
                       ASI_HK_CRM_Reason_For_Change__c,
                       ASI_CRM_Delivery_Address__c,
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
                       ASI_CRM_AR_Last_Paid_Date__c,
                       ASI_HK_CRM_Credit_Hold_Reason__c,
                       ASI_CRM_Hold_Code__c 
                       FROM ASI_HK_CRM_Sales_Order__c 
                       WHERE Id = :recordId];
        
        
        List<ASI_HK_CRM_Sales_Order_Item__c> l_sales_order_item = [SELECT 
                                                                 ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Description__c,
                                                                 ASI_CRM_System_Item_Type__c,
                                                                 ASI_HK_CRM_Quantity__c 
                                                                 FROM ASI_HK_CRM_Sales_Order_Item__c 
                                                                 WHERE ASI_HK_CRM_Sales_Order__c = :sales_order.Id 
                                                                 AND ASI_CRM_Sub_Brand__c != null
                                                                 AND ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Description__c != null
                                                                 AND (ASI_CRM_System_Item_Type__c  = 'Add FOC' OR ASI_CRM_System_Item_Type__c = 'Premium Item')];
        
        l_Attachment = [SELECT Id, Name  
                        FROM Attachment 
                        WHERE ParentId = :sales_order.Id];
        
        
        l_HYPERLINK = new List<String>();
        for(Attachment attachment : l_Attachment){
			l_HYPERLINK.add(sfdcBaseURL+'/servlet/servlet.FileDownload?file='+attachment.Id);
        }
        
        s_Sub_brand_Description = new Set<String>();
        s_pmm_Sub_brand_Description = new Set<String>();
        pmm_total_order_quantity = 0;
        for(ASI_HK_CRM_Sales_Order_Item__c sales_order_item : l_sales_order_item){ 
            if(sales_order_item.ASI_CRM_System_Item_Type__c == 'Add FOC'){
            	s_Sub_brand_Description.add(sales_order_item.ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Description__c);    
            }
            if(sales_order_item.ASI_CRM_System_Item_Type__c == 'Premium Item'){
                pmm_total_order_quantity += sales_order_item.ASI_HK_CRM_Quantity__c != null ? sales_order_item.ASI_HK_CRM_Quantity__c : 0;
                s_pmm_Sub_brand_Description.add(sales_order_item.ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Description__c);    
            }
        }
        
        Integer sales_order_item_index = 0;
        lastindexofaccount = s_Sub_brand_Description.size();
        
        m_sales_order_item_index = new Map <String, Integer>();    
        for(String Sub_brand_Description : s_Sub_brand_Description){        
        	sales_order_item_index = sales_order_item_index +1;
            m_sales_order_item_index.put(Sub_brand_Description, sales_order_item_index);
        }
        
        Integer sales_order_item_pmm_index = 0;
        lastindexofpmm = s_pmm_Sub_brand_Description.size();
        
        m_sales_order_item_pmm_index = new Map <String, Integer>();    
        for(String Sub_brand_Description : s_pmm_Sub_brand_Description){        
        	sales_order_item_pmm_index = sales_order_item_pmm_index +1;
            m_sales_order_item_pmm_index.put(Sub_brand_Description, sales_order_item_pmm_index);
        }
        
        
        return true;
    }
    
}
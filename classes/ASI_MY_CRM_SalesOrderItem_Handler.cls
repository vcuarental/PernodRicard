//test ASI_MY_CRM_SalesOrder_Handler_Test
public without sharing class ASI_MY_CRM_SalesOrderItem_Handler {
    
    public static void routineBeforeInsert(List<sObject> l_new, Map<Id, sObject> m_new, List<sObject> l_old, Map<Id, sObject> m_old){
        assign_item_type(l_new, m_new, l_old, m_old);
    }
	
    public static void routineBeforeUpdate(List<sObject> l_new, Map<Id, sObject> m_new, List<sObject> l_old, Map<Id, sObject> m_old){
        assign_item_type(l_new, m_new, l_old, m_old);
    }
    
    public static void assign_item_type(List<sObject> l_new, Map<Id, sObject> m_new, List<sObject> l_old, Map<Id, sObject> m_old){
        List<ASI_HK_CRM_Sales_Order_Item__c> l_sales_order_item = (List<ASI_HK_CRM_Sales_Order_Item__c>)l_new;
        
        Set<Id> s_sales_order = new Set<Id>();
        Set<Id> s_skuId = new Set<Id>();
        
        for(ASI_HK_CRM_Sales_Order_Item__c sales_order_item : l_sales_order_item){
            if(sales_order_item.ASI_HK_CRM_Sales_Order__c != null){
                s_sales_order.add(sales_order_item.ASI_HK_CRM_Sales_Order__c);
            }
            if(sales_order_item.ASI_HK_CRM_SKU__c != null){
                s_skuId.add(sales_order_item.ASI_HK_CRM_SKU__c);
            }
        }
     
        Map<Id, ASI_HK_CRM_Sales_Order__c> m_sales_order = new Map<Id, ASI_HK_CRM_Sales_Order__c>();
        if(!s_sales_order.isEmpty()){
            m_sales_order = new Map<Id, ASI_HK_CRM_Sales_Order__c>([SELECT ASI_CRM_System_Order_Type__c 
                                                                    FROM ASI_HK_CRM_Sales_Order__c
                                                                    WHERE Id IN :s_sales_order]);
        }
        Map<Id, ASI_MFM_SKU_Code__c> m_sku_code = new Map<Id, ASI_MFM_SKU_Code__c>();
        if(!s_skuId.isEmpty()){
            m_sku_code = new Map<Id, ASI_MFM_SKU_Code__c>([SELECT ASI_HK_CRM_Packaging_Size__c, ASI_HK_CRM_Product_Category__c, ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c   
                                                           FROM ASI_MFM_SKU_Code__c
                                                           WHERE Id IN :s_skuId]);
        }
        
        
        
        for(ASI_HK_CRM_Sales_Order_Item__c sales_order_item : l_sales_order_item){
            Id sales_order_Id = sales_order_item.ASI_HK_CRM_Sales_Order__c;
            Id sku_Id = sales_order_item.ASI_HK_CRM_SKU__c;
            if(m_sku_code.containsKey(sku_Id)){
                
                ASI_MFM_SKU_Code__c sku_code = m_sku_code.get(sku_Id);
                String sku_category_code = (sku_code.ASI_HK_CRM_Product_Category__c != null && String.isNotBlank(sku_code.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c)) ? sku_code.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c : null;
                if(sku_category_code == 'PR'){
                    sales_order_item.ASI_CRM_System_Item_Type__c = 'Premium Item';
                }
                else{
                    if(m_sales_order.containsKey(sales_order_Id)){
                        ASI_HK_CRM_Sales_Order__c sales_order = m_sales_order.get(sales_order_Id);
                        
                        if(sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.so_with_ch || sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.so_without_ch ||  sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.sor_with_ch ||    sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.sor_without_ch || sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.dn || sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.cn){
                            if(sales_order_item.ASI_HK_CRM_Price__c == 0    && sales_order_item.ASI_CRM_Last_Status__c != null  && (Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) >= 500 && Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) < 600) ){
                        		sales_order_item.ASI_CRM_System_Item_Type__c = 'Add FOC';
                            }
                            else if(sales_order_item.ASI_HK_CRM_Price__c == 0  && sales_order_item.ASI_CRM_Last_Status__c != null  && (Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) == 910 || Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) == 912 ) ){
                               // if(sales_order_item.ASI_CRM_GL_Class__c!=null && sales_order_item.ASI_CRM_GL_Class__c =='OFF2'){
                               //     sales_order_item.ASI_CRM_System_Item_Type__c = 'Add FOC';
                                //}else{
                                    sales_order_item.ASI_CRM_System_Item_Type__c = 'FOC';
                               // }
                                
                            }
                            else if(sales_order_item.ASI_HK_CRM_Price__c != 0 
                                   && sales_order_item.ASI_CRM_Last_Status__c != null
                                   && (Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) >= 500 && Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) < 1000)){
                                sales_order_item.ASI_CRM_System_Item_Type__c = 'Normal SO Item';
                            }
                        }
                        else if(sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.foc || sales_order.ASI_CRM_System_Order_Type__c == ASI_MY_CRM_SalesOrder_Ctrl.focr){
                            if(sales_order_item.ASI_HK_CRM_Price__c == 0    && sales_order_item.ASI_CRM_Last_Status__c != null   && (Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) >= 500 && Integer.valueOf(sales_order_item.ASI_CRM_Last_Status__c) < 600)){
                                sales_order_item.ASI_CRM_System_Item_Type__c = 'FOC';
                            }
                        }
                    }
                }
            }
        }
    }
    
}
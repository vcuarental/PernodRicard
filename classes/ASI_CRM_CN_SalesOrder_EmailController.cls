public without sharing class ASI_CRM_CN_SalesOrder_EmailController {
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public ASI_KOR_Sales_Order_Request__c SOCurrent{get;set;}
    public List<ASI_KOR_Sales_Order_Transaction__c> lineItem {get;set;}
    public List<salesOrderClass> lineItemClass {get;set;}
    public Boolean hasAllocationItem {get; set;}{hasAllocationItem = false;}
    
    public Boolean init(){
        
        SOCurrent = [
                SELECT Id
                        , Name
                        , ASI_CRM_CN_Total_order_Amt__c
                        , ASI_CRM_CN_Total_Qty__c
                        , ASI_CRM_CN_Customer__c
                        , ASI_CRM_CN_Customer__r.Name
                        , ASI_CRM_CN_Address__c
                        , ASI_KOR_Requested_Date__c
                        , ASI_CRM_CN_JDE_Customer_Number__c
                        , ASI_CRM_SG_Order_Date__c
                        , ASI_CRM_CN_Total_Order_Qty_9L__c
                        , ASI_CRM_CN_Other_Requirement__c
                        , ASI_CRM_CN_RTD__c
                        , ASI_CRM_Discount__c
                        , ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c //20181105 Alan Lau
                        , ASI_CRM_MOT_PO__c //20181119 Alan Lau
                        , ASI_CRM_Total_Order_Amount_MOT__c //20181119 Alan Lau
                        , ASI_CRM_Total_Promotion_Cost__c //20181119 Alan Lau
                FROM ASI_KOR_Sales_Order_Request__c
                WHERE Id = :currentHeaderID
        ];
        
        lineItem = new List<ASI_KOR_Sales_Order_Transaction__c>();
        //20170205 Elufa added ASI_CRM_CN_Product_Name__r.ASI_CRM_Allocation_Information__c
        lineItem = [
                SELECT Id
                        , ASI_CRM_Allocation_Information__c
                        , ASI_CRM_CN_Product_Name__r.ASI_CRM_Allocation_Information__c
                        , ASI_CRM_CN_Product_Name__r.ASI_MFM_Item_Group_Code__c
                        , Name
                        , ASI_CRM_CN_Product_Name__r.Name
                        , ASI_CRM_CN_Promotion_Code__r.Name
                        , ASI_CRM_CN_Remark__c
                        , ASI_CRM_CN_Unit_Price_BT_with_VAT__c
                        , ASI_CRM_CN_Unit_Price_Source__c
                        , ASI_KOR_Order_Qty__c
                        , ASI_CRM_CN_UOM__c
                        , ASI_CRM_CN_Qty_9L__c
                        , ASI_CRM_CN_Promotion_Code__c
                        , ASI_CRM_CN_Free_Qty_BT__c
                        , ASI_CRM_CN_Promotion_Expiration_Date__c
                        , ASI_CRM_CN_Total_Amount_BT__c
            			, ASI_CRM_Original_Quantity__c // 20190528 Vincent Lam
                        , ASI_CRM_MOT_Price_non_VAT__c //20181105 Alan Lau
                        , ASI_CRM_MOT_Promotion_Price_non_VAT__c //20181105 Alan Lau
                        , ASI_CRM_MOT_Discount_Amount__c //20181105 Alan Lau
                FROM ASI_KOR_Sales_Order_Transaction__c
                WHERE ASI_KOR_Sales_Order_Request__c = :currentHeaderID
        ];
        lineItemClass = new List<salesOrderClass>();
        List<salesOrderClass> tmplineItemClass = new List<salesOrderClass>();
        if(SOCurrent.ASI_CRM_CN_RTD__c){
            
            List<ASI_CRM_Order_Form_Customer_Relationship__c> OFID = [SELECT ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Customer__c =: SOCurrent.ASI_CRM_CN_Customer__c AND ASI_CRM_Order_Form_Type__c = 'RTD'];
            List<ASI_CRM_Order_Form_Detail__c> OFD = new List<ASI_CRM_Order_Form_Detail__c>();
            if(OFID.size() > 0)
            	OFD = [SELECT ASI_CRM_Product_Name__c, ASI_CRM_Sequence__c FROM ASI_CRM_Order_Form_Detail__c WHERE ASI_CRM_Order_Form__c =: OFID[0].ASI_CRM_Order_Form__c];
            Map<String, Decimal> mapSequence = new Map<String, Decimal>();
            
            for(ASI_CRM_Order_Form_Detail__c obj : OFD){
                if(obj.ASI_CRM_Sequence__c != NULL)
                    mapSequence.put(obj.ASI_CRM_Product_Name__c, obj.ASI_CRM_Sequence__c);
            }
            
            for(ASI_KOR_Sales_Order_Transaction__c obj : lineItem){

                //20170205 Elufa
                if(obj.ASI_CRM_CN_Product_Name__r.ASI_CRM_Allocation_Information__c)
                    hasAllocationItem = True;
                
                salesOrderClass tmpClass = new salesOrderClass();
                
                tmpClass.sequence = mapSequence.containsKey(obj.ASI_CRM_CN_Product_Name__c) ? mapSequence.get(obj.ASI_CRM_CN_Product_Name__c) : NULL;
                tmpClass.lineItem = obj;

                tmpClass.motPriceDiscountRate = tmpClass.lineItem.ASI_CRM_MOT_Discount_Amount__c != null && tmpClass.lineItem.ASI_CRM_MOT_Price_non_VAT__c != null ? ((tmpClass.lineItem.ASI_CRM_MOT_Discount_Amount__c / tmpClass.lineItem.ASI_CRM_MOT_Price_non_VAT__c) * 100).setScale(2) : 0; //20190110 Alan Lau
                
                tmplineItemClass.add(tmpClass);
        	}
            
        }else if(!SOCurrent.ASI_CRM_CN_RTD__c){
            
        	List<ASI_CRM_Order_Form_Customer_Relationship__c> OFID = [SELECT ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Customer__c =: SOCurrent.ASI_CRM_CN_Customer__c AND ASI_CRM_Order_Form_Type__c = 'Normal Item'];
            List<ASI_CRM_Order_Form_Detail__c> OFD = new List<ASI_CRM_Order_Form_Detail__c>();
            if(OFID.size() > 0)
                OFD = [SELECT ASI_CRM_Product_Name__c, ASI_CRM_Sequence__c FROM ASI_CRM_Order_Form_Detail__c WHERE ASI_CRM_Order_Form__c =: OFID[0].ASI_CRM_Order_Form__c];
            Map<String, Decimal> mapSequence = new Map<String, Decimal>();
            
            for(ASI_CRM_Order_Form_Detail__c obj : OFD){
                if(obj.ASI_CRM_Sequence__c != NULL)
                    mapSequence.put(obj.ASI_CRM_Product_Name__c, obj.ASI_CRM_Sequence__c);
            }
            
            for(ASI_KOR_Sales_Order_Transaction__c obj : lineItem){
                
                //20170205 Elufa
                if(obj.ASI_CRM_Allocation_Information__c)
                    hasAllocationItem = True;
                
                salesOrderClass tmpClass = new salesOrderClass();
                
                tmpClass.sequence = mapSequence.containsKey(obj.ASI_CRM_CN_Product_Name__c) ? mapSequence.get(obj.ASI_CRM_CN_Product_Name__c) : NULL;
                tmpClass.lineItem = obj;

                tmpClass.motPriceDiscountRate = tmpClass.lineItem.ASI_CRM_MOT_Discount_Amount__c != null && tmpClass.lineItem.ASI_CRM_MOT_Price_non_VAT__c != null ? ((tmpClass.lineItem.ASI_CRM_MOT_Discount_Amount__c / tmpClass.lineItem.ASI_CRM_MOT_Price_non_VAT__c) * 100).setScale(2) : 0; //20190110 Alan Lau
                
                tmplineItemClass.add(tmpClass);
            }
        }
            
        List<salesOrderClass> tmplineItemClass2 = new List<salesOrderClass>();
        List<salesOrderClass> tmplineItemClass3 = new List<salesOrderClass>();
        
        for(salesOrderClass obj : tmplineItemClass){
            if(obj.sequence != NULL){
                tmplineItemClass2.add(obj);
            }else{
                tmplineItemClass3.add(obj);
            }
        }
        
        if(tmplineItemClass2.size() > 0){
            Decimal k;
            integer l;
            integer i = 0;
            Boolean sorting = TRUE;
            while(sorting){
                
                Decimal j = tmplineItemClass2[i].sequence;
                
                k = k == NULL ? j : k;
                
                if(j <= k){
                    k = j;
                    l = i;
                }
                
                i++;
                if(i > tmplineItemClass2.size() - 1){
                    i = 0;
                    lineItemClass.add(tmplineItemClass2[l]);
                    tmplineItemClass2.remove(l);
                    k = NULL;
                    l = NULL;
                }
                
                sorting = !tmplineItemClass2.isEmpty();
            }
        }
        lineItemClass.addAll(tmplineItemClass3);
        
        /*for(ASI_KOR_Sales_Order_Transaction__c obj : lineItem){
            if(obj.ASI_CRM_CN_Product_Name__r.name.length() > 10 ){
                
                String c = obj.ASI_CRM_CN_Product_Name__r.Name;
                String b = '';
                
                while(c.length() >= 10  )
                {
                    b = b + c.subString(0,10) + '\n';
                	c = c.subString(10);
                }
                b = b + c;
                obj.ASI_CRM_CN_Product_Name__r.Name = b;
            }

			if(obj.ASI_CRM_CN_Remark__c.length() > 10 ){
                
                String c = obj.ASI_CRM_CN_Product_Name__r.Name;
                String b = '';
                
                while(c.length() >= 10  )
                {
                    b = b + c.subString(0,10) + '\n';
                	c = c.subString(10);
                }
                b = b + c;
                obj.ASI_CRM_CN_Product_Name__r.Name = b;
            }
        }*/
        
        return true;
    }
    Public Class salesOrderClass{
        Public Decimal sequence { get; set; }
        Public ASI_KOR_Sales_Order_Transaction__c lineItem{get;set;}
        public Decimal motPriceDiscountRate {get;set;}
    }
}
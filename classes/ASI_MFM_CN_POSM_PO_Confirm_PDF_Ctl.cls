public class ASI_MFM_CN_POSM_PO_Confirm_PDF_Ctl {
    
    public id POID {get;set;}
    public String domain {get;set;}
    public Date orderDate {get;set;}
    public String poRemarkSubString {get;set;}
    public String accCode {get;set;}
    public Decimal deliveryAmount {get;set;}
    public Map<String,String> posmItemPhotoMap {get;set;}
    public List<ASI_MFM_PO_POSM_Line__c> posmLineList {get;set;}
    public Map<Id, ASI_MFM_PO_POSM_Line__c> posmLineMap {get;Set;}
    public Map<Id, List<ASI_MFM_Item_Group_Line__c>> bundleItemLineMap {get;set;}
    public Map<Id, PosmLineObj> summaryMap {get;Set;}
    public Set<Id> itemGroupSet {get;set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_MFM_CN_POSM_PO_Confirm_PDF_Ctl(){}
    
    public boolean init(){
        orderDate = Date.today();
        posmLineList = [SELECT Id,name,ASI_MFM_Item_Group_Code__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
                        ASI_MFM_Total_Price__c,ASI_MFM_Total_Price_w_VAT__c,ASI_MFM_Bundle_Item_Group__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name, ASI_MFM_PO__r.ASI_MFM_Currency__c,
                        ASI_MFM_PO__r.ASI_MFM_Payment_Term__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_1__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_2__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_3__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_4__c,
                        ASI_MFM_PO__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Phone,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c,
                    	ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.gvp__Primary_Contact__c,
	                    ASI_MFM_PO__r.Owner.name, ASI_MFM_PO__r.ASI_MFM_eMarket_Buyer__r.name,
                    	ASI_MFM_PO__r.ASI_MFM_Remarks__c,ASI_MFM_PO__r.Name,
                        ASI_MFM_PO__r.ASI_MFM_CN_PO_Amount_RMB__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,
                        ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.ASI_CRM_Brand__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Inspection__c,ASI_MFM_Item_Group__r.ASI_MFM_Unit__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Safety_Instruction__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Period_of_Validity__c,
                        ASI_MFM_Contact_Person__c,ASI_MFM_Phone_Number__c,ASI_MFM_City__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c,
                    	ASI_MFM_Item_Group__r.ASI_MFM_Campaign_Name__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c,
                    	ASI_MFM_Item_Group__r.ASI_MFM_Importation__c,
                    	ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_1__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_1__r.name,
                        ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_2__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_2__r.name,
                        ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_3__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_3__r.name,
                        ASI_MFM_Delivery_Address_Warehouse__c, ASI_MFM_Delivery_Address_Warehouse__r.name,
                        ASI_MFM_Delivery_Address_Outlet__c, ASI_MFM_Delivery_Address_Outlet__r.name,
                    	ASI_MFM_Detail_Address__c, ASI_MFM_PO__r.CreatedDate
                        FROM ASI_MFM_PO_POSM_Line__c 
                        WHERE ASI_MFM_PO__c=:POID
                       	AND ASI_MFM_Confirm_PO_Notice__c = true];
        if(posmLineList.size()==0) return true;
        itemGroupSet = new Set<Id>();
        posmLineMap = new Map<Id,ASI_MFM_PO_POSM_Line__c>();
        summaryMap = new Map<Id, PosmLineObj>();
        
        Set<Id> bundleItemIdSet = new Set<Id>();
        bundleItemLineMap = new Map<Id, List<ASI_MFM_Item_Group_Line__c>>();
        
        for(ASI_MFM_PO_POSM_Line__c posmLine :posmLineList){
            bundleItemLineMap.put(posmLine.ASI_MFM_Item_Group__c,new List<ASI_MFM_Item_Group_Line__c>());
            if(posmLine.ASI_MFM_Bundle_Item_Group__c) {
                bundleItemIdSet.add(posmLine.ASI_MFM_Item_Group__c);
            }
            if(!itemGroupSet.contains(posmLine.ASI_MFM_Item_Group__c)) {
                itemGroupSet.add(posmLine.ASI_MFM_Item_Group__c);
                posmLineMap.put(posmLine.ASI_MFM_Item_Group__c,posmLine);
                summaryMap.put(posmLine.ASI_MFM_Item_Group__c,new PosmLineObj(posmLine));
            } else {
                summaryMap.get(posmLine.ASI_MFM_Item_Group__c).addSummay(posmLine);
            }
        }
        
        // SELECT Bundle Item line
        
        List<ASI_MFM_Item_Group_Line__c> componentItemList = [SELECT ASI_MFM_Item_Group__c, ASI_MFM_Chinese_Name__c , ASI_MFM_English_Name__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Unit_Quantity_in_Bundle__c
                                                              FROM ASI_MFM_Item_Group_Line__c
                                                              WHERE ASI_MFM_Item_Group__c IN :bundleItemIdSet];
        for(ASI_MFM_Item_Group_Line__c itemLine : componentItemList) {
            if(!bundleItemLineMap.containsKey(itemLine.ASI_MFM_Item_Group__c)) bundleItemLineMap.put(itemLine.ASI_MFM_Item_Group__c, new List<ASI_MFM_Item_Group_Line__c>());
            bundleItemLineMap.get(itemLine.ASI_MFM_Item_Group__c).add(itemLine);
        }
        
        deliveryAmount = 0.0;
        for(ASI_MFM_PO_Line_Item__c poLineItem :[SELECT ASI_MFM_Amount__c, ASI_MFM_Delivery_Fee__c, ASI_MFM_A_C_Code__r.Name FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c = :POID]) {
            accCode = poLineItem.ASI_MFM_A_C_Code__r.Name;
            if(poLineItem.ASI_MFM_Delivery_Fee__c==true) {
                deliveryAmount = poLineItem.ASI_MFM_Amount__c;
            }
        }
        
        domain=URL.getSalesforceBaseUrl().toExternalForm();
        
        Set<Id> itemGroupIdSet = new Set<Id>();
        posmItemPhotoMap = new Map<String,String>();
        for(ASI_MFM_PO_POSM_Line__c posmline :posmLineList) {
            posmItemPhotoMap.put(posmline.ASI_MFM_Item_Group__c, '-1');
            itemGroupIdSet.add(posmline.ASI_MFM_Item_Group__c);
        }
        
        
        for(ASI_CRM_Product_Warehouse_Photo__c photo: [SELECT ASI_CRM_Item_Group__c, ASI_Image_URL__c FROM ASI_CRM_Product_Warehouse_Photo__c WHERE ASI_CRM_Item_Group__c IN :itemGroupIdSet AND ASI_Image_URL__c != NULL]) {
            posmItemPhotoMap.put(photo.ASI_CRM_Item_Group__c, photo.ASI_Image_URL__c);
        }
        
        if(posmLineList.size()>0) {
            poRemarkSubString = posmLineList[0].ASI_MFM_PO__r.ASI_MFM_Remarks__c;
            poRemarkSubString = poRemarkSubString.substring(0, Math.min(5, poRemarkSubString.length()));
        }
        return true;
    }
    
    public class DeliveryObj {
        public String address {get;set;}
        public String city {get;set;}
        public String detailAddr {get;set;}
        public String person {get;set;}
        public String phone {get;set;}
        public Decimal qty {get;set;}
        
        public DeliveryObj(ASI_MFM_PO_POSM_Line__c posmLine) {
            address = (posmline.ASI_MFM_Delivery_Address_Outlet__r.name!=null)? posmline.ASI_MFM_Delivery_Address_Outlet__r.name:posmline.ASI_MFM_Delivery_Address_Warehouse__r.name;
            city = posmline.ASI_MFM_City__c;
            detailAddr = posmline.ASI_MFM_Detail_Address__c;
            person = posmline.ASI_MFM_Contact_Person__c;
            phone = posmline.ASI_MFM_Phone_Number__c;
            qty = posmline.ASI_MFM_Quantity__c;
        }
    }
    
    public class PosmLineObj {
        public Decimal count {get;set;}
        public Decimal qty {get;set;}
        public Decimal total {get;set;}
        public Decimal totalvat {get;set;}
        public Decimal unitPrice {get;set;}
        public List<DeliveryObj> delivery {get;set;}
        
        public PosmLineObj(ASI_MFM_PO_POSM_Line__c posmLine) {
            this.unitPrice = (posmLine.ASI_MFM_Unit_Price__c!=null)?posmLine.ASI_MFM_Unit_Price__c:0;
            this.qty = (posmLine.ASI_MFM_Quantity__c!=null)?posmLine.ASI_MFM_Quantity__c:0;
            this.total = (posmLine.ASI_MFM_Total_Price__c!=null)?posmLine.ASI_MFM_Total_Price__c:0;
            this.totalvat = (posmLine.ASI_MFM_Total_Price_w_VAT__c!=null)?posmLine.ASI_MFM_Total_Price_w_VAT__c:0;
            this.count = 1;
            this.delivery = new List<DeliveryObj>{new DeliveryObj(posmLine)};
        }
        
        public void addSummay(ASI_MFM_PO_POSM_Line__c posmLine){
            this.unitPrice += (posmLine.ASI_MFM_Unit_Price__c!=null)?posmLine.ASI_MFM_Unit_Price__c:0;
            this.qty += (posmLine.ASI_MFM_Quantity__c!=null)?posmLine.ASI_MFM_Quantity__c:0;
            this.total += (posmLine.ASI_MFM_Total_Price__c!=null)?posmLine.ASI_MFM_Total_Price__c:0;
            this.totalvat += (posmLine.ASI_MFM_Total_Price_w_VAT__c!=null)?posmLine.ASI_MFM_Total_Price_w_VAT__c:0;
            this.count++;
            this.delivery.add(new DeliveryObj(posmLine));
        }
    }   
}
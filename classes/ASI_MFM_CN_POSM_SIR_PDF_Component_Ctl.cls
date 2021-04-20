public class ASI_MFM_CN_POSM_SIR_PDF_Component_Ctl {
    public id LINEID {get;set;}
    public String requestTimestamp {get;set;}
    public Integer sirCount {get;set;}
    public ASI_MFM_Stock_In_Request__c sirSingle {get;set;}
    public ASI_MFM_PO_POSM_Line__c posmLine {get;set;}
    public List<ASI_MFM_Stock_In_Request__c> sirList {get;set;}
    public String sirTimestamp {get;set;}
    public Integer sirLineCount {get;set;}
    public String remarkSubstring {get;set;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public ASI_MFM_CN_POSM_SIR_PDF_Component_Ctl(){
    }
    public boolean init(){
        posmLine = [SELECT id,name,ASI_MFM_Item_Group_Code__c,ASI_MFM_Unit_Price__c, 
                        ASI_MFM_PO__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Phone,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c,
                    	ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.gvp__Primary_Contact__c,
	                    ASI_MFM_PO__r.Owner.name, ASI_MFM_PO__r.ASI_MFM_eMarket_Buyer__r.name,
                    	ASI_MFM_PO__r.ASI_MFM_Remarks__c,
                        ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.ASI_CRM_Brand__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Inspection__c,ASI_MFM_Item_Group__r.ASI_MFM_Unit__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Safety_Instruction__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Period_of_Validity__c,
                        ASI_MFM_Contact_Person__c,ASI_MFM_Phone_Number__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c,
                    	ASI_MFM_Item_Group__r.ASI_MFM_Campaign_Name__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c,
                    	ASI_MFM_Item_Group__r.ASI_MFM_Importation__c,
                    	ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_1__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_1__r.name,
                        ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_2__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_2__r.name,
                        ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_3__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_3__r.name,
                    	ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c,
                        ASI_MFM_Delivery_Address_Warehouse__c, ASI_MFM_Delivery_Address_Warehouse__r.name,
                        ASI_MFM_Delivery_Address_Outlet__c, ASI_MFM_Delivery_Address_Outlet__r.name,
                    	ASI_MFM_Detail_Address__c,
                        (SELECT id,name,ASI_Delivery_Date__c, ASI_MFM_TIV_Number__c,
                         ASI_MFM_Total_Quantity__c,ASI_MFM_Lot_Number__c,ASI_MFM_Qty_Per_Bag_Box__c,
                         ASI_MFM_Qty_Per_Box__c, ASI_MFM_Total_Number_Of_Box__c, ASI_MFM_Fraction_Qty__c, ASI_MFM_SIR_Sent__c,
                         ASI_MFM_Net_Weight__c, ASI_MFM_Timestamp__c, ASI_MFM_Box_Net_Weight__c, ASI_MFM_Min_Unit_Price__c,
                         ASI_MFM_Total_Qty_Per_Bag_Box__c 
                         FROM Stock_In_Requests__r
                         WHERE ASI_MFM_Status__c Like 'Confirmed'
                         AND ASI_MFM_SIR_Sent__c = false
                         //AND ASI_MFM_TIV_Note_Sent__c=false
                         //AND ASI_MFM_TIV_Number__c!=''
                         ORDER BY ASI_Delivery_Date__c)
                    FROM ASI_MFM_PO_POSM_Line__c 
                    WHERE id= :LINEID
                    LIMIT 1];
        remarkSubstring = posmLine.ASI_MFM_PO__r.ASI_MFM_Remarks__c;
        remarkSubstring = remarkSubstring.substring(0, Math.min(5, remarkSubstring.length()));
        sirTimestamp = '';
        sirList = new List<ASI_MFM_Stock_In_Request__c>();
        for(ASI_MFM_Stock_In_Request__c sir : posmLine.Stock_In_Requests__r){
            if(sirTimestamp==''||sirTimestamp==sir.ASI_MFM_Timestamp__c) {
                if(sirTimestamp=='') {sirTimestamp = sir.ASI_MFM_Timestamp__c;}
                sirSingle = sir;
                sir.ASI_MFM_SIR_Sent__c = true;
                sirList.add(sir);
            }
        }
        sirLineCount = sirList.size();
        if(sirList.size()>0) {
            update sirList;
        }
        return true;
    }
}
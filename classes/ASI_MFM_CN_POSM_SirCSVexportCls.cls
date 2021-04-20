public class ASI_MFM_CN_POSM_SirCSVexportCls {
    
    public String ponum {get;set;}
    public transient List<ItemCsvWrapper> csvLineList {get; private set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = fetchList();} return dummyVar; } set; }
    
    public ASI_MFM_CN_POSM_SirCSVexportCls(){
    }
    
    public boolean fetchList() {
        if(String.isBlank(ponum) || ponum == null)
            ponum = apexpages.currentPage().getParameters().get('ponum');
        Id posmlineRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
        
        List<ASI_MFM_PO_POSM_Line__c> posmLineList = [SELECT id, Name, ASI_MFM_PO__r.Name, ASI_MFM_Item_Group__r.name, 
                                                      		ASI_MFM_Item_Group_Code__c, ASI_MFM_Quantity__c, 
                                                          	ASI_MFM_Unit_Price__c, ASI_MFM_Province__c, ASI_MFM_City__c, ASI_MFM_Detail_Address__c,
                                                      		ASI_MFM_Delivery_Address_Warehouse__c,
                                                      		ASI_MFM_Delivery_Address_Outlet__c, 
                                                      		ASI_MFM_Delivery_Address_Warehouse__r.ASI_MFM_Direct_Delivery__c,
                                                      		ASI_MFM_Delivery_Address_Warehouse__r.name,
                                                      		ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c,
                                                      		ASI_MFM_Delivery_Address_Outlet__r.ASI_CRM_CN_Chi_Name__c,
                                                      		ASI_MFM_Delivery_Address_Outlet__r.ASI_CRM_CN_Eng_Name__c 
                                                      FROM ASI_MFM_PO_POSM_Line__c 
                                                      WHERE ASI_MFM_PO__r.Name = :ponum
                                                      AND RecordTypeId = :posmlineRTID
                                                      AND ASI_MFM_Confirm_PO_Notice__c=true
                                                     	];
        csvLineList = new List<ItemCsvWrapper>();
        for(ASI_MFM_PO_POSM_Line__c line : posmLineList){
            //if(line.ASI_MFM_Delivery_Address_Warehouse__r.ASI_MFM_Direct_Delivery__c!=true)
	            csvLineList.add(new ItemCsvWrapper(line));
        }
        return true;
    }
    
    public class ItemCsvWrapper {
        public String name {get; set;}
        public String poNum {get; set;}
        public String itemgroupName {get; set;}
        public String itemgroupCode {get; set;}
        public String quantity {get; set;}
        public String unitPrice {get; set;}
        public String address {get; set;}
        public String engAddress {get;set;}
        
        public ItemCsvWrapper(ASI_MFM_PO_POSM_Line__c item) {
            this.name = (item.Name!=null)? item.Name:'';
            this.address 	= (item.ASI_MFM_Delivery_Address_Outlet__c!=null)? item.ASI_MFM_Delivery_Address_Outlet__r.ASI_CRM_CN_Chi_Name__c:item.ASI_MFM_Delivery_Address_Warehouse__r.name+'-'+item.ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c+' '+item.ASI_MFM_Province__c+' '+item.ASI_MFM_City__c+' '+item.ASI_MFM_Detail_Address__c;
            this.engAddress = (item.ASI_MFM_Delivery_Address_Outlet__c!=null)? item.ASI_MFM_Delivery_Address_Outlet__r.ASI_CRM_CN_Eng_Name__c:item.ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c;
            this.poNum = (item.ASI_MFM_PO__r.Name!=null)? item.ASI_MFM_PO__r.Name:'';
            this.itemgroupName = (item.ASI_MFM_Item_Group__r.name!=null)? item.ASI_MFM_Item_Group__r.name:'';
            this.itemgroupCode = (item.ASI_MFM_Item_Group_Code__c!=null)? item.ASI_MFM_Item_Group_Code__c:'';
            this.quantity = (item.ASI_MFM_Quantity__c!=null)? item.ASI_MFM_Quantity__c+'':'';
            this.unitPrice= (item.ASI_MFM_Unit_Price__c!=null)? item.ASI_MFM_Unit_Price__c+'':'';
        }
    }
}
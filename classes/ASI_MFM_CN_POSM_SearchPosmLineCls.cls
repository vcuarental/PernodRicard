global with sharing class ASI_MFM_CN_POSM_SearchPosmLineCls {
    
    @RemoteAction
    global static ResultObj searchPosm(String dataSet) {
        try {
            Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
            String ponum = (String)dataMap.get('ponum');
            if(ponum==null||ponum=='') {
                return new ResultObj(false, 'Please Input PO Number', null);
            }
            Id posmlineRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
            List<ASI_MFM_PO_POSM_Line__c> posmLineList = [SELECT id, Name, ASI_MFM_PO__r.Name, ASI_MFM_Item_Group__r.name, 
                                                          	ASI_MFM_Item_Group_Code__c, ASI_MFM_Quantity__c, 
	                                                        ASI_MFM_Delivery_Address_Warehouse__r.ASI_MFM_Direct_Delivery__c,
                                                          	ASI_MFM_Unit_Price__c
                                                          FROM ASI_MFM_PO_POSM_Line__c 
                                                          WHERE ASI_MFM_PO__r.Name = :ponum
                                                          AND RecordTypeId = :posmlineRTID];
            if(posmLineList.size() == 0) {
                return new ResultObj(false, 'PO : ' + ponum + ' Not Found', null);
            }
            List<PosmLine> lineList = new List<PosmLine>();
            for(ASI_MFM_PO_POSM_Line__c posmLine : posmLineList) {
                //if(posmLine.ASI_MFM_Delivery_Address_Warehouse__r.ASI_MFM_Direct_Delivery__c!=true)
	                lineList.add(new PosmLine(posmLine));
            }
            return new ResultObj(true, 'success', lineList);
        } catch (Exception e) {
            return new ResultObj(false, e.getMessage(), null);
        }
    }
    
    global class ResultObj {
    	public String message;
        public Boolean success;
        public List<PosmLine> posmLineList;
        public ResultObj(Boolean b, String m, List<PosmLine> plList){
            message = m;
            success = b;
            posmLineList = plList;
        }
    }
    
    global class PosmLine {
        public String posmLineNum;
        public String itemGroupName;
        public String itemGroupCode;
        public String poNum;
        public Decimal quantity;
        public Decimal unitPrice;
        
        public PosmLine(ASI_MFM_PO_POSM_Line__c posmline) {
            posmLineNum = (posmline.Name!=null) ? posmline.Name:'';
            poNum = (posmline.ASI_MFM_PO__r.Name!=null)? posmline.ASI_MFM_PO__r.Name:'';
            itemGroupName = (posmline.ASI_MFM_Item_Group__r.name!=null)? posmline.ASI_MFM_Item_Group__r.name:'';
            itemGroupCode = (posmline.ASI_MFM_Item_Group_Code__c!=null)? posmline.ASI_MFM_Item_Group_Code__c:'';
            quantity = (posmline.ASI_MFM_Quantity__c!=null)? posmline.ASI_MFM_Quantity__c:0;
            unitPrice = (posmline.ASI_MFM_Unit_Price__c!=null)? posmline.ASI_MFM_Unit_Price__c:0;
        }
    }

}
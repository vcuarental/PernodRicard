global with sharing class ASI_MFM_CN_POSM_VendorMailSelectCtrl {
    public String posmLineListJson {get;set;}
    public String poid{get;set;}
	public ASI_MFM_CN_POSM_VendorMailSelectCtrl() {
        poid = ApexPages.currentPage().getParameters().get('Id');
        //String sql = getFullSql('ASI_MFM_PO_POSM_Line__c', 'ASI_MFM_PO__c = :poid');
        //List<ASI_MFM_PO_POSM_Line__c> posmLinelist = Database.query(sql);
        List<ASI_MFM_PO_POSM_Line__c> posmLinelist = [SELECT id, ASI_MFM_Item_Group_Chinese_Name__c, ASI_MFM_Item_Group_Code__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,ASI_MFM_Total_Price__c,
                                                      		ASI_MFM_Total_Price_w_VAT__c,ASI_MFM_Detail_Address__c, ASI_MFM_Tax_Code__r.name
                                                      FROM ASI_MFM_PO_POSM_Line__c
                                                      WHERE ASI_MFM_PO__c = :poid
                                                     ];
        posmLineListJson = JSON.serialize(posmLinelist);
    }
    
    @RemoteAction
    global static ResultObj sendMail(String dataSet) {
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        List<Object> dataList = (List<Object>)dataMap.get('posmLineList');
        String poid = (String)dataMap.get('po');
        if(dataList==null||dataList.size()==0) {
            return new ResultObj(false, 'Please Select POSM Line.');
        }
        List<ASI_MFM_PO_POSM_Line__c> selectedPosmLineList = new List<ASI_MFM_PO_POSM_Line__c>();
        for(Object data : dataList) {
            Map<String,Object> mapping = (Map<String,Object>)data;
            selectedPosmLineList.add(new ASI_MFM_PO_POSM_Line__c(Id=(Id)mapping.get('id'),ASI_MFM_Confirm_PO_Notice__c=(Boolean)mapping.get('select')));
        }
        update selectedPosmLineList;
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(Id=poid, ASI_MFM_Confirm_PO_Notification__c=true);
        update po;
        return new ResultObj(true, 'Success.');
    }
    
    global class ResultObj {
    	public String message;
        public Boolean success;
        public ResultObj(Boolean b, String m){
            message = m;
            success = b;
        }
    }
    /*
    private String getFullSql(String apiname, String condition){
        String strSql = 'SELECT ';
        for(String key : Schema.getGlobalDescribe().get(apiname).getDescribe().fields.getMap().keySet()) {
            strSql+= key+' ,';
        }
        strSql = strSql.removeEnd(',');
        strSql += 'FROM '+apiname+' ';
        if(condition!=null && condition!='') {
            strSql += 'WHERE ' + condition;
        }
        return strSql;
    }
*/
}
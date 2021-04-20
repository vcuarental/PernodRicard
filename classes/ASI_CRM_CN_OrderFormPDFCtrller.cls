public without sharing class ASI_CRM_CN_OrderFormPDFCtrller {
    public ASI_CRM_CN_OrderFormPDFCtrller(ApexPages.StandardController controller) {
        this.header = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
    }
    public ASI_CRM_CN_OrderFormPDFCtrller(){ }
    public id currentHeaderId {set;get;}
    public ASI_CRM_AccountsAdditionalField__c header{get;set;}
    //Oreder Form 
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    //RTD Order Form 
    public Boolean dummyI { get { if (dummyI != true) {dummyI = initI();} return dummyI; } set; }
    
    //20161026 Ben @ Elufa
    Public String orderFormType {Get; Set;}
    
    public List<ASI_CRM_Order_Form_Customer_Relationship__c> OFCR_List{get;set;}
    public List<ASI_CRM_Order_Form_Detail__c> OFD_List {get;set;}
    public List<ASI_CRM_Item_Group_Customer_Price__c> Customer_IGCP {get;set;}
    
    //20170205 Elufa
    Public Boolean hasAllocation {Get; Set;}{hasAllocation = False;}
    
    public Class interimData{
        public ASI_CRM_Order_Form_Detail__c OFD {get; set;}
        public ASI_CRM_Item_Group_Customer_Price__c IGCP {get; set;}
    }
    public List<interimData> results {get; set;}
    public Map<String, ASI_CRM_Item_Group_Customer_Price__c> results2 = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
    public List<interimData> results3 {get; set;}
    
    //2019/10/27 CanterDuan 记录税率
    Public Decimal taxRate {get;set;}
    
    public boolean init(){
        header=[select name,ASI_CRM_CN_Is_IHBR_Outlet__c from ASI_CRM_AccountsAdditionalField__c where id=:currentHeaderId];
        
		//2019/10/27 CanterDuan 获取最新的汇率
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(!taxRateList.isEmpty()){
            taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
        //Setup
        Customer_IGCP = new List<ASI_CRM_Item_Group_Customer_Price__c>();
        //OFCR_List=new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
        OFD_List=new List<ASI_CRM_Order_Form_Detail__c>();
        set<id> OFCR_set = new set<id>();
        set<id> OFD_set= new set<id>();
        map<String, ASI_CRM_Order_Form_Detail__c> OFD_map = new map<String, ASI_CRM_Order_Form_Detail__c>();
        
        results = new List<interimData>();
        results3 = new List<interimData>();
        
        if(header.ASI_CRM_CN_Is_IHBR_Outlet__c==true){
            //20170205 Elufa added ASI_CRM_Allocation_Information__c
            for(ASI_CRM_Item_Group_Customer_Price__c igcp:[select ASI_CRM_Item_Group__r.ASI_CRM_Allocation_Information__c, ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c, ASI_CRM_Promotion_Expiration_Date__c, ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Customer__c=:currentHeaderId AND ASI_CRM_Price_Type__c != 'T1']){ // Customer_IGCP=[select ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Customer__c=:currentHeaderId];

                //20170205 Elufa
                if(igcp.ASI_CRM_Item_Group__r.ASI_CRM_Allocation_Information__c)
                    hasAllocation = True;
                
                interimData temp= new interimData();
                temp.IGCP=igcp;
                results.add(temp);
            }
        }else{
            for(ASI_CRM_Order_Form_Customer_Relationship__c OFCR:[select name,ASI_CRM_Order_Form__c from ASI_CRM_Order_Form_Customer_Relationship__c where ASI_CRM_Customer__c=:currentHeaderId]){ //OFCR_List=[select name,ASI_CRM_Order_Form__c from ASI_CRM_Order_Form_Customer_Relationship__c where ASI_CRM_Customer__c=:currentHeaderId];
                OFCR_set.add(OFCR.ASI_CRM_Order_Form__c);
            }
            //20170205 Elufa added , ASI_CRM_Product_Name__r.ASI_CRM_Allocation_Information__c
            List<ASI_CRM_Order_Form_Detail__c> tmpOFD = new List<ASI_CRM_Order_Form_Detail__c>([select name, ASI_CRM_Product_Name__r.ASI_CRM_Allocation_Information__c, ASI_CRM_Sequence__c, ASI_CRM_Product_Name__c,ASI_CRM_Product_Name__r.name,ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Remark__c from ASI_CRM_Order_Form_Detail__c where ASI_CRM_Order_Form__c in: OFCR_set and ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c='Normal Item' Order By ASI_CRM_Sequence__c Desc]);
            List<ASI_CRM_Order_Form_Detail__c> tmpOFDSorted = new List<ASI_CRM_Order_Form_Detail__c>();
            for(integer i = tmpOFD.size()-1; i >= 0 ; i--){
                
                //20170205 Elufa
                if(tmpOFD[i].ASI_CRM_Product_Name__r.ASI_CRM_Allocation_Information__c)
                    hasAllocation = True;
                
                tmpOFDSorted.add(tmpOFD[i]);
            }
            for(ASI_CRM_Order_Form_Detail__c OFD : tmpOFDSorted){ //OFD_List=[select name,ASI_CRM_Product_Name__c,ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Remark__c from ASI_CRM_Order_Form_Detail__c where ASI_CRM_Order_Form__c in: OFCR_set];
                interimData temp= new interimData();
                OFD_set.add(OFD.ASI_CRM_Product_Name__c);
                OFD_map.put(currentHeaderId + '' + OFD.ASI_CRM_Product_Name__c,OFD);
                if (OFD.ASI_CRM_Remark__c != null){
                //string[] strcomment1 = (a.ASI_CRM_Comment__c).split('\n');
                String c = OFD.ASI_CRM_Remark__c;
                String b = '';
                while(c.length() >= 6  )
                {
                    b = b + c.subString(0,6) + '\n';
                	c = c.subString(6);
                }
                b = b + c;
                OFD.ASI_CRM_Remark__c = b;

            }
                temp.OFD=OFD;
            	results.add(temp);
            }
            
            for(ASI_CRM_Item_Group_Customer_Price__c igcp:[select name, ASI_CRM_Promotion_Expiration_Date__c, ASI_CRM_Customer__c,ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Item_Group__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Item_Group__c in:OFD_set AND ASI_CRM_Customer__c = : currentHeaderId]){  // Customer_IGCP=[select name,ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Item_Group__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Item_Group__c in:OFD_set];
                
                ASI_CRM_Item_Group_Customer_Price__c temp= new ASI_CRM_Item_Group_Customer_Price__c();
                
                if(OFD_map.containsKey(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c) && taxRate != null){
                    //20190415 Laputa Andy changed Tax Rate from 16% to 13%
                    //igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * 1.13).setScale(2);//20180426 Introv changed Tax Rate from 17% to 16%
                	igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * (1 + taxRate/100)).setScale(2); //2019/10/27 CanterDuan将税率修改调整为配置的形式
                    temp=igcp;
            		results2.put(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c, temp);
                }
            }
            if(results.size() > 0){
                for(interimData obj : results){
                    interimData temp= new interimData();
                    temp.OFD = obj.OFD;
                    if(results2.containsKey(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c))
                        temp.IGCP = results2.get(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c);
                    results3.add(temp);
                }
            }
        }
        return true; 
    }
    
    
    public boolean initI(){
        header=[select name from ASI_CRM_AccountsAdditionalField__c where id=:currentHeaderId];
        //2019/10/27 CanterDuan 获取最新的汇率
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(!taxRateList.isEmpty()){
            taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
        //Setup
        Customer_IGCP=new List<ASI_CRM_Item_Group_Customer_Price__c>();
        OFD_List=new List<ASI_CRM_Order_Form_Detail__c>();
        set<id> OFCR_set = new set<id>();
        set<id> OFD_set= new set<id>();
        map<String, ASI_CRM_Order_Form_Detail__c> OFD_map = new map<String, ASI_CRM_Order_Form_Detail__c>();
        
        results = new List<interimData>();
        results3 = new List<interimData>();
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c OFCR:[select name,ASI_CRM_Order_Form__c from ASI_CRM_Order_Form_Customer_Relationship__c where ASI_CRM_Customer__c=:currentHeaderId]){ 
            OFCR_set.add(OFCR.ASI_CRM_Order_Form__c);
        }
        
        List<ASI_CRM_Order_Form_Detail__c> tmpOFD = new List<ASI_CRM_Order_Form_Detail__c>([select name
                                                                                            , ASI_CRM_Sequence__c
                                                                                            , ASI_CRM_Product_Name__r.name
                                                                                            , ASI_CRM_Product_Name__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_Code__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_CRM_Allocation_Information__c//20170205 Elufa
                                                                                            , ASI_CRM_Remark__c from ASI_CRM_Order_Form_Detail__c 
                                                                                            where ASI_CRM_Order_Form__c in: OFCR_set 
                                                                                            and ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c = : orderFormType
                                                                                            Order By ASI_CRM_Sequence__c Desc]);
        List<ASI_CRM_Order_Form_Detail__c> tmpOFDSorted = new List<ASI_CRM_Order_Form_Detail__c>();
            
        for(integer i = tmpOFD.size()-1; i >= 0 ; i--){
            
            //20170205 Elufa
            if(tmpOFD[i].ASI_CRM_Product_Name__r.ASI_CRM_Allocation_Information__c)
                hasAllocation = True;
            
            tmpOFDSorted.add(tmpOFD[i]);
        }
        
        for(ASI_CRM_Order_Form_Detail__c OFD: tmpOFDSorted){
            interimData temp= new interimData();
            OFD_set.add(OFD.ASI_CRM_Product_Name__c);
            OFD_map.put(currentHeaderId + '' + OFD.ASI_CRM_Product_Name__c,OFD);
            
            if (OFD.ASI_CRM_Remark__c != null){
                //string[] strcomment1 = (a.ASI_CRM_Comment__c).split('\n');
                String c = OFD.ASI_CRM_Remark__c;
                String b = '';
                while(c.length() >= 6 )
                {
                    b = b + c.subString(0,6) + '\n';
                	c = c.subString(6);
                }
                b = b + c;
                OFD.ASI_CRM_Remark__c = b;

            }
            temp.OFD=OFD;
            results.add(temp);
        }

        for(ASI_CRM_Item_Group_Customer_Price__c igcp:[select name, ASI_CRM_Promotion_Expiration_Date__c, ASI_CRM_Customer__c,ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Item_Group__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Item_Group__c in:OFD_set AND ASI_CRM_Customer__c = : currentHeaderId]){
            
            ASI_CRM_Item_Group_Customer_Price__c temp= new ASI_CRM_Item_Group_Customer_Price__c();
            if(OFD_map.containsKey(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c) && taxRate != null){
                //20190415 Laputa Andy changed Tax Rate from 16% to 13%
                //igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * 1.13).setScale(3);//20180426 Introv changed Tax Rate from 17% to 16%
                igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * (1 + taxRate/100)).setScale(3); //2019/10/27 CanterDuan将税率修改调整为配置的形式
                temp=igcp;
                results2.put(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c, temp);
            }
        }
        if(results.size() > 0){
            for(interimData obj : results){
                interimData temp= new interimData();
                temp.OFD = obj.OFD;
                if(results2.containsKey(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c))
                    temp.IGCP = results2.get(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c);
                results3.add(temp);
            }
        }
        return true; 
    }
}
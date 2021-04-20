public with sharing class ASI_MFM_CN_POtoSupplier_Component_Ctr {
    public ASI_MFM_CN_POtoSupplier_Component_Ctr(ApexPages.StandardController controller) {
        this.PO = (ASI_MFM_PO__c)controller.getRecord();
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
    }

  //ApexPages.StandardController controller;
    public ASI_MFM_PO__c po {set;get;}
    public ASI_MFM_Plan__c plan{get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lineItem{get;set;}
    public id POID {set;get;}
    public String subbrand_all {set;get;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }


    public ASI_MFM_CN_POtoSupplier_Component_Ctr(){
      lineItem = new List<ASI_MFM_PO_Line_Item__c>();
    }

    public boolean init(){
      
        system.debug(poid);
        List<ASI_MFM_PO__c> LPO = [Select ASI_MFM_Status__c, ASI_MFM_Supplier_Name__r.Name, Name,  ASI_MFM_PO_Start_Date__c,
          ASI_MFM_PO_End_Date__c, ASI_MFM_PO_Type__c, Owner.Name, ASI_MFM_BU_Code__r.Name, 
          ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_Remarks__c, 
          ASI_MFM_Event_ID__r.ASI_MFM_Event__r.Name, ASI_MFM_Currency__c,
          LastModifiedBy.Name, ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c, ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,
          ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,
          ASI_MFM_PO_Amount__c
          from ASI_MFM_PO__c where id =:POID limit 1];
        if(LPO != null && LPO.size()>0){
            this.Po = LPO[0];
        
            ASI_MFM_PO__c poCurrent = [select ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c from ASI_MFM_PO__c where id =: Po.Id];
            System.debug('POId ' + Po.Id);
            
            List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
                ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_A_C_Code__r.Name, ASI_MFM_BU_Code__r.ASI_MFM_BU_Description__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c, ASI_MFM_AP_Code__r.Name,
                ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c, 
                ASI_MFM_G_L_Date__c, ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c, ASI_MFM_Customer_Name__r.Name 
                from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: Po.Id];
            
            return init(poCurrent, lineItemList);
        }
        return true;
    }
     
    /*    
    public boolean init(){
      
    system.debug(poid);
        List<ASI_MFM_PO__c> LPO = [Select ASI_MFM_Status__c, ASI_MFM_Supplier_Name__r.Name, Name,  ASI_MFM_PO_Start_Date__c,
          ASI_MFM_PO_End_Date__c, ASI_MFM_PO_Type__c, Owner.Name, ASI_MFM_BU_Code__r.Name, 
          ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_Remarks__c, 
          ASI_MFM_Event_ID__r.ASI_MFM_Event__r.Name, ASI_MFM_Currency__c,
          LastModifiedBy.Name, ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c, ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,
          ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,
          ASI_MFM_PO_Amount__c
          from ASI_MFM_PO__c where id =:POID limit 1];
        if(LPO != null && LPO.size()>0){
        this.Po = LPO[0];
        lineItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        
        ASI_MFM_PO__c poCurrent = [select ASI_MFM_Supplier_Name__c,ASI_MFM_Plan__c from ASI_MFM_PO__c where id =: Po.Id];
        System.debug('POId ' + Po.Id);
        
        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,
            owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
           
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);
        List<ASI_MFM_PO_Line_Item__c> lineItemList = [select ASI_MFM_List_Item_Description__c,ASI_MFM_UOM__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
        ASI_MFM_Amount__c,ASI_MFM_SKU_Code__r.Name, ASI_MFM_A_C_Code__r.Name, ASI_MFM_BU_Code__r.ASI_MFM_BU_Description__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c, ASI_MFM_AP_Code__r.Name,
        ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c, 
        ASI_MFM_G_L_Date__c, ASI_MFM_Customer_Name__r.ASI_HK_CRM_Customer_Code__c, ASI_MFM_Customer_Name__r.Name 
        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c =: Po.Id];
        subbrand_all = '';
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
 
            if(poli.ASI_MFM_Quantity__c == null){
                poli.ASI_MFM_Quantity__c = 0;
            }
            if(poli.ASI_MFM_Unit_Price__c == null){
                poli.ASI_MFM_Unit_Price__c = 0;
            }
            if(poli.ASI_MFM_Amount__c == null){
                poli.ASI_MFM_Amount__c = 0;
            }
            lineItem.add(poli);
            List <ASI_MFM_Sub_brand__c> SBName = [SELECT Name FROM ASI_MFM_Sub_brand__c WHERE id = :poli.ASI_MFM_Sub_brand_Code__c];
            for (ASI_MFM_Sub_brand__c abc : SBName){
                subbrand_all +=  abc.Name + '<br/>' ;
            }
        }
        //catch(exception e){e.getMessage();}
        }
        return true;
    }
    */
        
    public boolean init(ASI_MFM_PO__c poCurrent, List<ASI_MFM_PO_Line_Item__c> lineItemList){

        if(poCurrent.ASI_MFM_Plan__c != null){
            plan = [select id,Name,ASI_MFM_Plan_Description__c,
            owner.name from ASI_MFM_Plan__c where id =: poCurrent.ASI_MFM_Plan__c ]; 
        }
        else{
            plan = new ASI_MFM_Plan__c();
            plan.Name = '';
            plan.ASI_MFM_Plan_Description__c = '';
        }
           
        System.debug('planId' + plan.id);
        System.debug('planName' + plan.Name);
        System.debug('planDescription' + plan.ASI_MFM_Plan_Description__c);

        subbrand_all = '';
        for(ASI_MFM_PO_Line_Item__c poli : lineItemList){
 
            if(poli.ASI_MFM_Quantity__c == null){
                poli.ASI_MFM_Quantity__c = 0;
            }
            if(poli.ASI_MFM_Unit_Price__c == null){
                poli.ASI_MFM_Unit_Price__c = 0;
            }
            if(poli.ASI_MFM_Amount__c == null){
                poli.ASI_MFM_Amount__c = 0;
            }
            lineItem.add(poli);
            List <ASI_MFM_Sub_brand__c> SBName = [SELECT Name FROM ASI_MFM_Sub_brand__c WHERE id = :poli.ASI_MFM_Sub_brand_Code__c];
            for (ASI_MFM_Sub_brand__c abc : SBName){
                subbrand_all +=  abc.Name + '<br/>' ;
            }
        }
        //catch(exception e){e.getMessage();}

        return true;
    }
    
    String LongDate = ' ';

      // Init cLongDate with the current Datetime in long date format    
    public String getLongDate() {
        Datetime cDT = System.now();
        LongDate = cDT.format('yyyy-MM-dd hh:mm');
        return LongDate;
        }
}
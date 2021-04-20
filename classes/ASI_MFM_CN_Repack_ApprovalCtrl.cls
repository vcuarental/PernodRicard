public without sharing class ASI_MFM_CN_Repack_ApprovalCtrl {
    public String PageId {set;get;}
    public Decimal beforeNumberOfCases {set;get;}
    public Decimal afterNumberOfCases {set;get;}
    // public DataInfo dataInfo{set;get;}
    public Map<String,Object> dataInfo{set;get;}
    public ASI_MFM_POSM_Return_Request__c onlineRemark {set;get;}{onlineRemark= new ASI_MFM_POSM_Return_Request__c ();}
    
    public ASI_MFM_CN_Repack_ApprovalCtrl(){}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_MFM_CN_Repack_ApprovalCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
    }
    public Boolean isMultiple {set;get;}
    public String productCode {set;get;}
    public String productDesc {set;get;}

    public boolean init(){
        onlineRemark = [SELECT ASI_MFM_Item_Code_Before_Repack2__r.ASI_MFM_SKU_Code__c,ASI_MFM_Item_Code_Before_Repack3__r.ASI_MFM_SKU_Code__c,ASI_MFM_Item_Code_Before_Repack4__r.ASI_MFM_SKU_Code__c,
        ASI_MFM_Item_Code_Before_Repack5__r.ASI_MFM_SKU_Code__c,ASI_MFM_Item_Code_Before_Repack2__c,ASI_MFM_Item_Code_Before_Repack3__c,ASI_MFM_Item_Code_Before_Repack4__c,ASI_MFM_Item_Code_Before_Repack5__c,ASI_MFM_Item_Code_Before_Repack2_Des__c,ASI_MFM_Item_Code_Before_Repack3_Des__c,ASI_MFM_Item_Code_Before_Repack4_Des__c,ASI_MFM_Item_Code_Before_Repack5_Des__c,ASI_MFM_English_Name__c,ASI_MFM_Old_Item_English_Name__c,ASI_MFM_Repack_Unit_Price__c,ASI_MFM_Traceability_Puma_Requirement__c ,ASI_MFM_Estimated_delivery_time__c,ASI_MFM_Is_the_T1_price_changed__c,ASI_MFM_Logistic_Application__c,ASI_MFM_Repack_Charge_Other_Remark__c,CreatedDate,Name,ASI_MFM_New_Item_English_Name__c,ASI_MFM_Chinese_Name__c,ASI_MFM_Sales_Channel__c,  ASI_MFM_Repack_Deadline__c,
        ASI_MFM_Repack_Material_Source__c, ASI_MFM_Repack_Manpower_Fee_Charge_To__c,ASI_MFM_Repack_Type_and_Frequency__c, ASI_MFM_Item_Code_Before_Repack__r.ASI_MFM_SKU_Code__c,
        ASI_MFM_T1_Price__c,ASI_MFM_Repack_BT_Set_Quantity__c,ASI_MFM_Old_Item_Bottle_Barcode__c,ASI_MFM_Item_Code_After_Repack__r.ASI_MFM_SKU_Code__c,
        ASI_MFM_New_Item_Bottle_Barcode__c,ASI_MFM_Repack_Material_Item_Code__c,ASI_MFM_Carton_Spec__c,ASI_MFM_Estimated_Packing_Cost__c,ASI_MFM_Estimated_Packaged_Date__c,ASI_MFM_Packaging_Warehouse__c,
        ASI_MFM_Item_Code_Before_Repack__r.ASI_FOC_Packing_Description__c ,ASI_MFM_Item_Code_After_Repack__r.ASI_CRM_Bottle_Barcode__c,ASI_MFM_Item_Code_After_Repack__r.ASI_CRM_Box_Barcode__c ,ASI_MFM_Item_Code_After_Repack__r.ASI_CRM_Case_Barcode__c,
        ASI_MFM_Item_Code_Before_Repack__r.ASI_CRM_Bottle_Barcode__c,ASI_MFM_Item_Code_Before_Repack__r.ASI_CRM_Box_Barcode__c ,ASI_MFM_Item_Code_Before_Repack__r.ASI_CRM_Case_Barcode__c,
        ASI_MFM_Item_Code_After_Repack__r.ASI_MFM_SKU_Description__c ,ASI_MFM_Item_Code_Before_Repack__r.ASI_MFM_SKU_Description__c,ASI_MFM_Item_Code_Before_Repack__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c,
        ASI_MFM_Item_Code_After_Repack__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c,ASI_MFM_Item_Code_After_Repack__r.ASI_FOC_Packing_Description__c  FROM ASI_MFM_POSM_Return_Request__c  WHERE Id =:PageId];  
        afterNumberOfCases = 0;
        if(null ==onlineRemark.ASI_MFM_Repack_BT_Set_Quantity__c)
        {
          onlineRemark.ASI_MFM_Repack_BT_Set_Quantity__c = 0;
        }
        if(null != onlineRemark.ASI_MFM_Item_Code_After_Repack__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c)
        {
            beforeNumberOfCases = onlineRemark.ASI_MFM_Repack_BT_Set_Quantity__c/onlineRemark.ASI_MFM_Item_Code_After_Repack__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c;
            beforeNumberOfCases = beforeNumberOfCases.setScale(2);
        }
        

        if(null != onlineRemark.ASI_MFM_Item_Code_After_Repack__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c)
        {
            afterNumberOfCases = onlineRemark.ASI_MFM_Repack_BT_Set_Quantity__c/onlineRemark.ASI_MFM_Item_Code_After_Repack__r.ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c;
        }
        afterNumberOfCases = Math.ceil(afterNumberOfCases);

        productCode = onlineRemark.ASI_MFM_Item_Code_Before_Repack__r.ASI_MFM_SKU_Code__c;
        productDesc = onlineRemark.ASI_MFM_Old_Item_English_Name__c;
        if(null != onlineRemark.ASI_MFM_Item_Code_Before_Repack2__c || null != onlineRemark.ASI_MFM_Item_Code_Before_Repack2_Des__c)
        {
           productCode +=','+onlineRemark.ASI_MFM_Item_Code_Before_Repack2__r.ASI_MFM_SKU_Code__c;
           productDesc += ','+ onlineRemark.ASI_MFM_Item_Code_Before_Repack2_Des__c;
           isMultiple = true;
        }
        if(null != onlineRemark.ASI_MFM_Item_Code_Before_Repack3__c || null!= onlineRemark.ASI_MFM_Item_Code_Before_Repack3_Des__c)
        {
           productCode +=','+onlineRemark.ASI_MFM_Item_Code_Before_Repack3__r.ASI_MFM_SKU_Code__c;
           productDesc += ','+ onlineRemark.ASI_MFM_Item_Code_Before_Repack3_Des__c;
          isMultiple = true;
        }
        if(null != onlineRemark.ASI_MFM_Item_Code_Before_Repack4__c || null != onlineRemark.ASI_MFM_Item_Code_Before_Repack4_Des__c)
        {
           productCode +=','+onlineRemark.ASI_MFM_Item_Code_Before_Repack4__r.ASI_MFM_SKU_Code__c;
           productDesc += ','+ onlineRemark.ASI_MFM_Item_Code_Before_Repack4_Des__c;
          isMultiple = true;
        }
         if(null != onlineRemark.ASI_MFM_Item_Code_Before_Repack5__c || null != onlineRemark.ASI_MFM_Item_Code_Before_Repack5_Des__c)
        {
           productCode +=','+onlineRemark.ASI_MFM_Item_Code_Before_Repack5__r.ASI_MFM_SKU_Code__c;
           productDesc += ','+ onlineRemark.ASI_MFM_Item_Code_Before_Repack5_Des__c;
          isMultiple = true;
        }
        //isMultiple = false;
        // productCode =  substringlength(productCode);
        // productDesc =  substringlength(productDesc);

        // 查询审批步骤
        ProcessInstance instance =[SELECT Id,TargetObject.Id, (SELECT Id,CreatedDate,Actor.Name, StepStatus,CreatedBy.name,OriginalActor.Name,ProcessNode.Name, Comments 
         FROM StepsAndWorkitems where (StepStatus ='Approved' OR StepStatus ='Started') order by ProcessNodeId desc) FROM ProcessInstance where TargetObject.Id =:PageId order by CreatedDate desc limit 1];
        dataInfo = new Map<String,Object>();
        dataInfo.put('Approval 1Name', '');
        dataInfo.put('Approval 1Date', '');
        dataInfo.put('Approval 1.1Name', '');
        dataInfo.put('Approval 1.1Date', '');
        dataInfo.put('Approval 2Name', '');
        dataInfo.put('Approval 2Date', '');
        dataInfo.put('Approval 3Name', '');
        dataInfo.put('Approval 3Date', '');
        dataInfo.put('Approval 3.1Name', '');
        dataInfo.put('Approval 3.1Date', '');
        dataInfo.put('Approval 4Name', '');
        dataInfo.put('Approval 4Date', '');
        dataInfo.put('Approval 5Name', '');
        dataInfo.put('Approval 5Date', '');
        dataInfo.put('Approval 6Name', '');
        dataInfo.put('Approval 6Date', '');
        if(null != instance.StepsAndWorkitems)
        {
           for(ProcessInstanceHistory item : instance.StepsAndWorkitems)
           {
              if(item.StepStatus =='Started')
              {
                dataInfo.put('sumbitName1', '');
                dataInfo.put('sumbitName2', '');
                 dataInfo.put('sumbitDate1', '');
                dataInfo.put('sumbitDate2', '');
                if(!onlineRemark.ASI_MFM_Logistic_Application__c)
                {
                  dataInfo.put('sumbitName1', item.Actor.Name);
                  dataInfo.put('sumbitDate1', item.CreatedDate);
                 
                }
                else
                {
                  dataInfo.put('sumbitName2', item.Actor.Name);
                  dataInfo.put('sumbitDate2', item.CreatedDate);
                }
                 
                  
              }
              else
              {
                dataInfo.put(item.ProcessNode.Name+'Name', item.Actor.Name);
                dataInfo.put(item.ProcessNode.Name+'Date', item.CreatedDate);
              }
             
           }
           System.debug(LoggingLevel.INFO, '*** dataInfo: ' + dataInfo);
        }
        return true;   
     
    }

}
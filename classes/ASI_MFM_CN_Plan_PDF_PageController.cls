public class ASI_MFM_CN_Plan_PDF_PageController {

    private final ASI_MFM_Plan__c Plan;
    public List<ASI_MFM_Plan_Line_Item__c> costEstList{get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> lineItemList {get;set;}
    public List<ASI_MFM_PP_Category_A_C__c> PPCategory {get;set;}
    public Integer PPCategoryTempR {get;set;}
    public List<ASI_MFM_PP_Category__c> PPCategoryTemp {get;set;}
    public String verifiedBy{get;set;}
    public decimal costEstTotal{get;set;}
    public ASI_MFM_Plan__c planTemp{get;set;}
    
    
    public string ppc_code {get;set;}
    

    
    public ASI_MFM_CN_Plan_PDF_PageController(ApexPages.StandardController stdController){
        
        this.Plan = (ASI_MFM_Plan__c)stdController.getRecord();
        
        
         //Stella
            //PPCategory = new List<ASI_MFM_PP_Category_A_C__c>();
        
        PPCategory  = [Select ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c from ASI_MFM_PP_Category_A_C__c
                           WHERE ASI_MFM_PP_Category__c=: this.plan.ASI_MFM_PP_Category__c];
         ppc_code = '';                  
        for (ASI_MFM_PP_Category_A_C__c PPCategory_listTemp :PPCategory){
        //PPCategory.add(PPCategory_listTemp );
        ppc_code  += PPCategory_listTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c + ' - ' + PPCategory_listTemp.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c + '<br /> '; 
        }
                    
        //Cost Estimate List
        costEstList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        List<ASI_MFM_Plan_Line_Item__c> costEstListTemp = [select 
        ASI_MFM_List_Item_Description__c,
        ASI_MFM_Quantity__c,
        ASI_MFM_A_C_Code__r.name,
        ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c,
        ASI_MFM_Customer_Name__r.ASI_MFM_Customer_Supplier_Number__c,
        ASI_MFM_Customer_Name__r.Name,
        ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,
        ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Total_Cost__c,
        ASI_MFM_Print_Sequence__c,
        ASI_MFM_Size__c, ASI_MFM_FOC_Size__c,
        
        ASI_MFM_Unit_Cost__c
        //ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,
        //ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c, ASI_MFM_List_Item_Description__c , 
        //ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Description__c,
        //ASI_MFM_Total_Cost__c

        from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: this.Plan.id
        order by ASI_MFM_Print_Sequence__c, name
        ];
        
        
        //costEstTotal = 0;
        for(ASI_MFM_Plan_Line_Item__c cost: costEstListTemp){
           /* if(cost.ASI_MFM_Total_Cost__c != null){ 
                costEstTotal += cost.ASI_MFM_Total_Cost__c;
            }

            if(cost.ASI_MFM_Quantity__c == null){
                cost.ASI_MFM_Quantity__c = 0;
            }
            if(cost.ASI_MFM_Total_Cost__c == null){
                cost.ASI_MFM_Total_Cost__c = 0;
            }
            cost.ASI_MFM_List_Item_Description__c = breakStrings(cost.ASI_MFM_List_Item_Description__c.split(' ', -1), 28);
            */
            costEstList.add(cost);
        }

    }
    
    
    
}
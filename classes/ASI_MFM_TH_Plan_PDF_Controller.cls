public with sharing class ASI_MFM_TH_Plan_PDF_Controller {

	//public String currentHeaderId;

	public ASI_MFM_TH_Plan_PDF_Controller(ApexPages.StandardController controller) {
            this.header = (ASI_MFM_Plan__c)controller.getRecord();
    }
    public id currentHeaderId {set;get;}

	public List<ASI_MFM_Plan_Line_Item__c> details {get;set;}
    public ASI_MFM_Plan__c header{get;set;} 
    public Boolean HaveRegion {get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

	public Decimal totalAmount {get;set;}
	public Decimal totalP1cost {get;set;}
    public Decimal totalP2cost {get;set;}
    public Decimal totalP3cost {get;set;}
   	public Decimal totalP4cost {get;set;}
    public Decimal totalP5cost {get;set;}
    public Decimal totalP6cost {get;set;}
    public Decimal totalP7cost {get;set;}
    public Decimal totalP8cost {get;set;}
    public Decimal totalP9cost {get;set;}
   	public Decimal totalP10cost {get;set;}
    public Decimal totalP11cost {get;set;}
    public Decimal totalP12cost {get;set;}


    
    
    
    public ASI_MFM_TH_Plan_PDF_Controller(){ }

    public boolean init(){
           totalAmount = 0;
        totalP1cost = 0;
        totalP2cost = 0;
        totalP3cost = 0;
        totalP4cost = 0;
        totalP5cost = 0;
        totalP6cost = 0;
        totalP7cost = 0;
        totalP8cost = 0;
        totalP9cost = 0;
        totalP10cost = 0;
        totalP11cost = 0;
        totalP12cost = 0;
    	details= new List<ASI_MFM_Plan_Line_Item__c> ();
        
    	header=[select Name,CreatedBy.name,ASI_MFM_Plan_Raised_Date__c,
    	ASI_MFM_Status__c,ASI_MFM_Plan_Name__c,ASI_MFM_Objectives_Quantified__c,ASI_MFM_Objectives_Others__c,
    	ASI_MFM_Target_distribution_channel__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c,ASI_MFM_Mechanics__c,
    	ASI_MFM_POS_POP__c,ASI_MFM_Media_Support__c
    	 from ASI_MFM_Plan__c where id=: currentHeaderId];




    	 List<ASI_MFM_Plan_Line_Item__c> detailsItem= [select ASI_MFM_TH_Region__c, ASI_MFM_List_Item_Description__c,ASI_MFM_Sub_brand_Code__r.name,
    	  ASI_MFM_A_C_Code__r.name,ASI_MFM_Customer_Name__r.name,ASI_MFM_Unit_Cost__c,ASI_MFM_Quantity__c,
    	  ASI_MFM_Total_Cost__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,
    	  ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,
    	  ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,
    	  ASI_MFM_Month_12_Cost__c
    	 from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c=:currentHeaderId];
        HaveRegion=false;
        for (ASI_MFM_Plan_Line_Item__c planItem : detailsItem){
            if(planItem.ASI_MFM_Month_1_Cost__c>=0){
                totalP1cost += planItem.ASI_MFM_Month_1_Cost__c;
            }
            if(planItem.ASI_MFM_Month_2_Cost__c>=0){
                totalP2cost += planItem.ASI_MFM_Month_2_Cost__c;
            }
            if(planItem.ASI_MFM_Month_3_Cost__c>=0){
                totalP3cost += planItem.ASI_MFM_Month_3_Cost__c;
            }
            if(planItem.ASI_MFM_Month_4_Cost__c>=0){
                totalP4cost += planItem.ASI_MFM_Month_4_Cost__c;
            }
            if(planItem.ASI_MFM_Month_5_Cost__c>=0){
                totalP5cost += planItem.ASI_MFM_Month_5_Cost__c;
            }
            if(planItem.ASI_MFM_Month_6_Cost__c>=0){
                totalP6cost += planItem.ASI_MFM_Month_6_Cost__c;
            }
            if(planItem.ASI_MFM_Month_7_Cost__c>=0){
                totalP7cost += planItem.ASI_MFM_Month_7_Cost__c;
            }
            if(planItem.ASI_MFM_Month_8_Cost__c>=0){
                totalP8cost += planItem.ASI_MFM_Month_8_Cost__c;
                }
            if(planItem.ASI_MFM_Month_9_Cost__c>=0){
                totalP9cost += planItem.ASI_MFM_Month_9_Cost__c;
            }
            if(planItem.ASI_MFM_Month_10_Cost__c>=0){
                totalP10cost += planItem.ASI_MFM_Month_10_Cost__c;
            }
            if(planItem.ASI_MFM_Month_11_Cost__c>=0){
                totalP11cost += planItem.ASI_MFM_Month_11_Cost__c;
                }
            if(planItem.ASI_MFM_Month_12_Cost__c>=0){
                totalP12cost += planItem.ASI_MFM_Month_12_Cost__c;
            }
            
            if(planItem.ASI_MFM_Total_Cost__c>=0){
                totalAmount += planItem.ASI_MFM_Total_Cost__c;
            }
            if(planItem.ASI_MFM_TH_Region__c!='None' && planItem.ASI_MFM_TH_Region__c!=null){
                HaveRegion=true;
            }
            details.add(planItem);
        }
        

    	return true;
    }



}
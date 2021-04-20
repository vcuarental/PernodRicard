public with sharing class ASI_MFM_KR_Plan_PDF_Controller {

	//public String currentHeaderId;

	public ASI_MFM_KR_Plan_PDF_Controller(ApexPages.StandardController controller) {
            this.header = (ASI_MFM_Plan__c)controller.getRecord();
    }
    public id currentHeaderId {set;get;}

	public List<ASI_MFM_Plan_Line_Item__c> details {get;set;}
    public ASI_MFM_Plan__c header{get;set;} 
    public Boolean HaveRegion {get;set;}
    public string BrandName {get;set;}{BrandName='';}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    
    //Approval History
    public Class approvalDetail
    {
        public ProcessInstanceHistory history{get;set;}
        public String title{get;set;}
        public String status{get;set;}
    }//end class

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
    public integer monthDiff{get;set;}
    
    public string channel{get;set;}   //Added by Kammy at 22Mar2016
    
    
    
    public ASI_MFM_KR_Plan_PDF_Controller(){ }

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
    	ASI_MFM_Target_distribution_channel__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c,ASI_MFM_Mechanics__c,ASI_MFM_Currency__c,
    	ASI_MFM_POS_POP__c,ASI_MFM_Media_Support__c, ASI_MFM_Project_Code__r.ASI_MFM_Code__c, ASI_MFM_Project_Code__r.name, ASI_MFM_Promotion_Code__c, ASI_MFM_Objectives__c,
    	ASI_MFM_Plan_Amount__c, ASI_MFM_Channel_Category__c
    	 from ASI_MFM_Plan__c where id=: currentHeaderId];
    	 
        monthDiff =(header.ASI_MFM_End_Date__c).month() + 12 - (header.ASI_MFM_Start_Date__c).month() +12 * ((header.ASI_MFM_End_Date__c).year() - (header.ASI_MFM_Start_Date__c).year() -1) +1;



    	 List<ASI_MFM_Plan_Line_Item__c> detailsItem= [select name,ASI_MFM_TH_Region__c, ASI_MFM_List_Item_Description__c,ASI_MFM_Sub_brand_Code__r.name,
    	  ASI_MFM_A_C_Code__r.name,ASI_MFM_Customer_Name__r.name,ASI_MFM_Unit_Cost__c,ASI_MFM_Quantity__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c,
    	  ASI_MFM_Total_Cost__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.name,
    	  ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,
    	  ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,
    	  ASI_MFM_Month_12_Cost__c, ASI_MFM_Product_Item__r.ASI_KOR_Brand__r.name, ASI_MFM_AccountsAdditionalField__r.Name,
    	  ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,ASI_MFM_AP_Code__r.Name, ASI_MFM_Channel__c,ASI_MFM_Channel__r.name, ASI_MFM_KR_subLedger__r.name,
    	  ASI_MFM_KR_subLedger__r.ASI_TnE_Branch_Channel_Desc__c
    	 from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c=:currentHeaderId];
        HaveRegion=false;
        set<string> brandset =new set<string>();
        for (ASI_MFM_Plan_Line_Item__c planItem : detailsItem){
            
            //Added by Kammy at 22Mar2016 start:
            if(planItem.ASI_MFM_KR_subLedger__r.name != null){
                channel = STRING.valueOf(planItem.ASI_MFM_KR_subLedger__r.name.substring(4,7));
                
                if(channel == '100'){
                    
                    channel = 'ON';
                }
                if(channel == '300'){
                    
                    channel = 'GIFT';
                }
                 if(channel == '400'){
                    
                    channel = 'OFF';
                }
            }
            
            
            //Added by Kammy at 22Mar2016 end.
            
            if(planItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c!=null ){
                if( planItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.name!=null){
                    brandset.add(planItem.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.name);
                }
                
            }
            
                
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
        
        for(string br:brandset){
            BrandName+=br+',';
        }
        // Remove the last chars of the Java String variable
        if(brandset!=null && brandset.size()>0){
            BrandName = BrandName.substring(0, BrandName.length() - 1);
        }
        

    	return true;
    }   
    
    public List<approvalDetail> getapprovalDetails()
    {
        List<approvalDetail> details = new List<approvalDetail>();
        if (details.size() == 0 && currentHeaderId != null)
        {
            List<ProcessInstance> pList = [SELECT Id, 
                                           (SELECT Id,
                                            CreatedDate,
                                            StepStatus,
                                            Comments,
                                            ActorId,
                                            Actor.Name,
                                            OriginalActorId,
                                            OriginalActor.Name
                                            FROM StepsAndWorkitems
                                            ORDER BY CreatedDate DESC,
                                            StepStatus DESC)
                                           FROM ProcessInstance
                                           WHERE TargetObjectId = :currentHeaderId
                                           ORDER BY CreatedDate DESC
                                           Limit 1];
            Set<Id> actoerIdSet = new Set<Id>();
            for (ProcessInstance p:pList){for (ProcessInstanceHistory his:p.StepsAndWorkitems){actoerIdSet.add(his.ActorId);}}
            Map<Id, User> userMap = new Map<Id, User>([Select Id, title From User Where Id In :actoerIdSet]);
            for (ProcessInstance p:pList){Boolean byPassPending = false;
                if(p.StepsAndWorkitems.size() != 0 &&(p.StepsAndWorkitems[0].StepStatus == 'Approved' ||p.StepsAndWorkitems[0].StepStatus == 'Rejected')){byPassPending = true;}
                for (ProcessInstanceHistory his:p.StepsAndWorkitems){
                    if(his.StepStatus != 'Reassigned'&& his.StepStatus != 'NoResponse' &&!(byPassPending && his.StepStatus == 'Pending')){approvalDetail detail = new approvalDetail();
                        if(his.StepStatus == 'Removed')
                            detail.status = 'Recalled';
                        else if(his.StepStatus == 'Started')
                            detail.status = 'Submitted';
                        else
                            detail.status = his.StepStatus;
                            
                        detail.title = userMap.get(his.ActorId).title;
                        detail.history = his;
                        details.add(detail);
                    }//end if
                }//end for
            }//end for
        }//end if
        return details;
    }//end method: getapprovalDetails



}
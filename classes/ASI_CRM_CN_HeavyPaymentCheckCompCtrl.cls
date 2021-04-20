/**
 * @File Name          : ASI_CRM_CN_HeavyPaymentCheckCompCtrl.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/7/2020, 1:55:25 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    5/7/2020   pengchen@bluelinksys.com     Initial Version
**/
public class ASI_CRM_CN_HeavyPaymentCheckCompCtrl {
    public ASI_TH_CRM_PaymentRequest__c PaymentRequest {set;get;}
    public string PageId {set;get;}
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> SuccessCheckPointList2nd {set;get;}  {SuccessCheckPointList2nd = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> FailedCheckPointList2nd {set;get;} {FailedCheckPointList2nd = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}

    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> SuccessCheckPointList {set;get;}  {SuccessCheckPointList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}
    public List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> FailedCheckPointList {set;get;} {FailedCheckPointList = new List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>();}

    public boolean showCN {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = initPage();} return dummyVar; } set; }
    public string strPDF {set;get;}
    public String groupStr {get;set;}
    public boolean AdorAbove {set;get;}{AdorAbove=false;}
    
    public ASI_CRM_CN_HeavyPaymentCheckCompCtrl(ApexPages.StandardController controller) {
        this.PaymentRequest = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();    
    }
    public ASI_CRM_CN_HeavyPaymentCheckCompCtrl(){}
    
    public Boolean DisplaySuccessCheckPointPart {get;set;}{DisplaySuccessCheckPointPart=true;}
    public Boolean DisplayFailedCheckPointPart {get;set;}{DisplayFailedCheckPointPart=true;}
    
    public boolean initPage() {
        showCN = USerInfo.getLanguage()=='zh_CN';
        if(this.PaymentRequest != null)
            PageId = PaymentRequest.id;
        list <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new list <ASI_TH_CRM_PaymentRequest__c>();

        if (String.isNotBlank(PageId)) {
            HeaderList = [SELECT id, name, Owner.Name, ASI_CRM_RVP_Approval__c,ASI_CRM_Total_Actual_Amount__c,ASI_CRM_CN_Payable_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c, ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,OwnerId
                          FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
                if (HeaderList.size()> 0){
                    this.PaymentRequest = HeaderList[0]; 
                }
            if (PaymentRequest.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return init2nd();
            } else {
                return init();
            }
        }
        return true;
    }
    
    public boolean init2nd(){
       
        // showCN = USerInfo.getLanguage()=='zh_CN';
        // if(this.PaymentRequest != null)
        //     PageId = PaymentRequest.id;
        // list <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new list <ASI_TH_CRM_PaymentRequest__c>();
        
        // //Get Header information
        // if (PageId != null){
        //     HeaderList = [SELECT id, name, Owner.Name, ASI_CRM_RVP_Approval__c,ASI_CRM_Total_Actual_Amount__c,ASI_CRM_CN_Payable_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c, ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,OwnerId
        //                   FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
            
        // }
        // if (HeaderList.size()> 0){
        //     this.PaymentRequest = HeaderList[0]; 
        // }
        if (strPDF == '0'){
            set<Id> userIds = new set<Id>();
            for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : PaymentRequest.id]){
                userIds.add(piw.ActorId);
            }
            groupStr = checkApprover2nd(userIds);
        } else if (strPDF == '2'){
            set<Id> userIds = new set<Id>();
            userIds.add(PaymentRequest.OwnerId);
            groupStr = checkApprover2nd(userIds);
        } else {
            groupStr = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.UserOrGroupInit();
        }
         // checkApprover();
        List<ASI_Attachment__c> AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c where ASI_CRM_Payment_Request__c = :PaymentRequest.Id ];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){ 
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                JsonString = JsonString.replaceAll('&lt;','<');
                JsonString = JsonString.replaceAll('&gt;','>');
                List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> CheckPointResultList =(List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>.class);
                if(att.ASI_CRM_Type__c=='CheckPoint-Success'){
                    SuccessCheckPointList2nd=CheckPointResultList;
                }else if(att.ASI_CRM_Type__c=='CheckPoint-Failed'){
                    FailedCheckPointList2nd=CheckPointResultList;
                }
            }
        }
        
        
        if(FailedCheckPointList2nd.size()==0){
            DisplayFailedCheckPointPart=false;
        }else{
              for(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData TempinterimData:FailedCheckPointList2nd){
                if(TempinterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') && !AdorAbove){
                    TempinterimData.DisplayToUser=false;
                }else{
                    TempinterimData.DisplayToUser=true;
                }
            }
        }
        
        
        if(SuccessCheckPointList2nd.size()==0){
            DisplaySuccessCheckPointPart=false;
        }else{
             for(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData TempinterimData:SuccessCheckPointList2nd){
                if(TempinterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') && !AdorAbove){
                    TempinterimData.DisplayToUser=false;
                }else{
                    TempinterimData.DisplayToUser=true;
                }
            }
        }
        
        
        return true;
    }

    public boolean init(){
       
        // showCN = USerInfo.getLanguage()=='zh_CN';
        // if(this.PaymentRequest != null)
        //     PageId = PaymentRequest.id;
        // list <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new list <ASI_TH_CRM_PaymentRequest__c>();
        
        // //Get Header information
        // if (PageId != null){
        //     HeaderList = [SELECT id, name, Owner.Name, ASI_CRM_RVP_Approval__c,ASI_CRM_Total_Actual_Amount__c,ASI_CRM_CN_Payable_Amount__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c, ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c
        //                   FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
            
        // }
        // if (HeaderList.size()> 0){
        //     this.PaymentRequest = HeaderList[0]; 
        // }
         checkApprover();
        List<ASI_Attachment__c> AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c where ASI_CRM_Payment_Request__c = :PaymentRequest.Id ];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){ 
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                JsonString = JsonString.replaceAll('&lt;','<');
                JsonString = JsonString.replaceAll('&gt;','>');
                List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData> CheckPointResultList =(List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData>.class);
                if(att.ASI_CRM_Type__c=='CheckPoint-Success'){
                    SuccessCheckPointList=CheckPointResultList;
                }else if(att.ASI_CRM_Type__c=='CheckPoint-Failed'){
                    FailedCheckPointList=CheckPointResultList;
                }
            }
        }
        
        
        if(FailedCheckPointList.size()==0){
            DisplayFailedCheckPointPart=false;
        }else{
              for(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData TempinterimData:FailedCheckPointList){
                if(TempinterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') && !AdorAbove){
                    TempinterimData.DisplayToUser=false;
                }else{
                    TempinterimData.DisplayToUser=true;
                }
            }
        }
        
        
        if(SuccessCheckPointList.size()==0){
            DisplaySuccessCheckPointPart=false;
        }else{
             for(ASI_CRM_CN_HeavyCheckPointResultCtrl.interimData TempinterimData:SuccessCheckPointList){
                if(TempinterimData.SegmentationCriteria.ASI_CRM_Financial_Indicator__c.contains('ROI') && !AdorAbove){
                    TempinterimData.DisplayToUser=false;
                }else{
                    TempinterimData.DisplayToUser=true;
                }
            }
        }
        
        
        return true;
    }
    
    // public void checkApprover(){
    //     AdorAbove = false;
    //     set<Id> actorIds = new set<Id>();
    //     for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : PaymentRequest.id]){
    //         actorIds.add(piw.ActorId);
    //     }
    //     list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];
    //     if(gms.size()>0)
    //         AdorAbove = true;
    // }
    // 
    public void checkApprover(){
        AdorAbove = false;
        set<Id> actorIds = new set<Id>();
        for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : PaymentRequest.id]){
            actorIds.add(piw.ActorId);
        }
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];
        if(gms.size()>0)
            AdorAbove = true;
    }

    public String checkApprover2nd(Set<Id> userIds){
        // AdorAbove = false;
        // list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];

        String groupAName = 'ASI_CN_GS_Commercial_team';
        String groupBName = 'ASI_CN_Commercial_team_ex_GS';
        String groupCName = 'ASI_CN_Finance';
        String groupDName = 'ASI_CN_HQ_Management';

        String belongGroup = 'Group ';

        if (userIds != null && !userIds.isEmpty()) {
            Set<String> groupNames = new Set<String>();
            for (GroupMember gm: [SELECT group.name,
                                         group.DeveloperName
                                  FROM GroupMember
                                  WHERE UserOrGroupId IN: userIds]) {
                groupNames.add(gm.group.DeveloperName);
            }
            if (groupNames.contains(groupAName)) {
                belongGroup += 'A';
            }
            if (groupNames.contains(groupBName)) {
                belongGroup += 'B';
            }
            if (groupNames.contains(groupCName)) {
                belongGroup += 'C';
            }
            if (groupNames.contains(groupDName)) {
                belongGroup += 'D';
            }
        }
        
        return belongGroup;
        // if(gms.size()>0)
        //     AdorAbove = true;
    }
    
}
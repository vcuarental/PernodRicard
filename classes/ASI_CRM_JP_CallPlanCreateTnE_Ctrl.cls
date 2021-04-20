/*********************************************************************************
 * Name: ASI_CRM_JP_CallPlanCreateTnE_Ctrl
 * Description: Controller class for ASI_CRM_JP_CallPlanCreateTnE_Page
 * Test Class: ASI_CRM_JP_CallPlanCreateTnE_CtrlTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/05/2018       Hugo Cheung             Created          
 * 08/10/2019       Wilken Lee              [WL 1.0] Default Tax Rate in TnE Detail from Call Detail
*/
public class ASI_CRM_JP_CallPlanCreateTnE_Ctrl {
    //Parameter from VF Page Name
    private final static String CALL_PLAN_ID   = 'id';
    private final static String SELECT_DETAIL_ID_SET_JSON = 'selectDetailIdSetJson';
    
    //Call Plan Detail Record
    private ASI_CRM_Call_Plan__c callPlan {get; set;}
    private Map<Id, ASI_CRM_Call_Detail__c> callPlanDetailMap {get; set;}
    
    //Error Message
    public String errorMsg {get; set;}
    
    //JSON String for VF Page
    public String callPlanDetailListJson {get {return toJsonString(callPlanDetailMap.values());}}
    
    public ASI_CRM_JP_CallPlanCreateTnE_Ctrl(ApexPages.StandardController standardController) {
        Id callPlanId = ApexPages.currentPage().getParameters().get(CALL_PLAN_ID);
        
        callPlan = retrieveCallPlan(callPlanId);
        callPlanDetailMap = new Map<Id, ASI_CRM_Call_Detail__c>(retrieveCallPlanDetailList(callPlanId));
    }

    /***************
    View Action Handler
    ***************/
    public PageReference createTnE() {
        errorMsg = '';
        
        if(String.isBlank(callPlan.ASI_CRM_TnE_Number__c)) errorMsg = Label.ASI_CRM_JP_Call_Plan_EmptyTnENumberError;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String selectDetailIdSetJson  = params.get(SELECT_DETAIL_ID_SET_JSON);
        System.debug(selectDetailIdSetJson);
        List<String> selectDetailIdSet = (List<String>) fromJsonString(selectDetailIdSetJson, List<String>.class);
        
        List<ASI_CRM_Call_Detail__c> selectDetailList = new List<ASI_CRM_Call_Detail__c>();
        for(String selectDetailId : selectDetailIdSet) {
            if(callPlanDetailMap.containsKey(selectDetailId) == false || 
               callPlanDetailMap.get(selectDetailId).ASI_CRM_Payment_Option__c != callPlan.ASI_CRM_TnE_Number__r.ASI_TnE_Payment_Option__c) {
                    errorMsg = Label.ASI_CRM_JP_Call_Plan_PmtOptionNotMatch;
            } else {
                selectDetailList.add(callPlanDetailMap.get(selectDetailId));
            }
        }
        
        if(String.isNotBlank(errorMsg)) return null;
        
        Map<Id, ASI_TnE_ClaimDetail__c> callDetailTnEMap = new Map<Id, ASI_TnE_ClaimDetail__c>();
        for(ASI_CRM_Call_Detail__c selectDetail : selectDetailList) {
            ASI_TnE_ClaimDetail__c tneDetail            = new ASI_TnE_ClaimDetail__c();
            tneDetail.ASI_TnE_ClaimHeader__c            = callPlan.ASI_CRM_TnE_Number__c;
            tneDetail.ASI_TnE_Expense_Category__c       = selectDetail.ASI_CRM_Tax_Routing__r.ASI_JP_TnE_Expense_Category__c;
            tneDetail.ASI_TnE_Expense_Classification__c = selectDetail.ASI_CRM_Tax_Routing__c;
            tneDetail.ASI_TnE_Receipt_Date__c           = callPlan.ASI_CRM_TnE_Number__r.ASI_TnE_Due_Date_Mapping__r.ASI_JP_TnE_Period_To__c;
            tneDetail.ASI_TnE_Receipt_Amount__c         = selectDetail.ASI_CRM_Actual_Amount__c;
            tneDetail.ASI_TnE_Total_Number_Pax__c       = selectDetail.ASI_CRM_Total_Number_of_Attendees__c;
            tneDetail.ASI_TnE_Attendee_Name__c          = selectDetail.ASI_CRM_JP_All_Attendees__c;
            tneDetail.ASI_TnE_Details_of_Expense__c     = ((datetime)selectDetail.ASI_CRM_Visit_Date_Formula__c).format('yyyy-MM-dd') 
                                                        + ' ' + selectDetail.ASI_CRM_Customer__r.Name;
            tneDetail.RecordTypeId                      = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_JP_TnE_Claim_Detail');
            tneDetail.ASI_TnE_Tax_Area__c               = selectDetail.ASI_CRM_Tax_Rate_Area__c; //WL 1.0
            tneDetail.ASI_TnE_Tax_Rate__c               = selectDetail.ASI_CRM_Tax_Rate__c; //WL 1.0
            
            /*[WL 1.0] BEGIN*/
            if (selectDetail.ASI_CRM_Tax_Rate_Area__c == 'CP0')
                tneDetail.ASI_TnE_BC__c = 'A';
            else if (selectDetail.ASI_CRM_Tax_Rate_Area__c == 'CP8')
                tneDetail.ASI_TnE_BC__c = 'B';
            else if (selectDetail.ASI_CRM_Tax_Rate_Area__c == 'CP8R')
                tneDetail.ASI_TnE_BC__c = 'C';
            else if (selectDetail.ASI_CRM_Tax_Rate_Area__c == 'CP10')
                tneDetail.ASI_TnE_BC__c = 'D';
            /*[WL 1.0] END*/
            
            callDetailTnEMap.put(selectDetail.Id, tneDetail);
        }
        
        insert callDetailTnEMap.values();
        
        for(ASI_CRM_Call_Detail__c selectDetail : selectDetailList) {
            selectDetail.ASI_CRM_Status__c = 'TnE Created';
            selectDetail.ASI_CRM_Sys_Call_Plan_TnE__c = null;
            selectDetail.ASI_CRM_TnE_Detail_No__c = callDetailTnEMap.get(selectDetail.Id).Id;
        }
        update selectDetailList;
        
        PageReference planPage = new ApexPages.StandardController(callPlan).view();
        planPage.setRedirect(true);
        return planPage;
    }
    
    public PageReference cancel() {
        PageReference planPage = new ApexPages.StandardController(callPlan).view();
        planPage.setRedirect(true);
        return planPage;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private ASI_CRM_Call_Plan__c retrieveCallPlan(Id callPlanId) {
        String query = 'SELECT Id, ASI_CRM_TnE_Number__c, ASI_CRM_TnE_Number__r.ASI_TnE_Payment_Option__c '
                     + ', ASI_CRM_TnE_Number__r.ASI_TnE_Due_Date_Mapping__r.ASI_JP_TnE_Period_To__c '
                     + 'FROM ASI_CRM_Call_Plan__c '
                     + 'WHERE Id = :callPlanId ';
        
        List<ASI_CRM_Call_Plan__c> callPlanList = (List<ASI_CRM_Call_Plan__c>) Database.query(query);
        
        return callPlanList.size() == 1 ? callPlanList.get(0) : null;
    }
    
    private List<ASI_CRM_Call_Detail__c> retrieveCallPlanDetailList(Id callPlanId) {
        String query = 'SELECT Id, Name, ASI_CRM_Customer__c, ASI_CRM_Customer__r.Name, ASI_CRM_Visit_Date_Formula__c '
                     + ', ASI_CRM_JP_All_Attendees__c, ASI_CRM_Total_Number_of_Attendees__c, ASI_CRM_Tax_Routing__c, ASI_CRM_Tax_Routing__r.Name '
                     + ', ASI_CRM_Tax_Routing__r.ASI_JP_TnE_Expense_Category__c, ASI_CRM_Actual_Amount__c, ASI_CRM_Payment_Option__c, ASI_CRM_Tax_Rate_Area__c, ASI_CRM_Tax_Rate__c ' //WL 1.0
                     + 'FROM ASI_CRM_Call_Detail__c '
                     + 'Where ASI_CRM_Sys_Call_Plan_TnE__c = :callPlanId';
        
        return (List<ASI_CRM_Call_Detail__c>) Database.query(query);
    }
    
    /***************
    Tools Function
    ***************/
    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private List<Object> fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return (List<Object>) System.JSON.deserialize(jsonString, apexType);
    }
}
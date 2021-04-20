Public With Sharing Class ASI_CRM_TW_VPDTodayCtrl{
    Public ASI_HK_CRM_Visitation_Plan__c[] MonthVP{set;get;}
    Public List<ASI_HK_CRM_Visitation_Plan_Detail__c> VPD{set;get;}
    Public List<ASI_HK_CRM_Visitation_Plan_Detail__c> VPDToday{set;get;}
    public boolean ShowMsg{set;get;}
    public boolean showCN {set;get;}
    public boolean showMerDaily {set;get;}
    public ASI_CRM_TW_Settings__c customSettingTW {get;set;}
   
    public String MonthVPId{get;set;}
    public String HMVPDId {get;set;}
    public String VPmonth{get;set;}
    public String VPyear{get;set;}
    public String MonthVPName{get;set;}
    public String keyPrefix {get;set;}
    ApexPages.StandardController controller;
    
    public ASI_CRM_TW_VPDTodayCtrl(ApexPages.StandardController controller) {
        this.controller = controller;
        showMerDaily = false; //default Sales Call Report
        VPDToday = new list <ASI_HK_CRM_Visitation_Plan_Detail__c>();  
        VPD =  [SELECT Id,Name,ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName,ASI_HK_CRM_Visitation_Plan__c, ASI_HK_CRM_Account__c,ASI_HK_CRM_Account__r.Name, ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c,ASI_HK_CRM_Visit_Date__c, ASI_CRM_Cancel_Reason__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c  
        WHERE ASI_HK_CRM_Visit_Date__c = TODAY and ASI_HK_CRM_Visitation_Plan__r.OwnerId = :UserInfo.getUserID() AND (ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName  =  'ASI_CRM_TW_Visitation_Plan' OR ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName = 'ASI_CRM_TW_Merchandiser_Visitation_Plan') ];
       
        Date today = date.today();    

        for ( ASI_HK_CRM_Visitation_Plan_Detail__c v :VPD){
            if (v.ASI_HK_CRM_Visit_Date__c == today)
                VPDToday.add(v);
        } 
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vToday :VPDToday){
            if(vToday.ASI_HK_CRM_Visitation_Plan__r.recordtype.DeveloperName == 'ASI_CRM_TW_Merchandiser_Visitation_Plan'){
                showMerDaily=true;
                break;
            }
        }
       
        customSettingTW = [SELECT id, ASI_CRM_TW_HomepageToVPDId__c FROM ASI_CRM_TW_Settings__c];
        if(customSettingTW != null) {          
            HMVPDId = customSettingTW.ASI_CRM_TW_HomepageToVPDId__c;
            /*Get custom object prefix*/
            Schema.DescribeSObjectResult r = ASI_HK_CRM_Visitation_Plan_Detail__c.sObjectType.getDescribe();
            keyPrefix = r.getKeyPrefix();
            /*Get system month abbr*/
            Map<Integer, String> m1 = new Map<Integer, String>();
            m1.put(01,'January');
            m1.put(02, 'February');
            m1.put(03, 'March');
            m1.put(04, 'April');
            m1.put(05, 'May');
            m1.put(06, 'June');
            m1.put(07, 'July');
            m1.put(08, 'August');
            m1.put(09, 'September');
            m1.put(10, 'October');
            m1.put(11, 'November');
            m1.put(12, 'December');
            
            Integer month = Date.today().month();
            string thismonth = m1.get(month);
            VPmonth = thismonth.left(3) ;
            
            /*Get system year*/
            Integer year = Date.today().year();
            VPyear = string.valueof(year); 
            
            /*Locate ASI_HK_CRM_Visitation_Plan__c this year this month this user*/                
            MonthVP =[SELECT Id,Name from ASI_HK_CRM_Visitation_Plan__c WHERE OwnerId= :UserInfo.getUserID() AND ASI_HK_CRM_Visitation_Plan__c.ASI_HK_CRM_Year__c =:VPyear AND ASI_HK_CRM_Visitation_Plan__c.ASI_HK_CRM_Month__c=:thismonth LIMIT 1];
            if (MonthVP.size()>0){
                MonthVPId = MonthVP[0].id;
                MonthVPName = MonthVP[0].Name;          
            }
        }
       
        //show message if there's no records
        if(VPDToday.size()>0 && VPDToday !=null){
            ShowMsg = false;
        }else{
            ShowMsg = true;
        }
        // for TW user - render pageblock 
        if (USerInfo.getLanguage()=='zh_TW'){      
           showCN =true;
        }else{
            showCN  = false;
        }
    }
    
    public PageReference redirectMassCancelPage(){
        return new PageReference('/apex/ASI_CRM_TW_VPDTodayMassCancel_Page');
    }
}
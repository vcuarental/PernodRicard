/*********************************************************************************
 * Name: ASI_CRM_KR_VisitationPlanCalendarCtl
 * Description: Controller class for ASI_CRM_KR_VisitationPlanHomePage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-03-12       Tony Ren                created
 */
 
 global without sharing class ASI_CRM_KR_VisitationPlanHomeCtrl {
     
    public transient List<ASI_KOR_Visitation_Plan_Detail__c> DetailLineList {get;set;}{ DetailLineList = new  List<ASI_KOR_Visitation_Plan_Detail__c> ();}
    public String DetailLineJSON {get{return JSON.serialize(DetailLineList);}}
    
    public transient List<ASI_KR_Setting__c> ColorList {get;set;}{ ColorList = new  List<ASI_KR_Setting__c> ();}
    public String ColorListJSON {get{return JSON.serialize(ColorList);}}
    public Transient Map<string,string> ColorMap {get;set;} {ColorMap= new Map<string,string>();}
    
    public Date firstDate  {set;get;}
    public Date MonthEnd  {set;get;}
    
     public ASI_CRM_KR_VisitationPlanHomeCtrl(){
         
         Date SelectedDate =  Date.today(); 
         // Get Start date of this month
         firstDate = SelectedDate.toStartOfMonth();
         // Get end date of this month
         MonthEnd= firstDate.addDays(date.daysInMonth(SelectedDate.year() , SelectedDate.month())  - 1);
         DetailLineList=[SELECT Id, Name, ASI_CRM_KR_Visit_Date_Time_From__c,ASI_CRM_KR_Visit_Date_Time_To__c,ASI_KOR_Wholesaler__r.ASI_KOR_Grade__c, ASI_KOR_Wholesaler__r.ASI_KOR_Venue_Pillar__c, ASI_KOR_Status__c,ASI_KOR_Subject__c,ASI_KOR_Cancellation_Reason__c,ASI_CRM_KR_Cancel_Type__c,ASI_KOR_Customer_Code__c,ASI_KOR_Account_Address__c,ASI_KOR_Visit_Date__c,ASI_KOR_Wholesaler__c,ASI_KOR_Wholesaler__r.Name,ASI_KOR_Wholesaler__r.RecordType.DeveloperName FROM ASI_KOR_Visitation_Plan_Detail__c WHERE ASI_KOR_Visitation_Plan__r.OwnerId =: System.UserInfo.getUserId() and ASI_KOR_Visit_Date__c >=: firstDate and ASI_KOR_Visit_Date__c<=:MonthEnd ];
         
         //Get Color List 
         ColorList = new  List<ASI_KR_Setting__c> ();
         ColorMap= new Map<string,string>();
         for(ASI_KR_Setting__c colorset: ASI_KR_Setting__c.getAll().values()){
             if(colorset.ASI_CRM_Type__c=='VisitationPlan'){
                 ColorList.add(colorset);
                 ColorMap.put(colorset.Name, colorset.ASI_CRM_Color__c);
             }
         } 
     }
    
    
    //------------------------------------------Get User Info-----------------------------------------------------
    // Start:  query 5 level in role under current user
    String[] users = new String[]{};
    
    global String[] getUsers(){
        return users;
    }           
    
    global void setUsers(String[] users){
        this.users = users;
    }
    
    
    global List<SelectOption> getUserItems(){
        List<SelectOption> useroptions = new List<SelectOption>();
        
        Map<String,String> LUserDisplayName = findAllUsers(System.UserInfo.getName(),System.UserInfo.getUserId(),System.UserInfo.getUserRoleID());
        for(String key : LUserDisplayName.keySet()){
        //for (String user : LUserDisplayName){    if(user != null)               
            
                useroptions.add(new SelectOption(key, LUserDisplayName.get(key)));
        }                      
        return useroptions;
    }
      // End:to query 5 level in role under current user
    
    // to query 5 level in role under current user
    global static Map<String,String> findAllUsers(String currentUserName, String UserId, String currentUserRoleID){
        // Select all user
        Map<String,String>  LUserDisplayName = new Map<String,String>();// {currentUserName}
        LUserDisplayName.put(UserId,currentUserName);
        Set<String> SRoleID = new Set<String>{currentUserRoleID};
        Integer NumofLv = 5;
        for(integer i = 0; i < 5; i++){
            for(UserRole r : [SELECT id, name FROM UserRole WHERE ParentRoleID IN :SRoleID]){
                SRoleID.add(r.id);
            }
        }
        for(User u : [Select id, name, userRoleID from user where (userRoleID != :currentUserRoleID and IsActive=TRUE and  userRoleID  IN :SRoleID) order by name limit 100]){
            //LUserDisplayName.add(u.name);
            LUserDisplayName.put(u.id,u.name);
        }

        for(User u : [Select id, name, userRoleID from user where managerId =: UserId AND IsActive=TRUE order by name limit 100]){
            //LUserDisplayName.add(u.name);
            LUserDisplayName.put(u.id,u.name);
        }
        
        return LUserDisplayName;
    }
    
     //------------------------------------------Get User Info End -----------------------------------------------------
    public static datetime convertDatetoDateTime(Date inputDate){
        return datetime.newInstance(inputDate.year(), inputDate.month(),inputDate.day());
    }
    
    
    
    global class VisitationPlanDetail {  
        public String startStr {get;set;}
        public String endStr   {get;set;}
        public ASI_KOR_Visitation_Plan_Detail__c VisitationDetail {get;set;}
        
        public VisitationPlanDetail (ASI_KOR_Visitation_Plan_Detail__c vp){
            this.VisitationDetail=vp;
            this.startStr=vp.ASI_KOR_Visit_Date__c!=null? convertDatetoDateTime(vp.ASI_KOR_Visit_Date__c).format('YYYY-MM-dd'):null;
            this.endStr=vp.ASI_KOR_Visit_Date__c!=null? convertDatetoDateTime(vp.ASI_KOR_Visit_Date__c+1).format('YYYY-MM-dd'):null;
        }
        
        
    }
    
        
    global class PublicHolidays {  
        public String startStr {get;set;}
        public String endStr   {get;set;}
        public ASI_CRM_Holiday__c publicHoliday {get;set;}
        
        public PublicHolidays (ASI_CRM_Holiday__c hol){
            this.publicHoliday=hol;
            
            this.startStr=hol.ASI_CRM_Date_From__c!=null? convertDatetoDateTime(hol.ASI_CRM_Date_From__c).format('YYYY-MM-dd'):null;
            this.endStr=hol.ASI_CRM_Date_To__c!=null? convertDatetoDateTime(hol.ASI_CRM_Date_To__c).format('YYYY-MM-dd'):null;
        }
        
        
    }
      
   
   
     
    //RemoteAction for retreive KR holidays
    @RemoteAction
    global static List<PublicHolidays> findHolidays(string whereClause){
        List<PublicHolidays> holidays = new list<PublicHolidays>();
        String soql='SELECT Id, Name, ASI_CRM_Date_From__c, ASI_CRM_Date_To__c, ASI_CRM_Holiday_Type__c,RecordType.DeveloperName FROM ASI_CRM_Holiday__c ';
        for(ASI_CRM_Holiday__c  holi :Database.query(soql+whereClause)){
           
            holidays.add(new PublicHolidays(holi));
        } 
        return holidays;
    }   
    
     
    //Get data from ASI_KOR_Visitation_Plan_Detail__c 
     @RemoteAction 
     global static List<VisitationPlanDetail> findVisitationPlanDetail(string whereClause,string Laststatement ,string AddOn){
         
        Date SelectedDate =  Date.today(); 
        // Get Start date of this month
        Date firstDate = SelectedDate.toStartOfMonth();
        String startDatestr = DateTime.newInstance(firstDate.year(),firstDate.month(),firstDate.day(), 0,0,0).format('yyyy-MM-dd');
         // Get end date of this month
        Date MonthEnd= firstDate.addDays(date.daysInMonth(SelectedDate.year() , SelectedDate.month())  - 1);
        String EndDatestr = DateTime.newInstance(MonthEnd.year(),MonthEnd.month(),MonthEnd.day(), 0,0,0).format('yyyy-MM-dd');
        
        
         List<VisitationPlanDetail> VisitationPlanDetailList= new List<VisitationPlanDetail>();
         
         String soql='SELECT Id, Name,ASI_CRM_KR_Visit_Date_Time_From__c,ASI_CRM_KR_Visit_Date_Time_To__c,ASI_KOR_Wholesaler__r.ASI_KOR_Grade__c, ASI_KOR_Wholesaler__r.ASI_KOR_Venue_Pillar__c, RecordType.DeveloperName,ASI_KOR_Cancellation_Reason__c,ASI_CRM_KR_Cancel_Type__c,ASI_KOR_Customer_Code__c,ASI_KOR_Account_Address__c,ASI_KOR_Subject__c,ASI_KOR_Status__c,ASI_KOR_Visit_Date__c,ASI_KOR_Wholesaler__c,ASI_KOR_Wholesaler__r.Name FROM ASI_KOR_Visitation_Plan_Detail__c ';
         
         String whereClauseAddOn='';
         if(AddOn == 'exclude'){
             whereClauseAddOn += '  and ( (ASI_KOR_Visit_Date__c > ' + EndDatestr + ' ) OR( ASI_KOR_Visit_Date__c <'+startDatestr+')) '; 
         }
         
         system.debug('Test SQL: '+soql+whereClause+whereClauseAddOn+ Laststatement);
         for(ASI_KOR_Visitation_Plan_Detail__c vp:Database.query(soql+whereClause+whereClauseAddOn+ Laststatement )){
             VisitationPlanDetailList.add(new VisitationPlanDetail(vp));
         }
         
         return VisitationPlanDetailList;
     }
   
   
     
     

}
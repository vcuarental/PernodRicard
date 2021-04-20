public class ASI_MFM_KR_BudgetsUploadController {
    public Map<String, interimData> allBudgetSetupMap {get;set;}{ allBudgetSetupMap = new Map<String, interimData>();}
    public transient String Fiscalyear {get;set;}{Fiscalyear=null;}
    public static List<String> BudgetType {get { return new List<String>{'Original Budget', 'Budget','LE1', 'LE2', 'LE3' ,'LE4'};}}
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public String Msg {get;set;}
    public string Activatetype {get;set;}
    
    public List<ASI_MFM_Budget_Setup__c> NewRecord {get;set;} {NewRecord = new List<ASI_MFM_Budget_Setup__c>();}
    public ASI_MFM_KR_BudgetsUploadController(){
        init();
        NewRecord = new List<ASI_MFM_Budget_Setup__c>();
    }
    
	public void init() {
        //construct current fiscal year
        string NowFY='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            NowFY=NowFY+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            NowFY=NowFY+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        Fiscalyear=NowFY;
        
        // construct new map 
        allBudgetSetupMap = new Map<String, interimData>();
        
        //Get current budget Type
        list<ASI_MFM_Budget_Setup__c> allBSList=[select id,name,ASI_MFM_Active__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c,ASI_MFM_Type__c,ASI_MFM_Fiscal_Year__c from ASI_MFM_Budget_Setup__c where RecordType.DeveloperName='ASI_MFM_KR_Budget_Setup' and ASI_MFM_Fiscal_Year__c =:Fiscalyear order by name];
        
        
        integer idx=1;
        for(ASI_MFM_Budget_Setup__c bs:allBSList){
            interimData temp= new interimData();
            temp.bs =bs;
            //the first one set readonly  
            if(idx==1){
                temp.SetReadonly=true;
            }
            idx++;
            if(bs.ASI_MFM_Active__c){
               Activatetype=bs.ASI_MFM_Fiscal_Year__c+bs.ASI_MFM_Type__c;
            }
            
            allBudgetSetupMap.put(bs.id,temp);
        }
        
        //Cannot get data from Database
        if(allBSList.size()<6){
            for(Integer i = 0; i < 6; i++){
                interimData tempdata= new interimData();
                ASI_MFM_Budget_Setup__c temp = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c=BudgetType[i],ASI_MFM_Fiscal_Year__c=Fiscalyear);
                if(i==0){
                    date StartDateOfYear=Date.newInstance(2000+integer.valueOf(Fiscalyear.substring(2,4)), 7, 1);
                    temp.ASI_MFM_Start_Date__c=StartDateOfYear;
                    tempdata.SetReadonly=true;
                }
                if(i==5){
                    date EndDateOfYear=Date.newInstance(2000+integer.valueOf(Fiscalyear.substring(4,6)), 6,30);
                    temp.ASI_MFM_End_Date__c=EndDateOfYear;
                }
                
                tempdata.bs =temp;
                allBudgetSetupMap.put(String.valueOf(i),tempdata);
            }
            
        }
        
    }//End init
    
    
    
    
    public void changefy() {
        UpsertPermission=true;
        Msg='';
        allBudgetSetupMap = new Map<String, interimData>();
        //Get data from database
        list<ASI_MFM_Budget_Setup__c> allBSList=[select id,name,ASI_MFM_Active__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c,ASI_MFM_Type__c,ASI_MFM_Fiscal_Year__c from ASI_MFM_Budget_Setup__c where RecordType.DeveloperName='ASI_MFM_KR_Budget_Setup' and ASI_MFM_Fiscal_Year__c =:Fiscalyear order by name];
        
        if(allBSList.size()==0){
            for(Integer i = 0; i < 6; i++){
                interimData tempdata= new interimData();
                ASI_MFM_Budget_Setup__c temp = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c=BudgetType[i],ASI_MFM_Fiscal_Year__c=Fiscalyear);
                //For the first one data: 7.1
                if(i==0){
                    date StartDateOfYear=Date.newInstance(2000+integer.valueOf(Fiscalyear.substring(2,4)), 7, 1);
                    temp.ASI_MFM_Start_Date__c=StartDateOfYear;
                    tempdata.SetReadonly=true;
                }
                
                //For the last One data, the end date should be 6.30
                if(i==5){
                    date EndDateOfYear=Date.newInstance(2000+integer.valueOf(Fiscalyear.substring(4,6)), 6,30);
                    temp.ASI_MFM_End_Date__c=EndDateOfYear;
                }
                
                tempdata.bs =temp;
                allBudgetSetupMap.put(String.valueOf(i),tempdata);
            }
        }else{ 
            // exist in database
            integer idx=1;
            for(ASI_MFM_Budget_Setup__c bs:allBSList){
                interimData tempdata= new interimData();
                tempdata.bs =bs;
                
                //For the first one data we will set as read only
                if(idx==1 ){// || bs.ASI_MFM_End_Date__c<system.today()
                    tempdata.SetReadonly=true;
                }
                // the function for idx is to find the first one data 
                idx++;
                allBudgetSetupMap.put(bs.id,tempdata);
                
            }
            
        }
    }
    
    
    public void SaveRecords() {
        
        boolean isprocess=true;
        isprocess=Validation(allBudgetSetupMap.values());
        if(isprocess){
            //Save successfully
            List<ASI_MFM_Budget_Setup__c> upsertTargetList = new List<ASI_MFM_Budget_Setup__c>();
            for(String key : allBudgetSetupMap.keySet()){
                upsertTargetList.add(allBudgetSetupMap.get(key).bs);
            }
            SaveSuccess=true;
            UpsertPermission=true;
            upsert upsertTargetList;
            init();
        }else{
            //Save failed , show error message
             SaveSuccess=false;
            UpsertPermission=false;
        }
        
        
    }
    
    
    //Validation checking for Saving records 
    boolean Validation(List<interimData> allList){
        boolean isProcess=true;
       
        
        Msg='';
        date StartDateOfYear=Date.newInstance(2000+integer.valueOf(Fiscalyear.substring(2,4)), 7, 1);
        date EndDateOfYear=Date.newInstance(2000+integer.valueOf(Fiscalyear.substring(4,6)), 6,30);
		
        for(Integer i = 0; i < 6; i++){
            IF(allList.SIZE() >= i+1){  //ADDED BY KAMMY
                // Active Time can not be empty 
                if(allList[i].bs.ASI_MFM_Start_Date__c==null){
                    Msg+=allList[i].bs.ASI_MFM_Type__c+':  Active Time can not be empty.'+'</br>';
                    isProcess=false;
                }else{
                    // the last one should be 6/30
                    if(i!=5 && allList[i+1].bs.ASI_MFM_Start_Date__c !=null ){
                        allList[i].bs.ASI_MFM_End_Date__c=allList[i+1].bs.ASI_MFM_Start_Date__c-1;
                    }
                    //checking for cross fiscal year 
                    if(allList[i].bs.ASI_MFM_Start_Date__c>EndDateOfYear || allList[i].bs.ASI_MFM_Start_Date__c<StartDateOfYear ){
                        Msg+=allList[i].bs.ASI_MFM_Type__c+': cannot cross Fiscal Year.'+'</br>';
                        isProcess=false;
                    }
                }
                
                boolean checkpre=true;
                for(Integer j = 0; j < i; j++){
                     // check the current date with previous date
                    if(allList[i].bs.ASI_MFM_Start_Date__c<=allList[j].bs.ASI_MFM_Start_Date__c && i!=1){
                        checkpre=false;
                        isProcess=false;
                    }
                }
                if(!checkpre){
                    Msg+='Please check Type: '+allList[i].bs.ASI_MFM_Type__c+'  cannot before previous Type. </br>';
                }
          }
        }
        return isProcess;
    }
    
    
    public Class interimData{
        public ASI_MFM_Budget_Setup__c bs {get; set;}
        public boolean SetReadonly  {get; set;} {SetReadonly=false;}
    }
}
@istest
public class ASI_MFM_PH_BudgetsUploadCrtl_TestClass {
    
    /*---------------------------------------------Fiscal Year Method -----------------------------------------------------------*/
     public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1  ;
        Integer yearA2 = Integer.valueOf(yearA1) +1  ;
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
    
    /*---------------------------------------------Test Budget: ASI_MFM_KR_BudgetsUploadController -----------------------------------------------------------*/
    static testMethod void ASI_MFM_PH_BudgetsUploadController_Test_1(){  
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;        
        update u;
        
        System.runAs(u){ 
            
            List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-50),ASI_MFM_Type__c = 'Budget',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-40),ASI_MFM_Type__c = 'LE1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-30), ASI_MFM_Type__c = 'LE2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-20),ASI_MFM_Type__c = 'LE3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-10),ASI_MFM_Type__c = 'LE4',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            insert NewRecord;
            
            
            Test.startTest();
            System.debug(Limits.getDMLRows()); 
                        
            ASI_MFM_PH_BudgetsUploadController ext = new ASI_MFM_PH_BudgetsUploadController();
            ext.Fiscalyear = Fiscalyear;
            ext.init();
            ext.changefy();  
            test.stopTest();  
        }   
    }
    
    static testMethod void ASI_MFM_PH_BudgetsUploadController_Test_2(){  //Without Start Date
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        update u;
        
        System.runAs(u){ 
            
            List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c = 'Budget',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c( ASI_MFM_Type__c = 'LE1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'), ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c = 'LE2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Type__c = 'LE3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c( ASI_MFM_Type__c = 'LE4',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_PH_Budget_Setup'), ASI_MFM_Fiscal_Year__c = fiscalYear);
            
            
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            //insert NewRecord;
            
            
            Test.startTest();
            System.debug(Limits.getDMLRows()); 
                        
            ASI_MFM_PH_BudgetsUploadController ext = new ASI_MFM_PH_BudgetsUploadController();
            
            ext.init();
            ext.Fiscalyear = Fiscalyear;
            ext.changefy();  
            ext.SaveRecords();
            
            test.stopTest();  
        }   
    }
}
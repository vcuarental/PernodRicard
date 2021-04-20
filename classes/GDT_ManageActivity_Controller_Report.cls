/**
 * Name     :   GDT_ManageActivity_Controller_Report.cls
 *  Apex Class Controller
 *
 * Author   :   Simon GAZIN
 * Date     :   29.07.2014
 *
 *******************************************************/
public with sharing class GDT_ManageActivity_Controller_Report {

    /* Variable declaration */
    public String serviceName       {get; set;}
    public String serviceCode       {get; set;}
    public String thisMonthName     {get; set;}
    public String lastMonthName     {get; set;}

    public List<GDT_Services__c> listService;
    public Map<String, Integer> mapNbActivities = new Map<String, Integer>();

    public Integer thisYear     {get; set;}
    public Integer thisMonth    {get; set;}
    public Integer lastYear     {get; set;}
    public Integer lastMonth    {get; set;}
    public Integer lastWeek     {get; set;}

    public Map<Integer, String> mapMonth = new Map<Integer, String>();

    /**************
     * Controller
     **************/
    public GDT_ManageActivity_Controller_Report(ApexPages.StandardController controller) {
        //Months
        mapMonth.put(01, 'January');    mapMonth.put(07, 'July'); 
        mapMonth.put(02, 'February');   mapMonth.put(08, 'August');
        mapMonth.put(03, 'March');      mapMonth.put(09, 'September');
        mapMonth.put(04, 'April');      mapMonth.put(10, 'October');
        mapMonth.put(05, 'May');        mapMonth.put(11, 'November');
        mapMonth.put(06, 'June');       mapMonth.put(12, 'December');

        //DateTime
        thisYear = Integer.valueOf((Datetime.now()).format('YYYY'));
        thisMonth = Integer.valueOf((Datetime.now()).format('MM'));
        thisMonthName = mapMonth.get(thisMonth);

        lastYear = thisYear;
        if(thisMonth == 1) {
            lastMonth = 12;
            lastYear = thisYear -1;
        }
        else
            lastMonth = thisMonth -1;
        lastMonthName = mapMonth.get(lastMonth);
        //lastWeek = LAST_WEEK;

        //Query SOQL
        listService = [SELECT Name, Code__c, ReportGroup__c FROM GDT_Services__c ORDER BY Code__c ASC NULLS FIRST];
    }


    /*************
     * GET ; SET
     *************/

    //Number of Services requested
    public Integer nbRequest {
        get{
            String querySOQL = 'SELECT count() FROM GDT_Activity__c WHERE CALENDAR_YEAR(Date_Request__c) = '+ String.valueOf(thisYear) +' AND CALENDAR_MONTH(Date_Request__c) = '+ String.valueOf(thisMonth);
            Integer nb = 0;

            nb = Database.countQuery(querySOQL);
            
            return nb;
        }
        set;
    }
    //Number of Services requested - LAST MONTH
    public Integer nbRequest_lm {
        get{
            String querySOQL = 'SELECT count() FROM GDT_Activity__c WHERE CALENDAR_YEAR(Date_Request__c) = '+ String.valueOf(lastYear) +' AND CALENDAR_MONTH(Date_Request__c) = '+ String.valueOf(lastMonth);
            Integer nb = 0;

            nb = Database.countQuery(querySOQL);
            
            return nb;
        }
        set;
    }
        //Number of Services requested - LAST WEEK
    public Integer nbRequest_lw {
        get{
            String querySOQL = 'SELECT count() FROM GDT_Activity__c WHERE Date_Request__c = LAST_WEEK';
            Integer nb = 0;

            nb = Database.countQuery(querySOQL);
            
            return nb;
        }
        set;
    }

    //Number of deployment
    public Integer nbDeploymentS02 {
        get {
            String querySOQL = 'SELECT count() FROM GDT_Activity_Line__c WHERE CALENDAR_MONTH(Date_Delivery__c) = '+ String.valueOf(thisMonth) +' AND CALENDAR_YEAR(Date_Delivery__c) = '+ String.valueOf(thisYear);
            nbDeploymentS02 = Database.countQuery(querySOQL);  

            return nbDeploymentS02;
        }
        set;
    }
    //Number of deployment - LAST MONTH
    public Integer nbDeploymentS02_lm {
        get {
            String querySOQL = 'SELECT count() FROM GDT_Activity_Line__c WHERE CALENDAR_MONTH(Date_Delivery__c) = '+ String.valueOf(lastMonth) +' AND CALENDAR_YEAR(Date_Delivery__c) = '+ String.valueOf(lastYear);
            nbDeploymentS02_lm = Database.countQuery(querySOQL);  

            return nbDeploymentS02_lm;
        }
        set;
    }
    //Number of deployment - LAST WEEK
    public Integer nbDeploymentS02_lw {
        get {
            String querySOQL = 'SELECT count() FROM GDT_Activity_Line__c WHERE Date_Delivery__c= LAST_WEEK';
            nbDeploymentS02_lw = Database.countQuery(querySOQL);  

            return nbDeploymentS02_lw;
        }
        set;
    }
    //Number of request (Service : S02 Request of release)
    public Integer nbRequestS02 {
        get {
            String querySOQL = 'SELECT count() FROM GDT_Activity__c WHERE GDT_Services__r.Code__c = \'SFDC-S02\' AND CALENDAR_MONTH(Date_Request__c) = '+ String.valueOf(thisMonth) +' AND CALENDAR_YEAR(Date_Request__c) = '+ String.valueOf(thisYear);
            nbRequestS02 = Database.countQuery(querySOQL);
            
            return nbRequestS02;
        }
        set;
    }
    //Number of request (Service : S02 Request of release) - LAST MONTH
    public Integer nbRequestS02_lm {
        get {
            String querySOQL = 'SELECT count() FROM GDT_Activity__c WHERE GDT_Services__r.Code__c = \'SFDC-S02\' AND CALENDAR_MONTH(Date_Request__c) = '+ String.valueOf(lastMonth) +' AND CALENDAR_YEAR(Date_Request__c) = '+ String.valueOf(lastYear);
            nbRequestS02_lm = Database.countQuery(querySOQL);
            
            return nbRequestS02_lm;
        }
        set;
    }
    //Number of request (Service : S02 Request of release) - LAST WEEK
    public Integer nbRequestS02_lw {
        get {
            String querySOQL = 'SELECT count() FROM GDT_Activity__c WHERE GDT_Services__r.Code__c = \'SFDC-S02\' AND Date_Request__c= LAST_WEEK';
            nbRequestS02_lw = Database.countQuery(querySOQL);
            
            return nbRequestS02_lw;
        }
        set;
    }

    /************
     * ID Reports
     ************/

    //Report : GDT_Report_AllServicesRequested
    public Id reportId_AllServicesRequested {
        get {
            try {
                reportId_AllServicesRequested = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_Report_AllServicesRequested'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_AllServicesRequested = null;
            }
            
            return reportId_AllServicesRequested;
        }
        set;
    }

    //Report : GDT_Report_AllServicesRequested - LAST MONTH
    public Id reportId_AllServicesRequested_LastMonth {
        get {
            try {
                reportId_AllServicesRequested_LastMonth = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_AllServicesRequested_LastMonth'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_AllServicesRequested_LastMonth = null;
            }
            
            return reportId_AllServicesRequested_LastMonth;
        }
        set;
    }

    //Report : GDT_Report_AllServicesRequested - LAST WEEK
    public Id reportId_AllServicesRequested_LastWeek {
        get {
            try {
                reportId_AllServicesRequested_LastWeek = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_AllServicesRequested_LW'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_AllServicesRequested_LastWeek= null;
            }
            
            return reportId_AllServicesRequested_LastWeek;
        }
        set;
    }
    //Report : GDT_Report_ServicesRequestedByAffiliate
    public Id reportId_ServicesRequestedByAffiliate {
        get {
            try {
                reportId_ServicesRequestedByAffiliate = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_Report_ServicesRequestedByAffiliate'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_ServicesRequestedByAffiliate = null;
            }
            
            return reportId_ServicesRequestedByAffiliate;
        }
        set;
    }

    //Report : GDT_Report_ServicesRequestedByAffiliate - LAST MONTH
    public Id reportId_ServicesRequestedByAffiliate_LastMonth {
        get {
            try {
                reportId_ServicesRequestedByAffiliate_LastMonth = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_ServicesRequestedByAffiliate_LM'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_ServicesRequestedByAffiliate_LastMonth = null;
            }
            
            return reportId_ServicesRequestedByAffiliate_LastMonth;
        }
        set;
    }
      //Report : GDT_Report_ServicesRequestedByAffiliate - LAST WEEK
    public Id reportId_ServicesRequestedByAffiliate_LastWeek {
        get {
            try {
                reportId_ServicesRequestedByAffiliate_LastWeek = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_ServicesRequestedByAffiliate_LW'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_ServicesRequestedByAffiliate_LastWeek = null;
            }
            
            return reportId_ServicesRequestedByAffiliate_LastWeek;
        }
        set;
    }

    //Report : GDT_Report_FocusS02RequestOfRelease
    public Id reportId_FocusS02 {
        get {
            try {
                reportId_FocusS02 = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_Report_FocusS02RequestOfRelease'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_FocusS02 = null;
            }
            
            return reportId_FocusS02;
        }
        set;
    }

    //Report : GDT_Report_FocusS02RequestOfRelease - LAST MONTH
    public Id reportId_FocusS02_LastMonth {
        get {
            try {
                reportId_FocusS02_LastMonth = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_FocusS02RequestOfRelease_LM'].Id;
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_FocusS02_LastMonth = null;
            }
            
            return reportId_FocusS02_LastMonth;
        }
        set;
    }
       //Report : GDT_Report_FocusS02RequestOfRelease - LAST WEEK
    public Id reportId_FocusS02_LastWeek {
        get {
            try {
                reportId_FocusS02_LastWeek = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_FocusS02RequestOfRelease_LW'].Id;
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_FocusS02_LastWeek = null;
            }
            
            return reportId_FocusS02_LastWeek;
        }
        set;
    }

    //Status of Activities
    public Id reportId_StatusActivities {
        get {
            try {
                reportId_StatusActivities = [SELECT Id FROM Report WHERE DeveloperName = 'GDT_Report_StatusOfActivities'].Id;  
            } catch(Exception e) {
              System.debug(e.getMessage());
              reportId_StatusActivities = null;
            }
            
            return reportId_StatusActivities;
        }
        set;
    }

}
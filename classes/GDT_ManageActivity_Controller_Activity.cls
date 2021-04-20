/**
 * Name     :   GDT_ManageActivity_Controller_Activity.cls
 *  Apex Class Controller
 *
 * Author   :   Simon GAZIN
 * Date     :   05.05.2014
 *
 *******************************************************/
public with sharing class GDT_ManageActivity_Controller_Activity {

    /* Variable Declaration */

    GDT_Activity__c record; //Record of activity

    //*if true, the block is display else if false, is hide
    public Boolean S00 {get; set;} //PageBlock contains all PageBlockSection for Service
    public Boolean S01 {get; set;} //PageBlockSection for Service 01
    public Boolean S02 {get; set;} //PageBlockSection for Service 02 
    public Boolean S03 {get; set;} //PageBlockSection for Service 03
    public Boolean S04 {get; set;} //PageBlockSection for Service 04
    public Boolean S05 {get; set;} //PageBlockSection for Service 05
    public Boolean S06 {get; set;} //PageBlockSection for Service 06
    public Boolean S07 {get; set;} //PageBlockSection for Service 07
    public Boolean S08 {get; set;} //PageBlockSection for Service 08
    public Boolean S09 {get; set;} //PageBlockSection for Service 09
    public Boolean S10 {get; set;} //PageBlockSection for Service 10
    public Boolean S11 {get; set;} //PageBlockSection for Service 11
    public Boolean S12 {get; set;} //PageBlockSection for Service 11
    public Boolean S13 {get; set;} //PageBlockSection for Service 13
    //public Boolean S.. {get; set;} //PageBlockSection for Service ..
    //*if true, the block is display else if false, is hide

    public Boolean relatedList_Line {get;set;} //Related list for LineItem
    public Boolean sandboxBoolean   {get;set;} //If Sandbox, display field Sandbox Name

    //Columns display/hide according to Service sorted
    public Boolean bDateExpected    {get; set;}
    public Boolean bDateDelivery    {get; set;}
    public Boolean bEnvironmentDest {get; set;}
    public Boolean bSandboxName     {get; set;}
    public Boolean bEnvironment     {get; set;}
    public Boolean bPackageName     {get; set;}
    public Boolean bAppName         {get; set;}

    //
    public  String serviceCode      {get; set;} //Contains the service code, example : SFDC_S01
    private String querySOQL        {get; set;} //Global query
    private String queryLimit       {get; set;}
    
    //SelectList
    public Integer slService        {get; set;} //Value of selectList for services
    public Integer slSortService    {get; set;} //Value of selectList for the sorts of service
    public Integer slSortStatus     {get; set;} //Value of selectList for the sorts of status
    public Integer slSortAffiliate  {get; set;} //Value of selectList for the sorts of affiliate
    public Integer slSortAffiliateGroup  {get; set;} //Value of selectList for the sorts of affiliate group
    public Integer slSortProjectName  {get; set;} //Value of selectList for the sorts of projectName
    public Integer slSortEnvironmentDest {get; set;}    //Value of selectList for Environment Destination
    public String sortServiceName   {get; set;} //Contains the serviceName which corresponds to the value of SelectList
    public String sortStatus        {get; set;} //Contains the Status which corresponds to the value of SelectList
    public String sortAffiliate     {get; set;} //Contains Affiliates which corresponds to the value of SelectList
    public String sortAffiliateGroup     {get; set;}
    public String sortProjectName     {get; set;}
    public String sortEnvironmentDest {get; set;} //Contains Environment Destination which corresponds to the value of SelectList

    //Pagination
    private Integer limitSize = 1000; //Number activities displayed on page
    public Integer counterOffset    {get; set;}
    public Integer totalRecord      {get; set;}
    public Integer currentPage      {get; set;}

    //Table of activities
    public List<GDT_Activity__c> tabActivities {get;set;}

    //Combinaison between the values ​​of the selectList and serviceCode
    Map<Integer, String> mapOfServices  = new Map<Integer, String>();
    //Combinaison between the values ​​of the selectList and Status
    Map<Integer, String> mapOfStatus    = new Map<Integer, String>();
    //Combinaison between the values ​​of the selectList and Affiliate
    Map<Integer, String> mapOfAffiliate = new Map<Integer, String>();
    Map<Integer, String> mapOfAffiliateGroup = new Map<Integer, String>();
    Map<Integer, String> mapOfProjectName = new Map<Integer, String>();
    //Combinaison between the values ​​of the selectList and Environment
    Map<Integer, String> mapOfEnvironmentDest = new Map<Integer, String>();

    /**************
     * Controller
     **************/
    public GDT_ManageActivity_Controller_Activity(ApexPages.StandardController controller) {    

        if(!Test.isRunningTest()){
            controller.addFields(new List<String>{'Template_Code__c'});
        }

        //Contains the value of the record
        record = (GDT_Activity__c)controller.getRecord();

        //Display the PageBlockSection for View and Edit visualforce page
        if(record.Template_Code__c != null){
            if (record.Template_Code__c == 'SFDC-S01') { S01 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S02') { S02 = true; S00 = true; relatedList_Line = true; }
            if (record.Template_Code__c == 'SFDC-S03') { S03 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S04') { S04 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S05') { S05 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S06') { S06 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S07') { S07 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S08') { S08 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S09') { S09 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S10') { S10 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S11') { S11 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S12') { S12 = true; S00 = true; relatedList_Line = false; }
            if (record.Template_Code__c == 'SFDC-S13') { S13 = true; S00 = true; relatedList_Line = false; }
            //if (record.Template_Code__c == 'SFDC-S..') { S.. = true; S00 = true; relatedList_Line = false; }
        }

        //Automatic insertion of the field : PerformedBy
        if(record.Performed_By__c == NULL)
            record.Performed_By__c = UserInfo.getUserId();

        //Default value of the field : Statut
        if(record.Status__c == null)
            record.Status__c = 'In Progress';

        //Columns display/hide
        bDateExpected       = true;
        bDateDelivery       = true;
        bEnvironmentDest    = false;
        bSandboxName        = false;
        bEnvironment        = false;
        bPackageName        = false;
        bAppName            = false;

        //Selection of fields needed to display on TabActivity
        querySOQL = 'SELECT CreatedDate, Id, Project_Name__c, Incident__c, Activity_Name__c, Affiliate__c, Affiliate_Group__c, Date_Delivery__c, Date_Expected__c, Date_Request__c, GDT_Services__r.Name, Project_Description__c, Commentary__c, Sandbox_Name__c, Sandbox_Type__c, Status__c, Template_Code__c, Environment_Destination__c, Environment__c, Package_Name__c, Application_Name__c FROM GDT_Activity__c';
        
        //Use for pagination /!\ requires number after OFFSET
        queryLimit = ' LIMIT :limitSize OFFSET ';
        counterOffset = 0;
        
        //Number of records
        totalRecord = Database.countQuery('SELECT count() FROM GDT_Activity__c');
        if(totalRecord == 0)
            currentPage = 0;
        else
            currentPage = 1;

        //Update table
        runQuery();
    }



    /**
     * sortDir
     *  The current sort direction. Defaults to asc
     */
    public String sortDir {
        get {
            if (sortDir == null)
                sortDir = 'DESC';

            return sortDir;
        }
        set;
    }

    /**
     * sortField
     *  The current field to sort by. defaults to last name
     */
    public String sortField {
        get {
            if (sortField == null)
                sortField = 'Date_Request__c'; 

            return sortField; 
        }
        set;
    }

    /**
     * Picklist Services
     *  To use for the sort
     */
    public List<SelectOption> optServices { 
        get {
            //Variable declaration
            List<SelectOption> options  = new List<SelectOption>();
            Integer itemValue       =   0;
            String  defaultService  =   '- - - - - - - - - - - - - - - - Service - - - - - - - - - - - - - - - - -';

            //Default value
            options.add(new SelectOption(String.valueOf(itemValue), defaultService));
            mapOfServices.put(itemValue, defaultService);

            try {
                AggregateResult[] arServices = [SELECT Name FROM GDT_Services__c GROUP BY Name ORDER BY Name ASC NULLS FIRST];

                //All Services
                for (AggregateResult ar : arServices) {
                    itemValue++;
                    options.add(new SelectOption(String.valueOf(itemValue), String.valueOf(ar.get('Name'))));
                    mapOfServices.put(itemValue, String.valueOf(ar.get('Name')));
                }

            } catch(Exception e) {
                System.debug(e.getMessage());
            }

            return options;
        }
    }

    /**
     * Picklist Status
     *  To use for the sort
     */
    public List<SelectOption> optStatus{ 
        get {
            //Variable declaration
            List<SelectOption> options = new List<SelectOption>();
            Integer itemValue       = 0;
            String  defaultStatus   = '- - - - - Status - - - - -';

            //Default value
            options.add(new SelectOption(String.valueOf(itemValue), defaultStatus));
            mapOfStatus.put(itemValue, defaultStatus);

            try {
                AggregateResult[] arStatus = [SELECT Status__c FROM GDT_Activity__c GROUP BY Status__c ORDER BY Status__c DESC NULLS FIRST];  

                for (AggregateResult ar : arStatus) {
                    if(String.isNotEmpty(String.valueOf(ar.get('Status__c')))){
                        itemValue++;
                        options.add(new SelectOption(String.valueOf(itemValue), String.valueOf(ar.get('Status__c')))); 
                        mapOfStatus.put(itemValue, String.valueOf(ar.get('Status__c')));
                    }
                }

            } catch(Exception e) {
                System.debug(e.getMessage());
            }
                        
            return options;
        }
    }

    /**
     * Picklist affiliates
     *  To use for the sort
     */
    public List<SelectOption> optAffiliates{ 
        get {
            //Variable declaration
            List<SelectOption> options = new List<SelectOption>();
            List<String> listAffiliate = new List<String>();

            Integer itemValue = 0;
            Integer result; //Returns the index (indexOf()), If the substring does not occur, this method returns -1
            Integer ssStart; //substring()
            Integer ssEnd;  //substring()

            String  soqlLabel; //Query Result
            String  itemLabel;
            String  defaultAffiliate = '- - - - - - - - Affiliate - - - - - - - -';

            //Default value
            options.add(new SelectOption(String.valueOf(itemValue), defaultAffiliate));
            mapOfAffiliate.put(itemValue, defaultAffiliate);

            try {
                List<GDT_Activity__c> soqlAffiliate = [SELECT Affiliate__c FROM GDT_Activity__c];

                for (GDT_Activity__c ar : soqlAffiliate) {
                    ssStart     = 0;
                    soqlLabel   = String.valueOf(ar.get('Affiliate__c'));

                    if(String.isNotEmpty(soqlLabel)){
                        result = soqlLabel.indexOf(';', ssStart);
        
                        //One value in multi-picklist
                        if(result == -1){
                            listAffiliate.add(soqlLabel);
                        }
                        //If more than one
                        else{
                            ssEnd = result;
        
                            do{ 
                                itemLabel = soqlLabel.substring(ssStart, ssEnd);
                                listAffiliate.add(itemLabel);
                                //
                                ssStart = ssEnd+1;
                                result  = soqlLabel.indexOf(';', result+1);
                                ssEnd   = result;
                            }while (result != (-1));
        
                            //Add the last value
                            itemLabel = soqlLabel.substring(ssStart);
                            listAffiliate.add(itemLabel);
                        }
                    }
                }//For 'ar'

                //Sets, by definition, contain no duplicates.
                Set<String> mySet = new Set<String>();
                List<String> resultList = new List<String>();
                mySet.addAll(listAffiliate);
                resultList.addAll(mySet);
                listAffiliate = resultList;

                //Sort the list
                listAffiliate.sort();

                //Add on map
                for(String sList : listAffiliate){
                    itemValue++;
                    options.add(new SelectOption(String.valueOf(itemValue), sList));
                    mapOfAffiliate.put(itemValue, sList);
                }

            } catch(Exception e) {
                System.debug(e.getMessage());
            }

            return options;
       }
    }

     public List<SelectOption> optAffiliatesGroup{ 
        get {
            //Variable declaration
            List<SelectOption> options = new List<SelectOption>();
            List<String> listAffiliateGroup = new List<String>();

            Integer itemValue = 0;
            Integer result; //Returns the index (indexOf()), If the substring does not occur, this method returns -1
            Integer ssStart; //substring()
            Integer ssEnd;  //substring()

            String  soqlLabel; //Query Result
            String  itemLabel;
            String  defaultAffiliateGroup = '- - - - - - - - Affiliate Group - - - - - - - -';

            //Default value
            options.add(new SelectOption(String.valueOf(itemValue), defaultAffiliateGroup));
            mapOfAffiliateGroup.put(itemValue, defaultAffiliateGroup);

            try {
                List<GDT_Activity__c> soqlAffiliateGRoup = [SELECT Affiliate_Group__c FROM GDT_Activity__c];

                for (GDT_Activity__c ar : soqlAffiliateGRoup) {
                    ssStart     = 0;
                    soqlLabel   = String.valueOf(ar.get('Affiliate_Group__c'));

                    if(String.isNotEmpty(soqlLabel)){
                        result = soqlLabel.indexOf(';', ssStart);
        
                        //One value in multi-picklist
                        if(result == -1){
                            listAffiliateGroup.add(soqlLabel);
                        }
                        //If more than one
                        else{
                            ssEnd = result;
        
                            do{ 
                                itemLabel = soqlLabel.substring(ssStart, ssEnd);
                                listAffiliateGroup.add(itemLabel);
                                //
                                ssStart = ssEnd+1;
                                result  = soqlLabel.indexOf(';', result+1);
                                ssEnd   = result;
                            }while (result != (-1));
        
                            //Add the last value
                            itemLabel = soqlLabel.substring(ssStart);
                            listAffiliateGroup.add(itemLabel);
                        }
                    }
                }//For 'ar'

                //Sets, by definition, contain no duplicates.
                Set<String> mySet = new Set<String>();
                List<String> resultList = new List<String>();
                mySet.addAll(listAffiliateGroup);
                resultList.addAll(mySet);
                listAffiliateGroup = resultList;

                //Sort the list
                listAffiliateGroup.sort();

                //Add on map
                for(String sList : listAffiliateGroup){
                    itemValue++;
                    options.add(new SelectOption(String.valueOf(itemValue), sList));
                    mapOfAffiliateGroup.put(itemValue, sList);
                }

            } catch(Exception e) {
                System.debug(e.getMessage());
            }

            return options;
       }
    }

    public List<SelectOption> optProjectName{ 
        get {
            //Variable declaration
            List<SelectOption> options = new List<SelectOption>();
            List<String> listProjectName = new List<String>();

            Integer itemValue = 0;
            Integer result; //Returns the index (indexOf()), If the substring does not occur, this method returns -1
            Integer ssStart; //substring()
            Integer ssEnd;  //substring()

            String  soqlLabel; //Query Result
            String  itemLabel;
            String  defaultProjectName = '- - - - - - - - Project Name - - - - - - - -';

            //Default value
            options.add(new SelectOption(String.valueOf(itemValue), defaultProjectName));
            mapOfProjectName.put(itemValue, defaultProjectName);

            try {
                List<GDT_Activity__c> soqlProjectName = [SELECT Project_Name__c FROM GDT_Activity__c];

                for (GDT_Activity__c ar : soqlProjectName) {
                    ssStart     = 0;
                    soqlLabel   = String.valueOf(ar.get('Project_Name__c'));

                    if(String.isNotEmpty(soqlLabel)){
                        result = soqlLabel.indexOf(';', ssStart);
        
                        //One value in multi-picklist
                        if(result == -1){
                            listProjectName.add(soqlLabel);
                        }
                        //If more than one
                        else{
                            ssEnd = result;
        
                            do{ 
                                itemLabel = soqlLabel.substring(ssStart, ssEnd);
                                listProjectName.add(itemLabel);
                                //
                                ssStart = ssEnd+1;
                                result  = soqlLabel.indexOf(';', result+1);
                                ssEnd   = result;
                            }while (result != (-1));
        
                            //Add the last value
                            itemLabel = soqlLabel.substring(ssStart);
                            listProjectName.add(itemLabel);
                        }
                    }
                }//For 'ar'

                //Sets, by definition, contain no duplicates.
                Set<String> mySet = new Set<String>();
                List<String> resultList = new List<String>();
                mySet.addAll(listProjectName);
                resultList.addAll(mySet);
                listProjectName = resultList;

                //Sort the list
                listProjectName.sort();

                //Add on map
                for(String sList : listProjectName){
                    itemValue++;
                    options.add(new SelectOption(String.valueOf(itemValue), sList));
                    mapOfProjectName.put(itemValue, sList);
                }

            } catch(Exception e) {
                System.debug(e.getMessage());
            }

            return options;
       }
    }




    /**
     * Picklist Environment Destination
     *  To use for the sort
     */
    public List<SelectOption> optEnvironmentDest{ 
        get {
            //Variable declaration
            List<SelectOption> options = new List<SelectOption>();
            List<String> listEnvironment = new List<String>();

            Integer itemValue = 0;
            Integer result; //Returns the index (indexOf()), If the substring does not occur, this method returns -1
            Integer ssStart; //substring()
            Integer ssEnd;  //substring()

            String  soqlLabel; //Query Result
            String  itemLabel;
            String  defaultEnvironment = '- - - - - Environment Destination - - - - -';

            //Default value
            options.add(new SelectOption(String.valueOf(itemValue), defaultEnvironment));
            mapOfEnvironmentDest.put(itemValue, defaultEnvironment);

            try {
                List<GDT_Activity__c> soqlEnvironment = [SELECT Environment_Destination__c FROM GDT_Activity__c];

                for (GDT_Activity__c ar : soqlEnvironment) {
                    ssStart     = 0;
                    soqlLabel   = String.valueOf(ar.get('Environment_Destination__c'));

                    if(String.isNotEmpty(soqlLabel)){
                        result = soqlLabel.indexOf(';', ssStart);
        
                        //One value in multi-picklist
                        if(result == -1){
                            listEnvironment.add(soqlLabel);
                        }
                        //If more than one
                        else{
                            ssEnd = result;
        
                            do{ 
                                itemLabel = soqlLabel.substring(ssStart, ssEnd);
                                listEnvironment.add(itemLabel);
                                //
                                ssStart = ssEnd+1;
                                result  = soqlLabel.indexOf(';', result+1);
                                ssEnd   = result;
                            }while (result != (-1));
        
                            //Add the last value
                            itemLabel = soqlLabel.substring(ssStart);
                            listEnvironment.add(itemLabel);
                        }
                    }
                }//For 'ar'

                //Sets, by definition, contain no duplicates.
                Set<String> mySet = new Set<String>();
                List<String> resultList = new List<String>();
                mySet.addAll(listEnvironment);
                resultList.addAll(mySet);
                listEnvironment = resultList;

                //Sort the list
                listEnvironment.sort();

                //Add on map
                for(String sList : listEnvironment){
                    itemValue++;
                    options.add(new SelectOption(String.valueOf(itemValue), sList));
                    mapOfEnvironmentDest.put(itemValue, sList);
                }

            } catch(Exception e) {
                System.debug(e.getMessage());
            }

            return options;
       }
    }

    /**
     * getLineItem
     *  Return the list of lineItem which depend on the service
     */
    public List<GDT_Activity_Line__c> getLine {
        get{
            List<GDT_Activity_Line__c> getLine = new List<GDT_Activity_Line__c>();

            try {
                getLine = [SELECT Id, GDT_Activity_Relationship__c, Release_type_Line__c, Deployment_Type__c, Performed_By__c, Status__c, Commentary__c, Date_expected__c, Available_elements_date__c,  Date_delivery__c, Date_of_request__c FROM GDT_Activity_Line__c WHERE GDT_Activity_Relationship__c = :record.Id ORDER BY CreatedDate ASC NULLS FIRST];
            } catch(Exception e) {
                System.debug('No records getLine : ' + e.getMessage());
            }

            return getLine;
        }
    }

    /**
     * Pagination
     */
    public Integer startRecord {
        get{
            if(totalRecord > 0)
                startRecord = counterOffset + 1;
            else
                startRecord = 0;

            return startRecord;
        } private set;
    }
    public Integer endRecord {
        get{
            if(endRecord == null)
                endRecord = 0;

            endRecord = counterOffset + limitSize;

            if(endRecord > totalRecord)
                endRecord = totalRecord;

            return endRecord;
        } private set;
    }
    //Calculate the number of page
    public Integer nbPage {
        get {
            nbPage = (totalRecord + limitSize - 1) / limitSize;
            return nbPage;
        } private set;
    }
    //Display buttons 'First' and 'Previous'
    public Boolean firstPageLink {
        get {
            if(currentPage == 1 || totalRecord == 0)
                return false;
            else
                return true;
            } private set;
    }
    //Display buttons 'Last' and 'Next'
    public Boolean lastPageLink {
        get {
            if(currentPage == nbPage || totalRecord == 0)
                return false;
            else
                return true;
            } private set;
    }


    /*************
     *  FUNCTION
     ************/

    /**
     * CloseIncident()
     *  Closing the incident in relation to the activity
     */
    public PageReference CloseIncident() {
        try {
            //updating the status of the activity
            GDT_Activity__c updateActivity = [SELECT Incident__c, Status__c FROM GDT_Activity__c WHERE Id=:record.Id];
            updateActivity.Status__c = 'Closed';
            update updateActivity;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        //Reloaded the visualforce page
        PageReference pageRef = new PageReference('/apex/GDT_ManageActivity_ViewActivity?id='+record.Id);
        pageRef.setRedirect(true);
        return pageRef;
     }


    public PageReference SaveActivity() {
        try {
            upsert record;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        //Reloaded the visualforce page
        PageReference pageRef = new PageReference('/apex/GDT_ManageActivity_TabActivity');
        pageRef.setRedirect(true);
        return pageRef;
     }



     /**
      * openIncident()
      *  Opening the incident in relation of the activity
      */
     public PageReference OpenIncident() {
        try {
            //Opend the incident
            BMCServiceDesk__Incident__c incident = [SELECT Id, BMCServiceDesk__Status_ID__c, BMCServiceDesk__FKStatus__c FROM BMCServiceDesk__Incident__c WHERE Id = :record.Incident__c];
            incident.BMCServiceDesk__FKStatus__c = [SELECT Id FROM BMCServiceDesk__Status__c WHERE Name='IN PROGRESS'].Id;
            update incident;

            //updating the status of the activity
            GDT_Activity__c updateActivity = [SELECT Incident__c, Status__c FROM GDT_Activity__c WHERE Id=:record.Id];
            updateActivity.Status__c = 'In Progress';
            update updateActivity;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        //Reloaded the visualforce page
        PageReference pageRef = new PageReference('/apex/GDT_ManageActivity_ViewActivity?id='+record.Id);
        pageRef.setRedirect(true);
        return pageRef;
     }

     /**
      * inProgressIncident()
      *  Change the statut of the incident
      */
     public PageReference InProgressIncident() {
        try {
            //updating the status of the activity
            GDT_Activity__c updateActivity = [SELECT Incident__c, Status__c FROM GDT_Activity__c WHERE Id=:record.Id];
            updateActivity.Status__c = 'In Progress';
            update updateActivity;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        //Reloaded the visualforce page
        PageReference pageRef = new PageReference('/apex/GDT_ManageActivity_ViewActivity?id='+record.Id);
        pageRef.setRedirect(true);
        return pageRef;
     }

     /**
      * waitingForUserIncident()
      *  Change the statut of the incident
      */
     public PageReference WaitingForUserIncident() {
        try {
            //updating the status of the activity
            GDT_Activity__c updateActivity = [SELECT Incident__c, Status__c FROM GDT_Activity__c WHERE Id=:record.Id];
            updateActivity.Status__c = 'Waiting for user';
            update updateActivity;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        //Reloaded the visualforce page
        PageReference pageRef = new PageReference('/apex/GDT_ManageActivity_ViewActivity?id='+record.Id);
        pageRef.setRedirect(true);
        return pageRef;
     }

     /**
      * ResolvedIncident()
      *  Change the statut of the incident
      */
     public PageReference ResolvedIncident() {
        try {
            //updating the status of the activity
            GDT_Activity__c updateActivity = [SELECT Incident__c, Status__c FROM GDT_Activity__c WHERE Id=:record.Id];
            updateActivity.Status__c = 'Resolved';
            update updateActivity;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        //Reloaded the visualforce page
        PageReference pageRef = new PageReference('/apex/GDT_ManageActivity_ViewActivity?id='+record.Id);
        pageRef.setRedirect(true);
        return pageRef;
     }

    /**
     * SelectService()
     *  When you create a new Activity, you must select a service
     *  And this function will display the PageBlockSection which corresponds
     *  By default, all blocks are hidden
     */
    public void SelectService() {
        //Initialization
        S00 = false;    S10 = false;
        S01 = false;    S11 = false;
        S02 = false;    S12 = false;
        S03 = false;    S13 = false;
        S04 = false;    //S.. = false;
        S05 = false;
        S06 = false;
        S07 = false;
        S08 = false;
        S09 = false;

        try {
            //Contains the serviceCode used
            record.GDT_Services__c = [SELECT Id FROM GDT_Services__c WHERE Name = :mapOfServices.get(slService)].Id;
            serviceCode = [SELECT Code__c FROM GDT_Services__c WHERE Id = :record.GDT_Services__c].Code__c;

        } catch(Exception e) {
            System.debug(e.getMessage());

            slService = 0;
        }

        if(slService != 0) {
            //Display pageBlockSection
            if (serviceCode == 'SFDC-S01') { S00 = true; S01 = true; }
            if (serviceCode == 'SFDC-S02') { S00 = true; S02 = true; }
            if (serviceCode == 'SFDC-S03') { S00 = true; S03 = true; }
            if (serviceCode == 'SFDC-S04') { S00 = true; S04 = true; }
            if (serviceCode == 'SFDC-S05') { S00 = true; S05 = true; }
            if (serviceCode == 'SFDC-S06') { S00 = true; S06 = true; }
            if (serviceCode == 'SFDC-S07') { S00 = true; S07 = true; }
            if (serviceCode == 'SFDC-S08') { S00 = true; S08 = true; }
            if (serviceCode == 'SFDC-S09') { S00 = true; S09 = true; }
            if (serviceCode == 'SFDC-S10') { S00 = true; S10 = true; }
            if (serviceCode == 'SFDC-S11') { S00 = true; S11 = true; }
            if (serviceCode == 'SFDC-S12') { S00 = true; S12 = true; }
            if (serviceCode == 'SFDC-S13') { S00 = true; S13 = true; }
            //if (serviceCode == 'SFDC-S..') { S.. = true; S00 = true; }
        }
    }

    /**
     * CompleteEmail
     *  This function allows you to retrieve email address of requester,  automatically
     */
    public void CompleteEmail() {
        try {
            record.Requester_Email__c = [SELECT Email FROM User WHERE Id = :record.PR_Requester_Name__c].Email;
        }
        catch(Exception e) {
            record.Requester_Email__c = '';
        }
    }

    /**
     * DisplaySandboxDetail
     *  Environment__c : Picklist
     */
    public void DisplaySandboxDetail() {
        if(record.Environment__c == 'Sandbox name')
            sandboxBoolean = true;
        else
            sandboxBoolean = false;
    }

    /**
     * sortActivities()
     *  Update the sorts
     */
    public void sortActivities(){
        sortServiceName = String.valueOf(mapOfServices.get(slSortService));
        sortStatus      = mapOfStatus.get(slSortStatus);
        sortAffiliate   = mapOfAffiliate.get(slSortAffiliate);
        sortAffiliateGroup   = mapOfAffiliateGroup.get(slSortAffiliateGroup);
        sortProjectName   = mapOfProjectName.get(slSortProjectName);
        sortEnvironmentDest = mapOfEnvironmentDest.get(slSortEnvironmentDest);

        counterOffset = 0;

        //Show or Hide columns
        showColumns();
        // Run the query
        runQuery();

        if(totalRecord == 0){
            currentPage = 0;
        }
        else {
            currentPage = 1;
        }
    }

    /**
     * sortReset()
     *  Initializes the sorts
     */
    public void sortReset(){
        slSortService   = 0;
        slSortStatus    = 0;
        slSortAffiliate = 0;
        slSortAffiliateGroup = 0;
        slSortProjectName= 0;
        slSortEnvironmentDest = 0;

        //Number of records
        totalRecord = Database.countQuery('SELECT count() FROM GDT_Activity__c');
        currentPage = 1;
        counterOffset = 0;

        //Show or Hide columns
        showColumns();
        // Run the query
        runQuery();
    }

    /**
     * toggleSort()
     *  toggles the sorting of query from asc -> desc
     */
    public void toggleSort() {
        // Simply toggle the direction
        sortDir = sortDir.equals('DESC') ? 'ASC' : 'DESC';
        // Run the query again
        runQuery();
    }

    /**
     * runQuery()
     *  Runs the actual query
     */
    public Integer nbTEST {get;set;}
    public void runQuery() {
        try {
            totalRecord = Database.countQuery('SELECT count() FROM GDT_Activity__c');
            String filterSOQL;

            if(totalRecord > 0) {
                tabActivities = Database.query(querySOQL + ' WHERE Status__c != \'Created\' ORDER BY ' + sortField + ' ' + sortDir + queryLimit + counterOffset);

                //Sort: Service
                if(slSortService != 0){
                    List<GDT_Activity__c> listActivities = new List<GDT_Activity__c>();
                    for(GDT_Activity__c act : tabActivities){
                        if(act.GDT_Services__r.Name == sortServiceName)
                            listActivities.add(act);
                    }
                    tabActivities = listActivities;
                    totalRecord = tabActivities.size();
                }

                //Sort: Status
                if(slSortStatus != 0){
                    List<GDT_Activity__c> listActivities = new List<GDT_Activity__c>();
                    for(GDT_Activity__c act : tabActivities){
                        if(act.Status__c == sortStatus)
                            listActivities.add(act);
                    }
                    tabActivities = listActivities;
                    totalRecord = tabActivities.size();
                }
                //Sort: Affiliate
                if(slSortAffiliate != 0){
                    List<GDT_Activity__c> listActivities = new List<GDT_Activity__c>();
                    List<GDT_Activity__c> listActivitiesAffiliate = Database.query(querySOQL + ' WHERE Status__c != \'Created\'  AND GDT_Activity__c.Affiliate__c INCLUDES(\'' + sortAffiliate + '\') ORDER BY ' + sortField + ' ' + sortDir + queryLimit + counterOffset);
                    for(GDT_Activity__c act : tabActivities){
                        for(GDT_Activity__c lsAct : listActivitiesAffiliate){
                            if(act.Id == lsAct.Id)
                                listActivities.add(lsAct);
                        }
                    }
                    tabActivities = listActivities;
                    totalRecord = tabActivities.size();
                }
                if(slSortAffiliateGroup != 0){
                    List<GDT_Activity__c> listActivities = new List<GDT_Activity__c>();
                    for(GDT_Activity__c act : tabActivities){
                        if(act.Affiliate_Group__c == sortAffiliateGroup)
                            listActivities.add(act);
                    }
                    tabActivities = listActivities;
                    totalRecord = tabActivities.size();
                }
                if(slSortProjectName != 0){
                    List<GDT_Activity__c> listActivities = new List<GDT_Activity__c>();
                    for(GDT_Activity__c act : tabActivities){
                        if(act.Project_Name__c == sortProjectName)
                            listActivities.add(act);
                    }
                    tabActivities = listActivities;
                    totalRecord = tabActivities.size();
                }
                //Sort: Environment Destination
                if(slSortEnvironmentDest != 0){
                    List<GDT_Activity__c> listActivities = new List<GDT_Activity__c>();
                    for(GDT_Activity__c act : tabActivities){
                        if(act.Environment_Destination__c == sortEnvironmentDest)
                            listActivities.add(act);
                    }
                    tabActivities = listActivities;
                    totalRecord = tabActivities.size();
                }

            }
                        system.debug(tabActivities);

        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops! Error in runQuery()'));
        }
    }

    /**
     * showColumns()
     *  Is used when a filter is select on the service 
     *  False = Hide / True = Display
     */
    public void showColumns() {
        //Defaults values
        bDateExpected = true;
        bDateDelivery = true;
        bEnvironmentDest = false;
        bSandboxName = false;
        bEnvironment = false;
        bPackageName = false;
        bAppName = false;

        //Switch by Services
        if(slSortService == 1 || slSortService == 4) {
            bDateExpected = false;
            bSandboxName = true;
        }
        if(slSortService == 2) {
            bDateExpected = false;
            bDateDelivery = false;
            bEnvironmentDest = true;
        }
        if(slSortService == 3) {
            bSandboxName = true;
        }
        if(slSortService == 5) {
            bDateExpected = false;
            bPackageName = true;
            bEnvironment = true;
        }
        if(slSortService == 7 || slSortService == 12) {
            bDateExpected = false;
            bAppName = true;
            bEnvironment = true;
        }
    }
    
    /**
     * Pagination
     */
    //Returns the first page of records
    public void first() {
        counterOffset = 0;
        currentPage = 1;
        runQuery();
    }

    //Returns the last page of records
    public void last() {
        counterOffset = (nbPage * limitSize) - limitSize;
        currentPage = nbPage;
        runQuery();
    }

    //Returns the previous page of records
    public void previous() {
        counterOffset -= limitSize;
        currentPage -= 1;
        runQuery();
    }

    //Returns the next page of records
    public void next() {
        counterOffset += limitSize;
        currentPage += 1;
        runQuery();
    }

}//GDT_Controller
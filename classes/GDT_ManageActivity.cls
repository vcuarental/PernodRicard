/**
 * Name     :   GDT_ManageActivity.cls
 *  This class contains functions used in Apex triggers.
 *
 * Author   :   Simon GAZIN
 * Date     :   15.05.2014
 *
 *******************************************************/
public without sharing class GDT_ManageActivity {
    
    /**
     * EditName()
     *  This function will automatically create 
     *  the name of a record for an activity
     *
     * Retrun value (format) : S00-YYYY-XX
     */
    public void EditName(GDT_Activity__c act){
        //Variable Declaration
        Datetime    dtYear      = Datetime.now();           //Date of the day
        String      year_Date   = dtYear.format('YYYY');    //Current year  

        String  serviceChoose   = '';   //ID of Service to record
        String  serviceCode     = '';   //Template code of Service
        Decimal serviceCounter  = 0;    //Value of counter

        try {
            //Retrieves the ID, Code and Counter of the Service
            serviceChoose   = act.GDT_Services__c;
            serviceCode     = [SELECT Code__c FROM GDT_Services__c WHERE Id = :serviceChoose].Code__c;
            serviceCounter  = [SELECT Counter__c FROM GDT_Services__c WHERE Id = :serviceChoose].Counter__c;

            //Before    : SFDC_S00
            //After     : S00
            if(serviceCode.startsWith('SFDC-') == true){
                serviceCode = serviceCode.substring(5);
            }

            //Result
            act.Activity_Name__c = serviceCode + '-' + year_Date + '-'  + String.valueOf(serviceCounter);

        } catch(Exception e) {
            System.debug('ERROR EditName(): ' + e.getMessage());
            act.Activity_Name__c = 'S00-' + year_Date + '-0';
        }
    }
    

    /**
     * UpdateCounter()
     *  Allows you to update the counter value which corresponds
     *  to the number of activities for a service
     */
    public void UpdateCounter(GDT_Activity__c act){
        //Variable declaration
        String serviceChoose = act.GDT_Services__c; //ID of Service to record

        try {
            //List of Services
            List<GDT_Services__c> list_Services     = [SELECT Id, Name, Counter__c FROM GDT_Services__c];
            List<GDT_Services__c> upList_Services = new List<GDT_Services__c>();
            
            //Brow the list of Services,
            //to increment the counter corresponding to the selected Service
            for(GDT_Services__c service : list_Services){
                if(serviceChoose == service.Id){
                    service.Counter__c += 1;
                    upList_Services.add(service);
                }
            }
            update upList_Services;

        } catch(Exception e) {
            System.debug('ERROR1 UpdateCounter(): ' + e.getMessage());
            System.debug('ERROR2 UpdateCounter(): Counter no updated');
        }
    }


    /**
     * ResetCounter()
     *  Set counter to 0 each new year for all Services
     */
    public void ResetCounter(GDT_Activity__c act){
        //Variable declaration
        String serviceChoose    = act.GDT_Services__c; //ID of Service to record

        try {
            List<GDT_Services__c> list_Services     = [SELECT Id, Name, Counter__c FROM GDT_Services__c];
            List<GDT_Services__c> upList_Services   = new List<GDT_Services__c>();

            //Number of records created this year       
            Integer numberActivities = [SELECT count() FROM GDT_Activity__c WHERE CreatedDate = THIS_YEAR AND GDT_Services__c = :serviceChoose];

            if (numberActivities == 0) {
                for(GDT_Services__c service : list_Services){
                    if(serviceChoose == service.Id){
                        service.Counter__c = 01;
                        upList_Services.add(service);
                    }
                }
                update upList_Services;
            }

        } catch(Exception e) {
            System.debug('ERROR ResetCounter(): ' + e.getMessage());
        }       
    }

    /**
     * RecordFormat()
     *  Force writing the names of sandbox capitalized
     */
    public void RecordFormat(GDT_Activity__c act){
        if(act.Sandbox_Name__c != null){
            //String myString_SandboxName = act.Sandbox_Name__c;
            //myString_SandboxName = myString_SandboxName.toUpperCase();
            //act.Sandbox_Name__c = myString_SandboxName;
            act.Sandbox_Name__c = (act.Sandbox_Name__c).toUpperCase();
        }

        if(act.Environment_Destination__c != null){
            String myString_EnvDestination = act.Environment_Destination__c;
            myString_EnvDestination = myString_EnvDestination.toUpperCase();
            act.Environment_Destination__c = myString_EnvDestination;
        }

        if(act.Environment_Source__c != null){
            String myString_EnvSource = act.Environment_Source__c;
            myString_EnvSource = myString_EnvSource.toUpperCase();
            act.Environment_Source__c = myString_EnvSource;
        }
    }

    /**
     * CreateIncident()
     *  Creation of an incident Remedy for the creation of an activity
     *  Call : BeforeInsert (Activity)
     */
    public void CreateIncident(GDT_Activity__c act){
        GDT_Services__c objService;

        try {
            objService = [SELECT Name, BMCImpact__c, BMCUrgency__c FROM GDT_Services__c WHERE Id = :act.GDT_Services__c];
        } catch(Exception e) {
            objService = [SELECT Name, BMCImpact__c, BMCUrgency__c FROM GDT_Services__c WHERE Code__c = :act.Service_Code__c];
            act.GDT_Services__c = objService.Id;
            System.debug(e.getMessage());
        }
        
        // Created object Incident
        BMCServiceDesk__Incident__c incident = new BMCServiceDesk__Incident__c();
            //Template, Stauts and Priority
            try {
                incident.OwnerId = [SELECT Id FROM Group WHERE DeveloperName = 'PRG_Competency_Center' LIMIT 1].Id; // Owner ID
                incident.BMCServiceDesk__FKOpenBy__c = [SELECT Id FROM User WHERE Username LIKE 'globaldev.team@pernod-ricard.com%' LIMIT 1].Id; // Staff
            } catch(Exception e) {
                System.debug('Error completed Staff or Owner ID : '  + e.getMessage());
            }
            
            incident.BMCServiceDesk__IncidentType__c    = 'Service Request'; //Incident Type
            incident.BMCServiceDesk__contactType__c     = 'Email message'; //Incident source
            incident.BMCServiceDesk__queueName__c       = 'PRG - Competency Center'; //Queue Name
            incident.BMCServiceDesk__FKCategory__c      = [SELECT Id FROM BMCServiceDesk__Category__c WHERE Name = 'SFDC - Platform'].Id;
            //incident.BMCServiceDesk__state__c           = false;
            incident.BMCServiceDesk__FKImpact__c        = objService.BMCImpact__c;
            incident.BMCServiceDesk__FKUrgency__c       = objService.BMCUrgency__c;
            
            //Client Details

            incident.BMCServiceDesk__FKClient__c = act.PR_Requester_Name__c; //UserInfo.getUserId();Client ID (UserInfo.getUserId()) globaldev.team
            incident.BMCServiceDesk__PreferredContactMethod__c  = 'Email'; //Preferred Contact Method
            
            ///Incident Summary and Original Description
            incident.RF_Summary__c  = objService.Name + ' / n° ' + act.Activity_Name__c ;
            incident.Summary__c     = objService.Name + ' / n° ' + act.Activity_Name__c ;
            
            //Description Incident
            if(act.Project_Name__c == null && act.Sandbox_Name__c == null && act.Project_Description__c == null) {}
            else {
                if(act.Sandbox_Name__c != null) {
                    if ( act.Project_Description__c != null){
                        incident.BMCServiceDesk__incidentDescription__c = act.Sandbox_Name__c + ' (' + act.Project_Description__c + ')';
                    }else{
                        incident.BMCServiceDesk__incidentDescription__c = act.Sandbox_Name__c;
                    }
                    
                }
                else if(act.Project_Name__c != null) {
                    if ( act.Project_Description__c != null){
                        if ( act.Environment_Destination__c != null){
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c + ' ( ' + act.Environment_Destination__c +' : '+ act.Project_Description__c + ' )';
                        }else{
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c + ' ( ' + act.Project_Description__c + ' )';
                        }
                    }else{
                        if ( act.Environment_Destination__c != null){
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c + ' ( ' + act.Environment_Destination__c + ' )';
                        }else{
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c;
                        }
                    }
                }
            }

            try {
                insert incident;   
            } catch(Exception e) {
                System.debug(e.getMessage());
            }

            //Association between activity and incident
            act.Incident__c = incident.Id;

            try {
                //ASSIGNED
                //incident.BMCServiceDesk__FKStatus__c = [SELECT Id FROM BMCServiceDesk__Status__c WHERE Name='ASSIGNED'].Id;
                //update incident;
                incident.BMC_RF_Responded_Date__c = Datetime.now();
                incident.BMCServiceDesk__respondedDateTime__c = Datetime.now();

                //IN PROGRESS
                incident.BMCServiceDesk__FKStatus__c = [SELECT Id FROM BMCServiceDesk__Status__c WHERE Name='IN PROGRESS'].Id;
                update incident; 

            } catch(Exception e) {
                System.debug('ERROR CreateIncident(): ' + e.getMessage());
            }
    }

    /**
     * DeleteIncident()
     *  Remove the incident of the activity
     */
    public void DeleteIncident(GDT_Activity__c act){
        try {
            BMCServiceDesk__Incident__c incident = [SELECT Id FROM BMCServiceDesk__Incident__c WHERE Id = :act.Incident__c]; 
            delete incident;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
     * CheckStatus()
     *  Checking the status of the activity
     *  BeforeUpdate (Activity)
     */
    public void CheckStatus(GDT_Activity__c act){
        try {
            BMCServiceDesk__Incident__c incident = [SELECT Id, BMCServiceDesk__FKStatus__c, BMCServiceDesk__incidentResolution__c, BMCServiceDesk__ClosureCategory__c FROM BMCServiceDesk__Incident__c WHERE Id = :act.Incident__c];

            //Synchronisation Status (Salesforce/Remedy)
            if(act.Status__c == 'Closed' && (incident.BMCServiceDesk__FKStatus__r.Name != 'CLOSED')) {
                incident.BMCServiceDesk__FKStatus__c = [SELECT Id FROM BMCServiceDesk__Status__c WHERE Name='RESOLVED' AND BMCServiceDesk__appliesToIncident__c=true AND BMCServiceDesk__inactive__c=false].Id;
                incident.BMCServiceDesk__incidentResolution__c = 'Service request is completed';
                incident.BMCServiceDesk__ClosureCategory__c = 'Request Fullfilled';
            }

            if(act.Status__c == 'In Progress'){
                incident.BMCServiceDesk__FKStatus__c = [SELECT Id FROM BMCServiceDesk__Status__c WHERE Name='IN PROGRESS'].Id;
            }

            if(act.Status__c == 'Waiting for user'){
                incident.BMCServiceDesk__FKStatus__c = [SELECT Id FROM BMCServiceDesk__Status__c WHERE Name='WAITING FOR USER'].Id;
            }
            
            if(act.Status__c == 'Resolved'){
                incident.BMCServiceDesk__FKStatus__c = [SELECT Id FROM BMCServiceDesk__Status__c WHERE Name='RESOLVED'].Id;
                incident.BMCServiceDesk__incidentResolution__c = 'Service request is completed';
                incident.BMCServiceDesk__ClosureCategory__c = 'Request Fullfilled';
            }
            
            update incident;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    /**
     * UpdateIncident()
     *  Updating the incident fields after update activity
     *  Call : BeforeUpdate (Activity)
     */
    public void UpdateIncident(GDT_Activity__c act){
        //Boolean hasOpened = false;
        String serviceName = ' ';

        try {
            ServiceName = [SELECT Name FROM GDT_Services__c WHERE Id = :act.GDT_Services__c].Name;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    
        try {
            BMCServiceDesk__Incident__c incident = [SELECT Id, BMCServiceDesk__Status_ID__c, BMCServiceDesk__FKStatus__c, RF_Summary__c, Summary__c, BMCServiceDesk__incidentDescription__c, BMCServiceDesk__FKClient__c FROM BMCServiceDesk__Incident__c WHERE Id = :act.Incident__c];

            //Client Details
            incident.BMCServiceDesk__FKClient__c = act.PR_Requester_Name__c;

            //Incident Summary and Original Description
            incident.RF_Summary__c  = serviceName + ' / n° ' + act.Activity_Name__c;
            incident.Summary__c  = serviceName + ' / n° ' + act.Activity_Name__c;
            //Description Incident
            if(act.Project_Name__c == null && act.Sandbox_Name__c == null && act.Project_Description__c == null) {}
            else {
                if(act.Sandbox_Name__c != null) {
                    if ( act.Project_Description__c != null){
                        incident.BMCServiceDesk__incidentDescription__c = act.Sandbox_Name__c + ' (' + act.Project_Description__c + ')';
                    }else{
                        incident.BMCServiceDesk__incidentDescription__c = act.Sandbox_Name__c;
                    }
                    
                }
                else if(act.Project_Name__c != null) {
                    if ( act.Project_Description__c != null){
                        if ( act.Environment_Destination__c != null){
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c + ' ( ' + act.Environment_Destination__c +' : '+ act.Project_Description__c + ' )';
                        }else{
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c + ' ( ' + act.Project_Description__c + ' )';
                        }
                    }else{
                        if ( act.Environment_Destination__c != null){
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c + ' ( ' + act.Environment_Destination__c + ' )';
                        }else{
                            incident.BMCServiceDesk__incidentDescription__c = act.Project_Name__c;
                        }
                    }
                }
            }
            
            update incident;

        } catch(Exception e) {
            System.debug('ERROR UpdateIncident(): ' + e.getMessage());
        }
    }

}//GDT_ManageActivity
public with sharing class LAT_RegionalSupervisorHandler {
    public LAT_RegionalSupervisorHandler() {}

    public static void updateNames(){
         for(LAT_RegionalSupervisor__c rs : (List<LAT_RegionalSupervisor__c>)trigger.new){
                rs.name = rs.LAT_RegionalClientOnPremise__c;
         }
    }

}
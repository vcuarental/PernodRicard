trigger RIC_ActeurAfterDelete on RIC_Acteur__c (after delete) {
    RIC_AP01_Acteur.deleteProjectShareFromActeur(trigger.old);
}
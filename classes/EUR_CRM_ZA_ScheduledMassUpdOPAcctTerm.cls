global class EUR_CRM_ZA_ScheduledMassUpdOPAcctTerm implements Schedulable {
   global void execute(SchedulableContext sc) {
      EUR_CRM_ZA_MassUpdOPAcctTermnination b = new EUR_CRM_ZA_MassUpdOPAcctTermnination(); 
      Database.executebatch(b, 200);
   }
}
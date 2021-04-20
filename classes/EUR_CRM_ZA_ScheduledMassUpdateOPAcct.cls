global class EUR_CRM_ZA_ScheduledMassUpdateOPAcct implements Schedulable {
   global void execute(SchedulableContext sc) {
      EUR_CRM_ZA_MassUpdateOPAccountMapping b = new EUR_CRM_ZA_MassUpdateOPAccountMapping(); 
      Database.executebatch(b, 200);
   }
}
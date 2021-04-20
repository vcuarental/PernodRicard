global class ASI_CRM_TW_SalesVolumeCalculation_Schd implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new ASI_CRM_TW_SalesVolumeCalculation_Batch());
   }
}
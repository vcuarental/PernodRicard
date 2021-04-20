Global class ASI_MFM_CN_ReceiptGeneration_Schd implements Schedulable{
    
    Global void execute(SchedulableContext sc) {
        
        database.executebatch(new ASI_MFM_CN_ReceiptGeneration_Batch());
    }
}
/**********************************************************************************************
*                                  Company: ValueNet                                          *
*---------------------------------------------------------------------------------------------*
* Clase schedule que ejecuta el batch de Clean Account Product Payment                        *
***********************************************************************************************/

global class LAT_CleanAccProductPaymentScheduler implements Schedulable {

    global Id idCAPP;

    global void execute(SchedulableContext SC){
    
        LAT_Clean_Account_Product_Payment__c CAPP_record = [SELECT Id, TimeStamp__c, LAT_Country__c, CreatedDate, LAT_Status__c
                                                            FROM LAT_Clean_Account_Product_Payment__c WHERE Id =: idCAPP]; 
        Datetime now = dateTime.now();
        
        //solo se va a intentar ejecutar el batch por 20m, sino se considera timeout
        if(CAPP_record.CreatedDate.addMinutes(20) >= now){       
            List<AsyncApexJob> listAsyncApexJob = [SELECT id FROM AsyncApexJob 
                                                   WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
            //se chequea el limite de Salesforce, si hay cupo disponible se ejecuta el batch, sino se vuelve a hacer el schedule            
            if (listAsyncApexJob == null || listAsyncApexJob != null && listAsyncApexJob.size() < 5){
                
                CAPP_record.LAT_Status__c = 'Processing';
                try{update CAPP_record;}catch(exception e){}
                
                LAT_CleanAccountProductPaymentBatch batchToRun = new LAT_CleanAccountProductPaymentBatch();
                batchToRun.timeStamp = CAPP_record.TimeStamp__c;
                batchToRun.country = CAPP_record.LAT_Country__c;
                batchToRun.idCAPP = CAPP_record.Id;
                Database.executeBatch(batchToRun);
            }else{                
                DateTime nowTime = datetime.now().addSeconds(65);
                String Seconds = '0';
                String Minutes = String.valueOf(nowTime.minute()).length() == 1 ? '0' + String.valueOf(nowTime.minute()) : String.valueOf(nowTime.minute());
                String Hours = String.valueOf(nowTime.hour()).length() == 1 ? '0' + String.valueOf(nowTime.hour()) : String.valueOf(nowTime.hour());
                String DayOfMonth = String.valueOf(nowTime.day());
                String Month = String.ValueOf(nowTime.month());
                String DayOfweek = '?';
                String optionalYear = String.valueOf(nowTime.year());
                String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
                
                LAT_CleanAccProductPaymentScheduler scheduleToRun = new LAT_CleanAccProductPaymentScheduler();
                scheduleToRun.idCAPP = idCAPP;    
                String idjob = system.schedule('LAT_CleanAccProductPaymentScheduler '+system.now(), CronExpression, scheduleToRun);
            }
        }else{
            CAPP_record.LAT_Status__c = 'Timeout';
            try{update CAPP_record;}catch(exception e){}               
        }
    }
}
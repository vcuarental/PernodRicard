/*Filename:    ASI_CRM_TW_VisitationPlanClone_Ctrl.cls
* Modified By: Twinkle LI (Introv Limited)
* Date:        Nov 28 2016
* Purpose:     Controller Class for Clone TW CRM Visitation Plan
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_VisitationPlanClone_Ctrl{
    public id vpId {set;get;}
    public ASI_HK_CRM_Visitation_Plan_Detail__c inputVpd {set;get;}
    
    public ASI_CRM_TW_VisitationPlanClone_Ctrl(ApexPages.StandardController controller) {
        vpId = ApexPages.currentPage().getParameters().get('id');
        inputVpd = new ASI_HK_CRM_Visitation_Plan_Detail__c();
    }
    
    public PageReference cloneVP(){
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> listToInsertVpd = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        Set<Date> setHolidayDate = new Set<Date>();
        
        Integer intThisMonth;
        Integer intClonedMonth;
        
        Map<Date, Integer> mapClonedMonthWD = new Map<Date, Integer>();
        Map<Integer, Date> mapthisMonthWD = new Map<Integer, Date>();
        
        //get VP to be cloned from                                          
        List<ASI_HK_CRM_Visitation_Plan__c> clonedVp = [SELECT ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c 
                                                  FROM ASI_HK_CRM_Visitation_Plan__c 
                                                  WHERE id =: inputVpd.ASI_HK_CRM_Visitation_Plan__c LIMIT 1];        
        //get cloned month in integer                                          
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'January') intClonedMonth = 1;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'February') intClonedMonth = 2;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'March') intClonedMonth = 3;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'April') intClonedMonth = 4;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'May') intClonedMonth = 5;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'June') intClonedMonth = 6;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'July') intClonedMonth = 7;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'August') intClonedMonth = 8;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'September') intClonedMonth = 9;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'October') intClonedMonth = 10;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'November') intClonedMonth = 11;
        if(clonedVp[0].ASI_HK_CRM_Month__c == 'December') intClonedMonth = 12;
        
        system.debug('Cloned Month: '+intClonedMonth);
        
        //get current VP
        List<ASI_HK_CRM_Visitation_Plan__c> thisVp = [SELECT RecordTypeId, ASI_HK_CRM_Year__c, ASI_HK_CRM_Month__c 
                                                  FROM ASI_HK_CRM_Visitation_Plan__c 
                                                  WHERE id =: vpId LIMIT 1];        
        
        //get this month in integer                                          
        if(thisVp[0].ASI_HK_CRM_Month__c == 'January') intThisMonth = 1;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'February') intThisMonth = 2;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'March') intThisMonth = 3;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'April') intThisMonth = 4;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'May') intThisMonth = 5;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'June') intThisMonth = 6;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'July') intThisMonth = 7;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'August') intThisMonth = 8;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'September') intThisMonth = 9;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'October') intThisMonth = 10;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'November') intThisMonth = 11;
        if(thisVp[0].ASI_HK_CRM_Month__c == 'December') intThisMonth = 12;
        
        system.debug('This Month: '+intThisMonth);
        
        //get holiday of current and cloned VP by Year & Month                                                         
        for(ASI_CRM_Holiday__c holiday : [SELECT ASI_CRM_Date_From__c, ASI_CRM_Date_To__c 
                                          FROM ASI_CRM_Holiday__c 
                                          WHERE ((ASI_CRM_Date_From_Year__c =: thisVp[0].ASI_HK_CRM_Year__c OR ASI_CRM_Date_To_Year__c =: thisVp[0].ASI_HK_CRM_Year__c) AND 
                                                 (ASI_CRM_Date_From_Month__c =: thisVp[0].ASI_HK_CRM_Month__c OR ASI_CRM_Date_To_Month__c =: thisVp[0].ASI_HK_CRM_Month__c)) OR
                                                ((ASI_CRM_Date_From_Year__c =: clonedVp[0].ASI_HK_CRM_Year__c OR ASI_CRM_Date_To_Year__c =: clonedVp[0].ASI_HK_CRM_Year__c) AND
                                                 (ASI_CRM_Date_From_Month__c =: clonedVp[0].ASI_HK_CRM_Month__c OR ASI_CRM_Date_To_Month__c =: clonedVp[0].ASI_HK_CRM_Month__c))]){
            
            Date loopingDate;                               
            while(loopingDate == null || loopingDate < holiday.ASI_CRM_Date_To__c){
                if(loopingDate == null)
                    loopingDate = holiday.ASI_CRM_Date_From__c;
                else
                    loopingDate = loopingDate.addDays(1);
                
                setHolidayDate.add(loopingDate); 
            }   
        }
        system.debug('Holidays: '+setHolidayDate);
        
        //map cloned month working day
        Datetime clonedMonthDate;
        Integer intClonedWDIndex = 0;
        while(clonedMonthDate == null || clonedMonthDate.Month() == intClonedMonth){
            if(clonedMonthDate == null)
                clonedMonthDate = date.newInstance(integer.valueof((clonedVp[0].ASI_HK_CRM_Year__c)), intClonedMonth, 1);
            else
                clonedMonthDate = clonedMonthDate.addDays(1);
                
            if(clonedMonthDate != null && clonedMonthDate.Month() == intClonedMonth && 
               clonedMonthDate.format('EEEE') != 'Saturday' && clonedMonthDate.format('EEEE') != 'Sunday' && 
               !setHolidayDate.contains(clonedMonthDate.date())){
                mapClonedMonthWD.put(clonedMonthDate.date(), ++intClonedWDIndex);
            }
        }
        system.debug('Cloned VP WD: '+mapClonedMonthWD);
        
        //map this month working day
        Datetime thisMonthDate;
        Integer intThisWDIndex = 0;
        while(thisMonthDate == null || thisMonthDate.Month() == intThisMonth){
            if(thisMonthDate == null)
                thisMonthDate = date.newInstance(integer.valueof((thisVp[0].ASI_HK_CRM_Year__c)), intThisMonth, 1);
            else
                thisMonthDate = thisMonthDate.addDays(1);
                
            if(thisMonthDate != null && thisMonthDate.Month() == intThisMonth &&
               thisMonthDate.format('EEEE') != 'Saturday' && thisMonthDate.format('EEEE') != 'Sunday' && 
               !setHolidayDate.contains(thisMonthDate.date())){
                mapThisMonthWD.put(++intThisWDIndex, thisMonthDate.date());
            }
        }
        system.debug('This VP WD: '+mapThisMonthWD);
        
        //get cloned VPD: get own & active Account's VPD with Visit Date
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> listClonedVpd = [SELECT id, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Account__c
                                                             FROM ASI_HK_CRM_Visitation_Plan_Detail__c 
                                                             WHERE ASI_HK_CRM_Visitation_Plan__c =: inputVpd.ASI_HK_CRM_Visitation_Plan__c 
                                                             AND ASI_HK_CRM_Visit_Date__c != NULL
                                                             AND ASI_CRM_Account_Inactive__c = FALSE 
                                                             AND ASI_HK_CRM_Account__r.OwnerId =: UserInfo.getUserId()
                                                             ORDER BY ASI_HK_CRM_Visit_Date__c ASC];
        
        //
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : listClonedVpd){
            if(mapThisMonthWD.get(mapClonedMonthWD.get(vpd.ASI_HK_CRM_Visit_Date__c)) != null){
                ASI_HK_CRM_Visitation_Plan_Detail__c newVpd = new ASI_HK_CRM_Visitation_Plan_Detail__c();
                
                if(thisVp[0].recordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_TW_Visitation_Plan'))
                    newVpd.recordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Visitation_Plan_Detail');
                else
                    newVpd.recordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Merchandiser_Visitation_Plan_Detail');
                    
                newVpd.ASI_HK_CRM_Visitation_Plan__c = thisVp[0].id;
                newVpd.ASI_HK_CRM_Visit_Date__c = mapThisMonthWD.get(mapClonedMonthWD.get(vpd.ASI_HK_CRM_Visit_Date__c));
                newVpd.ASI_HK_CRM_Account__c = vpd.ASI_HK_CRM_Account__c;
                
                listToInsertVpd.add(newVpd);
            }
        }
        system.debug('listToInsertVpd: '+listToInsertVpd);
        
        //generate cloned vpd - exclude Holidays & Weekends, ignore remaining     
        /*Datetime assignDate;
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : listClonedVpd){
            if(assignDate == null)
                assignDate = date.newInstance(integer.valueof((thisVp[0].ASI_HK_CRM_Year__c)), intThisMonth, 1);
            else
                assignDate = assignDate.addDays(1);
                
            while(assignDate != null &&
                 ((assignDate.format('EEEE') == 'Saturday' || assignDate.format('EEEE') == 'Sunday') ||
                 setHolidayDate.contains(assignDate.date()))){
                assignDate = assignDate.addDays(1);
            }
            system.debug('Date: '+assignDate.date()); 
            system.debug('Day of Week: '+assignDate.format('EEEE'));
            
            system.debug('Assign Month: '+assignDate.Month()); 
            if(assignDate.Month() != intThisMonth)
                break; 
            
            ASI_HK_CRM_Visitation_Plan_Detail__c newVpd = new ASI_HK_CRM_Visitation_Plan_Detail__c();
            
            if(thisVp[0].recordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_TW_Visitation_Plan'))
                newVpd.recordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Visitation_Plan_Detail');
            else
                newVpd.recordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_TW_Merchandiser_Visitation_Plan_Detail');
                
            newVpd.ASI_HK_CRM_Visitation_Plan__c = thisVp[0].id;
            newVpd.ASI_HK_CRM_Visit_Date__c = assignDate.date();
            newVpd.ASI_HK_CRM_Account__c = vpd.ASI_HK_CRM_Account__c;
            
            listToInsertVpd.add(newVpd);
        }    
        system.debug('listToInsertVpd: '+listToInsertVpd);*/
        
        if(listToInsertVpd != null && listToInsertVpd.size() > 0)
            insert listToInsertVpd;
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'No details to be cloned, please select another Visitation Plan.'));
            return null;
        }
        
        PageReference vpPage = new PageReference('/'+vpId);
        vpPage.setRedirect(true);

        return vpPage;         
    } 
}
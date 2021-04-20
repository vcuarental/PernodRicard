/******************************************************************************************
*                           Company: ValueNet
*------------------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto LAT_BR_ClientChannelSegmentation__c
*******************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/    
public with sharing class LAT_BR_AP01_ClientChannelSegment {
    
    /*****************************************************************************************
    * Nombre del metodo: ObtainedSubChannelOnTrade
    * Descripcion: fills the field "LAT_BR_ObtainedSubChannel__c" for recordtypes On Trade
    * Desarrollador: Denis Aranda
    * Fecha: 27/05/2014
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void ObtainedSubChannelOnTrade(List<LAT_BR_ClientChannelSegmentation__c> triggerNew){
        
        Set<String> setIdsOfSeg = new Set<String>();
        String ProfileExceptionValue;
        String ChannelExceptionValue;
        String ProfileException;
        String ChannelException;
        String newSubChannel = '';
        
        //Creates Maps
        Map<String, List<String>> mapProAnsQAToListAnsCode = new Map<String, List<String>>();
        Map<String, String> mapSubChanQAToAnsCode = new Map<String, String>();
        Map<String, String> mapSubChanKeyToSubCha = new Map<String, String>();
        Map<String, String> mapProWeiQAToAnsCode = new Map<String, String>();
        Map<String, String> mapSubWeiQAToAnsCode = new Map<String, String>();
        Map<String, String> mapProAnsQAToAnsCode = new Map<String, String>();
        Map<String, String> mapBusSizQAToAnsCode = new Map<String, String>();
        
        Set<String> setIdOfAccOnSegAll = new Set<String>();
        
        String ObtainedSubChannel = null;
        
        for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
            if(trigger.isUpdate){
                ObtainedSubChannel = seg.LAT_BR_ObtainedSubChannel__c;
            }
            setIdOfAccOnSegAll.add(seg.LAT_BR_Client__c);
        }
        
        Map<Id, Account> mapIdtoAcc = new Map<Id, Account>([SELECT id, Status__c, LAT_BR_ActingFormat__c FROM Account WHERE Id IN: setIdOfAccOnSegAll ]);
    
        if(trigger.isUpdate){
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(seg.LAT_BR_ApprovalStatus__c == 'Draft' || seg.LAT_BR_ApprovalStatus__c == 'Rejected' || (seg.LAT_BR_ApprovalStatus__c == 'Active' && (mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Novo cadastro' || mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Não aprovado'))){
                    setIdsOfSeg.add(seg.id);
                }
            }
        }
        
        if(!setIdsOfSeg.isEmpty() || trigger.isInsert){
            
            //fills Maps
            List<LAT_BR_ClientSegmentationParameters__c> listCsp = [SELECT id, Name, LAT_BR_DataType__c, LAT_BR_Question__c, LAT_BR_BusinessSize__c, LAT_BR_Answer__c, LAT_BR_AnswerCode__c, LAT_BR_Key__c, LAT_BR_SubChannel__c, LAT_BR_Profile__c FROM LAT_BR_ClientSegmentationParameters__c ORDER BY LAT_BR_AnswerCode__c DESC];  
            for(LAT_BR_ClientSegmentationParameters__c par: listCsp){
                //Map for Sub_Channel Code Answer
                if(par.LAT_BR_DataType__c == 'Sub_Channel Code Answer'){
                    mapSubChanQAToAnsCode.put(par.LAT_BR_Question__c +'-'+ par.LAT_BR_Answer__c, par.LAT_BR_AnswerCode__c);
                }
                //Map for Sub_Channel Key
                if(par.LAT_BR_DataType__c == 'Sub_Channel Key'){
                    mapSubChanKeyToSubCha.put(par.LAT_BR_Key__c, par.LAT_BR_SubChannel__c);
                }
                //Map for Profile Weight
                if(par.LAT_BR_DataType__c == 'Profile Weight'){
                    mapProWeiQAToAnsCode.put(par.LAT_BR_Question__c +'-'+ par.LAT_BR_Answer__c, par.LAT_BR_AnswerCode__c);
                }
                //Map for Sub_Channel Weight
                if(par.LAT_BR_DataType__c == 'Sub_Channel Weight'){
                    mapSubWeiQAToAnsCode.put(par.LAT_BR_Question__c +'-'+ par.LAT_BR_Answer__c, par.LAT_BR_AnswerCode__c);
                }
                //2 Map for Profile Answer
                if(par.LAT_BR_DataType__c == 'Profile Answer'){
                    mapProAnsQAToAnsCode.put(par.LAT_BR_Answer__c +'-'+ par.LAT_BR_AnswerCode__c, par.LAT_BR_Profile__c);
                    if(!mapProAnsQAToListAnsCode.containsKey(par.LAT_BR_Answer__c)){
                        mapProAnsQAToListAnsCode.put(par.LAT_BR_Answer__c, new List<String>{par.LAT_BR_AnswerCode__c});
                    }else{
                        mapProAnsQAToListAnsCode.get(par.LAT_BR_Answer__c).add(par.LAT_BR_AnswerCode__c);
                    }
                }
                if(par.LAT_BR_DataType__c == 'Sub_Channel Exception'){
                    ChannelException = par.LAT_BR_Answer__c;
                    ChannelExceptionValue = par.LAT_BR_SubChannel__c; 
                }
                if(par.LAT_BR_DataType__c == 'Profile Exception'){
                    ProfileException = par.LAT_BR_Answer__c;
                    ProfileExceptionValue = par.LAT_BR_Profile__c;
                }
                if(par.LAT_BR_DataType__c == 'Business Size'){
                    mapBusSizQAToAnsCode.put(par.LAT_BR_Answer__c, par.LAT_BR_BusinessSize__c);
                }
            }
            
            //consults the maps to fill in the field if not found in the maps leaves field empty 
            for(LAT_BR_ClientChannelSegmentation__c seg : triggerNew){
                if(setIdsOfSeg.contains(seg.id) || trigger.isInsert){
                    //sets the LAT_BR_ObtainedSubChannel__c field
                    if(seg.LAT_BR_AdultEntertainmentHouse__c != null && seg.LAT_BR_AdultEntertainmentHouse__c == ChannelException){
                        newSubChannel = ChannelExceptionValue;
                        seg.LAT_BR_ObtainedSubChannel__c = ChannelExceptionValue;
                    }else{
                        String key = '';
                        key += seg.LAT_BR_MainBillFocus__c != null && mapSubChanQAToAnsCode.containsKey('LAT_BR_MainBillFocus__c' +'-'+ seg.LAT_BR_MainBillFocus__c) ? mapSubChanQAToAnsCode.get('LAT_BR_MainBillFocus__c' +'-'+ seg.LAT_BR_MainBillFocus__c):'';
                        key += seg.LAT_BR_MainConsumptionOccasion__c != null && mapSubChanQAToAnsCode.containsKey('LAT_BR_MainConsumptionOccasion__c' +'-'+ seg.LAT_BR_MainConsumptionOccasion__c) ? mapSubChanQAToAnsCode.get('LAT_BR_MainConsumptionOccasion__c' +'-'+ seg.LAT_BR_MainConsumptionOccasion__c):'';
                        key += seg.LAT_BR_PubPhysicalSpace__c != null && mapSubChanQAToAnsCode.containsKey('LAT_BR_PubPhysicalSpace__c' +'-'+ seg.LAT_BR_PubPhysicalSpace__c) ? mapSubChanQAToAnsCode.get('LAT_BR_PubPhysicalSpace__c' +'-'+ seg.LAT_BR_PubPhysicalSpace__c):'';
                        key += seg.LAT_BR_ActivitiesStartTime__c != null && mapSubChanQAToAnsCode.containsKey('LAT_BR_ActivitiesStartTime__c' +'-'+ seg.LAT_BR_ActivitiesStartTime__c) ? mapSubChanQAToAnsCode.get('LAT_BR_ActivitiesStartTime__c' +'-'+ seg.LAT_BR_ActivitiesStartTime__c):'';
                        key += seg.LAT_BR_Music__c != null && mapSubChanQAToAnsCode.containsKey('LAT_BR_Music__c' +'-'+ seg.LAT_BR_Music__c) ? mapSubChanQAToAnsCode.get('LAT_BR_Music__c' +'-'+ seg.LAT_BR_Music__c):'';
                        if(mapSubChanKeyToSubCha.containsKey(key)){
                            newSubChannel = mapSubChanKeyToSubCha.get(key);
                            seg.LAT_BR_ObtainedSubChannel__c = newSubChannel;
                        }else{
                            seg.addError(Label.LAT_BR_AP01_CCS_001);
                            //LAT_BR_AP01_CCS_001: Please revise your answers for the questionnaire, as no valid segmentation was found for Account with the answers provided.
                            return;
                        }
                    }
                    
                    // Gets the profile
                    if(seg.LAT_BR_IconicHouse__c != null && seg.LAT_BR_IconicHouse__c == ProfileException){
                        seg.LAT_BR_ObtainedProfile__c = ProfileExceptionValue;
                    }else{
                        Decimal numkey = 0;
                        Decimal numkeyTotal = 0;
                        //LAT_BR_MainBrandsSold__c
                        if(seg.LAT_BR_MainBrandsSold__c != null){
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainBrandsSold__c' +'-'+ seg.LAT_BR_MainBrandsSold__c)){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_MainBrandsSold__c' +'-'+ seg.LAT_BR_MainBrandsSold__c));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainBrandsSold__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_MainBrandsSold__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }
                            
                        }else{
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainBrandsSold__c' +'-'+ 'null')){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_MainBrandsSold__c' +'-'+ 'null'));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainBrandsSold__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_MainBrandsSold__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }   
                        }
                        
                        if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_MainBrandsSold__c' +'-'+ newSubChannel)){
                            numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_MainBrandsSold__c' +'-'+ newSubChannel));
                        }else{
                            if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_MainBrandsSold__c' +'-'+ '-')){
                                numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_MainBrandsSold__c' +'-'+ '-'));
                            }else{
                                seg.addError(Label.LAT_BR_AP01_CCS_003);  return;
                                // Label.LAT_BR_AP01_CCS_003 = Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Sub Channel Weight" the segmentation cannot be calculated
                            }
                        }
                        
                        //LAT_BR_MainDrinks__c
                        if(seg.LAT_BR_MainDrinks__c != null){
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainDrinks__c' +'-'+ seg.LAT_BR_MainDrinks__c)){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_MainDrinks__c' +'-'+ seg.LAT_BR_MainDrinks__c));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainDrinks__c' +'-'+ '-')){
                                    numkey = decimal.valueOf( mapProWeiQAToAnsCode.get('LAT_BR_MainDrinks__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }
                            
                        }else{
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainDrinks__c' +'-'+ 'null')){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_MainDrinks__c' +'-'+ 'null'));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_MainDrinks__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_MainDrinks__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }   
                        }
                        
                        if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_MainDrinks__c' +'-'+ newSubChannel)){
                            numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_MainDrinks__c' +'-'+ newSubChannel));
                        }else{
                            if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_MainDrinks__c' +'-'+ '-')){
                                numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_MainDrinks__c' +'-'+ '-'));
                            }else{
                                seg.addError(Label.LAT_BR_AP01_CCS_003); return;
                                // Label.LAT_BR_AP01_CCS_003 = Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Sub Channel Weight" the segmentation cannot be calculated
                            }
                        }
                        
                        //LAT_BR_Brigade__c
                        if(seg.LAT_BR_Brigade__c != null){
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_Brigade__c' +'-'+ seg.LAT_BR_Brigade__c)){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_Brigade__c' +'-'+ seg.LAT_BR_Brigade__c));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_Brigade__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_Brigade__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }
                            
                        }else{
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_Brigade__c' +'-'+ 'null')){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_Brigade__c' +'-'+ 'null'));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_Brigade__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_Brigade__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002);
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                    return;
                                }
                            }   
                        }
                        
                        if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_Brigade__c' +'-'+ newSubChannel)){
                            numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_Brigade__c' +'-'+ newSubChannel));
                        }else{
                            if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_Brigade__c' +'-'+ '-')){
                                numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_Brigade__c' +'-'+ '-'));
                            }else{
                                seg.addError(Label.LAT_BR_AP01_CCS_003); return;
                                // Label.LAT_BR_AP01_CCS_003 = Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Sub Channel Weight" the segmentation cannot be calculated
                            }
                        }
                        
                        //LAT_BR_ConsumerProfile__c
                        if(seg.LAT_BR_ConsumerProfile__c != null){
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_ConsumerProfile__c' +'-'+ seg.LAT_BR_ConsumerProfile__c)){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_ConsumerProfile__c' +'-'+ seg.LAT_BR_ConsumerProfile__c));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_ConsumerProfile__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_ConsumerProfile__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }
                            
                        }else{
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_ConsumerProfile__c' +'-'+ 'null')){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_ConsumerProfile__c' +'-'+ 'null'));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_ConsumerProfile__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_ConsumerProfile__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002);
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                    return;
                                }
                            }   
                        }
                        
                        if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_ConsumerProfile__c' +'-'+ newSubChannel)){
                            numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_ConsumerProfile__c' +'-'+ newSubChannel));
                        }else{
                            if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_ConsumerProfile__c' +'-'+ '-')){
                                numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_ConsumerProfile__c' +'-'+ '-'));
                            }else{
                                seg.addError(Label.LAT_BR_AP01_CCS_003);  return;
                                // Label.LAT_BR_AP01_CCS_003 = Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Sub Channel Weight" the segmentation cannot be calculated
                            }
                        }
                        
                        //LAT_BR_AverageSodaCansPrice__c
                        if(seg.LAT_BR_AverageSodaCansPrice__c != null){
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageSodaCansPrice__c' +'-'+ seg.LAT_BR_AverageSodaCansPrice__c)){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageSodaCansPrice__c' +'-'+ seg.LAT_BR_AverageSodaCansPrice__c));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageSodaCansPrice__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageSodaCansPrice__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002);  return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }
                            
                        }else{
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageSodaCansPrice__c' +'-'+ 'null')){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageSodaCansPrice__c' +'-'+ 'null'));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageSodaCansPrice__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageSodaCansPrice__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002);
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                    return;
                                }
                            }   
                        }
                        
                        if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_AverageSodaCansPrice__c' +'-'+ newSubChannel)){
                            numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_AverageSodaCansPrice__c' +'-'+ newSubChannel));
                        }else{
                            if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_AverageSodaCansPrice__c' +'-'+ '-')){
                                numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_AverageSodaCansPrice__c' +'-'+ '-'));
                            }else{
                                seg.addError(Label.LAT_BR_AP01_CCS_003);  return;
                                // Label.LAT_BR_AP01_CCS_003 = Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Sub Channel Weight" the segmentation cannot be calculated
                            }
                        }
                        
                        //LAT_BR_AverageMainMealPrice__c
                        if(seg.LAT_BR_Brigade__c != null){
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageMainMealPrice__c' +'-'+ seg.LAT_BR_AverageMainMealPrice__c)){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageMainMealPrice__c' +'-'+ seg.LAT_BR_AverageMainMealPrice__c));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageMainMealPrice__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageMainMealPrice__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }
                            
                        }else{
                            if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageMainMealPrice__c' +'-'+ 'null')){
                                numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageMainMealPrice__c' +'-'+ 'null'));
                            }else{
                                if(mapProWeiQAToAnsCode.containsKey('LAT_BR_AverageMainMealPrice__c' +'-'+ '-')){
                                    numkey = decimal.valueOf(mapProWeiQAToAnsCode.get('LAT_BR_AverageMainMealPrice__c' +'-'+ '-'));
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_002); return;
                                    //LAT_BR_AP01_CCS_002: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Profile Weight" the segmentation cannot be calculated.
                                }
                            }   
                        }
                        
                        if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_AverageMainMealPrice__c' +'-'+ newSubChannel)){
                            numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_AverageMainMealPrice__c' +'-'+ newSubChannel));
                        }else{
                            if(mapSubWeiQAToAnsCode.containsKey('LAT_BR_AverageMainMealPrice__c' +'-'+ '-')){
                                numkeyTotal += numkey * decimal.valueOf(mapSubWeiQAToAnsCode.get('LAT_BR_AverageMainMealPrice__c' +'-'+ '-'));
                            }else{
                                seg.addError(Label.LAT_BR_AP01_CCS_003); return;
                                // Label.LAT_BR_AP01_CCS_003 = Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Sub Channel Weight" the segmentation cannot be calculated
                            }
                        }
                        
                        //uses the numberKey created to get the profile
                        if(mapProAnsQAToListAnsCode.containsKey(newSubChannel)){
                            list<decimal> ListNum = new list<decimal>();
                            for(String str: mapProAnsQAToListAnsCode.get(newSubChannel)){
                                if(str != '-'){
                                    ListNum.add(decimal.valueOf(str));
                                }
                            }
                            
                            boolean isDash = true;
                            for(decimal num: ListNum){
                                if(num <= numkeyTotal){
                                    if(mapProAnsQAToAnsCode.ContainsKey(newSubChannel +'-'+ num)){
                                        seg.LAT_BR_ObtainedProfile__c = mapProAnsQAToAnsCode.get(newSubChannel +'-'+ num);
                                        isDash = false;
                                        break;
                                    }else{
                                        seg.addError(Label.LAT_BR_AP01_CCS_004); return;
                                    }
                                }
                            }
                            if(isDash){
                                if(mapProAnsQAToAnsCode.ContainsKey(newSubChannel +'-'+ '-')){
                                    seg.LAT_BR_ObtainedProfile__c = mapProAnsQAToAnsCode.get(newSubChannel +'-'+ '-');
                                }else{
                                    seg.addError(Label.LAT_BR_AP01_CCS_004); return;
                                }
                            }
                            
                           
                        }
                    }
                    //fill the field LAT_BR_ObtainedBusinessSize__c with people capacity
                    if(mapBusSizQAToAnsCode.containsKey(seg.LAT_BR_PeopleCapacity__c)){
                        seg.LAT_BR_ObtainedBusinessSize__c = mapBusSizQAToAnsCode.get(seg.LAT_BR_PeopleCapacity__c);
                    }else{
                        seg.addError(Label.LAT_BR_AP01_CCS_005);  return;
                        //LAT_BR_AP01_CCS_005: Due to missing parameter on the object "Client Segmentation Parameters" with Data Type "Business Size" the segmentation cannot be calculated
                    }
                }
                if(seg.LAT_BR_ObtainedSubChannel__c != ObtainedSubChannel){
                    seg.LAT_BR_ONSegment__c = null;
                }
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: AccUpdaterFromSegOn
    * Descripcion: Updates Account with the values from Segmentacion
    * Desarrollador: Denis Aranda
    * Fecha: 30/05/2014
    * Modo: after Insert, after Update
    *****************************************************************************************/
    public static void AccUpdaterFromSegOn(List<LAT_BR_ClientChannelSegmentation__c> triggerNew, Map<Id,LAT_BR_ClientChannelSegmentation__c> oldMap){
        
        Map<Id, LAT_BR_ClientChannelSegmentation__c> mapIdtoSeg;
        Map<Id, Account> mapIdtoAcc;
        List<LAT_BR_ClientChannelSegmentation__c> listSeg = new List<LAT_BR_ClientChannelSegmentation__c>();
        List<Account> ListOfAccToUpdate = new List<Account>();
        Set<String> setIdOfAccOnSegAll = new Set<String>();
        Set<String> setIdOfAccOnSeg = new Set<String>();
        Set<String> setIdOfSeg = new Set<String>();
        
        for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
            setIdOfAccOnSegAll.add(seg.LAT_BR_Client__c);
        }
        
        mapIdtoSeg = new Map<Id, LAT_BR_ClientChannelSegmentation__c>([SELECT id, Name, LAT_BR_Client__c, LAT_BR_ObtainedProfile__c,LAT_TriggerInUsage__c, 
                                                                        LAT_BR_ObtainedBusinessSize__r.Name, LAT_BR_ObtainedProfile__r.Name 
                                                                        FROM LAT_BR_ClientChannelSegmentation__c 
                                                                        WHERE LAT_BR_Client__c IN: setIdOfAccOnSegAll]);
        
        mapIdtoAcc = new Map<Id, Account>([SELECT id, Name, Rating, Status__c, Subtype__c, Segmentation_Type_on_trade__c, 
                                                            Rating_segmentation_targert_market__c, LAT_BR_BusinessSize__c,
                                                            Reason_for_Inactivation__c 
                                                            FROM Account 
                                                            WHERE Id IN: setIdOfAccOnSegAll ]);
        
        if(trigger.isUpdate){
            //Saves Ids of Account and Segment Object
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if( ((mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no JDE' || mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no CRM') && (seg.LAT_BR_ApprovalStatus__c == 'Active' && seg.LAT_BR_ApprovalStatus__c != oldMap.get(seg.id).LAT_BR_ApprovalStatus__c)) || (mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Novo cadastro' || mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Não aprovado') && seg.LAT_BR_ApprovalStatus__c == 'Active' ){
                    setIdOfAccOnSeg.add(seg.LAT_BR_Client__c);
                    setIdOfSeg.add(seg.id);
                }
            }
        }else{
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(seg.LAT_BR_ApprovalStatus__c == 'Active'){
                    setIdOfAccOnSeg.add(seg.LAT_BR_Client__c);
                    setIdOfSeg.add(seg.id);
                }
            }
        }
        if(!setIdOfSeg.isEmpty()){
            //Changes all other segmentations status for the same account to Inactive
            if(trigger.isUpdate){
                for(LAT_BR_ClientChannelSegmentation__c seg: mapIdtoSeg.values()){
                    if(!setIdOfSeg.contains(seg.id) ){
                        seg.LAT_BR_ApprovalStatus__c = 'Inactive';
                        //Increase by one to update the field and avoid some validation rule
                        
                        seg.LAT_TriggerInUsage__c = (seg.LAT_TriggerInUsage__c != null ) ? seg.LAT_TriggerInUsage__c + 1 : 1;
                        listSeg.add(seg);
                    }
                }
            }
            
            //Create a map of of account with its id as the key
            
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(setIdOfAccOnSeg.contains(seg.LAT_BR_Client__c)){
                    //Match the fields of seg to the related Account
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Segmentation_Type_on_trade__c = seg.LAT_BR_ObtainedSubChannel__c;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Subtype__c = seg.LAT_BR_ONSegment__c;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_FiscalBenefit__c = seg.LAT_BR_HasCompetitorContract__c;

                    if(mapIdtoSeg.containsKey(seg.id)){
                        if(mapIdtoSeg.get(seg.id).LAT_BR_ObtainedProfile__c != null){
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating_segmentation_targert_market__c = mapIdtoSeg.get(seg.id).LAT_BR_ObtainedProfile__r.Name;
                        }else{
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating_segmentation_targert_market__c = null;
                        }
                        if(mapIdtoSeg.get(seg.id).LAT_BR_ObtainedBusinessSize__c != null){
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_BusinessSize__c = mapIdtoSeg.get(seg.id).LAT_BR_ObtainedBusinessSize__r.Name;
                        }else{
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_BusinessSize__c = null;
                        }
                    }
                    //ask if Account.Rating is Cliente inativo and change it to Cliente
                    if(mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating == 'Cliente inativo') {// && mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no JDE'){
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating = 'Cliente';
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c = 'Aprovado - Aguardando retorno do JDE';
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Reason_for_Inactivation__c = null;
                    }
                    
                    if(mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no JDE'){
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c = 'Aprovado - Aguardando retorno do JDE';
                    }
                   
                    
                    //add all the accounts with changes to a list to update
                    ListOfAccToUpdate.add(mapIdtoAcc.get(seg.LAT_BR_Client__c));
                }
            }
            //if(!ListOfAccToUpdate.isEmpty()){
            //    Savepoint sp = Database.setSavepoint();
            //    try{update ListOfAccToUpdate; update listSeg;}catch(system.DMLException e){Database.rollback(sp);}
            //}

            if(!ListOfAccToUpdate.isEmpty()){
                update ListOfAccToUpdate;
            }
            
            if (!listSeg.isEmpty()){
                update listSeg;
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: updatesAreaRegionalManager
    * Descripcion: Completes fields LAT_BR_AreaManager__c and LAT_BR_RegionalManager__c when a new record is created
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 02/06/2014
    * Modo: before Insert
    *****************************************************************************************/
    public static void updatesAreaRegionalManager(List<LAT_BR_ClientChannelSegmentation__c> triggerNew){
        
        Set<Id> setAccountIds = new Set<Id>();
        for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
            setAccountIds.add(seg.LAT_BR_Client__c);
        }
    
        if(!setAccountIds.isEmpty()){
            Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id, Area_Manager__c, Regional_Manager__c FROM Account WHERE Id IN: setAccountIds]);
            
            if(!mapAccounts.isEmpty()){
                for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                    if(mapAccounts.containsKey(seg.LAT_BR_Client__c)){
                        if(mapAccounts.get(seg.LAT_BR_Client__c).Area_Manager__c != null){
                            seg.LAT_BR_AreaManager__c = mapAccounts.get(seg.LAT_BR_Client__c).Area_Manager__c;
                        }
                        if(mapAccounts.get(seg.LAT_BR_Client__c).Regional_Manager__c != null){
                            seg.LAT_BR_RegionalManager__c = mapAccounts.get(seg.LAT_BR_Client__c).Regional_Manager__c;
                        }
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: updatesStatus
    * Descripcion: Updates LAT_BR_ApprovalStatus__c when a record is inserted
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 04/06/2014
    * Modo: before Insert
    *****************************************************************************************/
    public static void updatesStatus(List<LAT_BR_ClientChannelSegmentation__c> triggerNew){
    
        Set<Id> setAccountIds = new Set<Id>();
    
        for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
            setAccountIds.add(seg.LAT_BR_Client__c);
        }
        
        Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id, Status__c FROM Account WHERE Id IN: setAccountIds]);
        
        List<LAT_BR_ClientChannelSegmentation__c> listSegs = [SELECT Id, LAT_BR_Client__c FROM LAT_BR_ClientChannelSegmentation__c WHERE LAT_BR_Client__c IN: setAccountIds];
        
        Map<Id,Set<Id>> mapAccSeg = new Map<Id,Set<Id>>();
        
        for(LAT_BR_ClientChannelSegmentation__c seg: listSegs){
            if(!mapAccSeg.containsKey(seg.LAT_BR_Client__c)){
                mapAccSeg.put(seg.LAT_BR_Client__c, new Set<Id>{seg.Id});
            }else{
                mapAccSeg.get(seg.LAT_BR_Client__c).add(seg.Id);
            }
        }
        
        for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
            if(mapAccSeg.containsKey(seg.LAT_BR_Client__c)){
                seg.LAT_BR_ApprovalStatus__c = 'Draft';
            }else{
                if(mapAccounts.containsKey(seg.LAT_BR_Client__c) && (mapAccounts.get(seg.LAT_BR_Client__c).Status__c == 'Novo cadastro' || mapAccounts.get(seg.LAT_BR_Client__c).Status__c == 'Não aprovado')){
                    seg.LAT_BR_ApprovalStatus__c = 'Active';
                }else{
                    seg.LAT_BR_ApprovalStatus__c = 'Draft';
                }
            }
        }        
    } 

    /*****************************************************************************************
    * Nombre del metodo: validatesDelete
    * Descripcion: Validates that only records with status Draft con be deleted
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 04/06/2014
    * Modo: before Insert
    *****************************************************************************************/
    public static void validatesDelete(List<LAT_BR_ClientChannelSegmentation__c> triggerOld){

        Set<Id> setAllowProfiles = new Set<Id>();
        setAllowProfiles.add(LAT_GlobalProfileCache.getStandardAdminProfileId());
        setAllowProfiles.add(LAT_GlobalProfileCache.getProfileIdByName('PR BRAZIL System Administrator'));
        setAllowProfiles.add(LAT_GlobalProfileCache.getProfileIdByName('Business administrator'));
        setAllowProfiles.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator'));
        setAllowProfiles.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator'));
    
        for(LAT_BR_ClientChannelSegmentation__c seg: triggerOld){
            if(seg.LAT_BR_ApprovalStatus__c != 'Draft' && !setAllowProfiles.contains(Userinfo.getProfileId())){
                seg.addError(Label.LAT_BR_AP01_CCS_006);
                //Label.LAT_BR_AP01_CCS_006 = "Only records with status in "Filling" can be deleted."
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: ObtainedForOffTrade
    * Descripcion: fills various field on segmentation for recordtypes On Trade
    * Desarrollador: Denis Aranda
    * Fecha: 27/05/2014
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void ObtainedForOffTrade(List<LAT_BR_ClientChannelSegmentation__c> triggerNew, Map<Id,LAT_BR_ClientChannelSegmentation__c> oldMap){
        
        Map<String, List<LAT_BR_ClientSegmentationParameters__c>> mapKeyCFFBPLToPar = new Map<String, List<LAT_BR_ClientSegmentationParameters__c>>();
        Map<String, String> mapCodAnsToAnsCode = new Map<String, String>();
        Map<String, String> mapProLevToAnsCode = new Map<String, String>();
        Map<String, String> mapFisBenToAnsCode = new Map<String, String>();
        Map<String, String> mapBusSizToUdcId = new Map<String, String>();
        Set<String> setOfAllIdsOfAcc = new Set<String>();
        Set<String> setIdsOfSeg = new Set<String>();
        
        if(trigger.isUpdate){
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                setOfAllIdsOfAcc.add(seg.LAT_BR_Client__c);
                if(seg.LAT_BR_BusinessTargetAudience__c != oldMap.get(seg.id).LAT_BR_BusinessTargetAudience__c){
                    seg.LAT_BR_ObtainedPriorityLevel__c = null;
                    seg.LAT_BR_ObtainedFiscalBenefit__c = null;
                    seg.LAT_BR_ObtainedBusinessSize__c = null;
                    seg.LAT_BR_ObtainedSubChannel__c = null;
                    seg.LAT_BR_ObtainedChannel__c = null;
                    seg.LAT_BR_ObtainedSegment__c = null;
                    seg.LAT_BR_ObtainedProfile__c = null;
                    seg.LAT_BR_FiscalBenefit__c = null;
                    if(seg.LAT_BR_BusinessTargetAudience__c == 'Mostly Legal Entities'){
                        seg.LAT_BR_FiscalBenefit__c = 'No';   
                    }
                }
            }
        }else{
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(seg.LAT_BR_BusinessTargetAudience__c == 'Mostly Legal Entities' && seg.LAT_BR_FiscalBenefit__c == null){
                    seg.LAT_BR_FiscalBenefit__c = 'No';                   
                }
                setOfAllIdsOfAcc.add(seg.LAT_BR_Client__c);
            }
        }
        
        Map<Id, Account> mapIdToAcc = new Map<Id, Account>([SELECT Id, Name, Status__c, Customer_Flag__c FROM Account WHERE Id IN: setOfAllIdsOfAcc]);
      
        if(trigger.isUpdate){
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(seg.LAT_BR_ApprovalStatus__c == 'Draft' || seg.LAT_BR_ApprovalStatus__c == 'Rejected' || (seg.LAT_BR_ApprovalStatus__c == 'Active' && (mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Novo cadastro' || mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Não aprovado'))){
                    setIdsOfSeg.add(seg.id);
                }
            }
        }
        
        if(!setIdsOfSeg.isEmpty() || trigger.isInsert){
            
            //fills Maps
            List<LAT_BR_ClientSegmentationParameters__c> listCsp = [SELECT id, Name, LAT_BR_DataType__c, LAT_BR_Channel__c, LAT_BR_CustomerFlag__c, LAT_BR_Question__c, LAT_BR_Segment__c, LAT_BR_PriorityLevel__c, LAT_BR_FiscalBenefit__c, LAT_BR_BusinessSize__c, LAT_BR_Answer__c, LAT_BR_AnswerCode__c, LAT_BR_Key__c, LAT_BR_SubChannel__c, LAT_BR_Profile__c FROM LAT_BR_ClientSegmentationParameters__c ORDER BY LAT_BR_AnswerCode__c DESC];  
            for(LAT_BR_ClientSegmentationParameters__c par: listCsp){
                if(!mapKeyCFFBPLToPar.containsKey(par.LAT_BR_Key__c)){
                    mapKeyCFFBPLToPar.put(par.LAT_BR_Key__c, new List<LAT_BR_ClientSegmentationParameters__c>{par});
                }else{
                    mapKeyCFFBPLToPar.get(par.LAT_BR_Key__c).add(par);
                }
                //Map for Sub_Channel Code Answer
                if(par.LAT_BR_DataType__c == 'Code Answer'){
                    mapCodAnsToAnsCode.put(par.LAT_BR_Question__c +'-'+ par.LAT_BR_Answer__c, par.LAT_BR_AnswerCode__c);
                }
                if(par.LAT_BR_DataType__c == 'Priority Level'){
                    mapProLevToAnsCode.put(par.LAT_BR_Question__c +'-'+ par.LAT_BR_Answer__c , par.LAT_BR_PriorityLevel__c);    
                }
                if(par.LAT_BR_DataType__c == 'Fiscal Benefit'){
                    mapFisBenToAnsCode.put(par.LAT_BR_Question__c +'-'+ par.LAT_BR_Answer__c, par.LAT_BR_FiscalBenefit__c);
                }
                if(par.LAT_BR_DataType__c == 'Business Size'){
                    mapBusSizToUdcId.put(par.LAT_BR_Question__c +'-'+ par.LAT_BR_Answer__c, par.LAT_BR_BusinessSize__c);
                }
            }
            
            Map<String,List<LAT_BR_ClientSegmentationParameters__c>> mapCustomerFlags;
            Map<String,List<LAT_BR_ClientSegmentationParameters__c>> mapFiscalBenefit;
            List<LAT_BR_ClientSegmentationParameters__c> listParam1;
            List<LAT_BR_ClientSegmentationParameters__c> listParam3;
            
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(setIdsOfSeg.contains(seg.id) || trigger.isInsert){
                    boolean isMLE = false; //MLE = Mostly Legal Entities
                    
                    //sets the field LAT_BR_RelationshipLevel__c on segmentation
                    if(seg.LAT_BR_BusinessTargetAudience__c == 'Mostly Legal Entities'){ // check what happensa if it should return an error when the map doesn contain it
                        isMLE = true;
                        
                        if(mapProLevToAnsCode.containsKey('LAT_BR_RelationshipLevel__c' +'-'+ seg.LAT_BR_RelationshipLevel__c)){
                            seg.LAT_BR_ObtainedPriorityLevel__c = mapProLevToAnsCode.get('LAT_BR_RelationshipLevel__c' +'-'+ seg.LAT_BR_RelationshipLevel__c);
                        }else{
                            seg.addError(Label.LAT_BR_AP01_CCS_001); return;
                            //LAT_BR_AP01_CCS_001: Please revise your answers for the questionnaire, as no valid segmentation was found for Account with the answers provided.
                        }
                    }
                    
                    //Creates the key
                    List<String> Lkey = new List<String>();
                    if(seg.LAT_BR_BusinessTargetAudience__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_BusinessTargetAudience__c' +'-'+ seg.LAT_BR_BusinessTargetAudience__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_BusinessTargetAudience__c' +'-'+ seg.LAT_BR_BusinessTargetAudience__c));
                    }
                    if(seg.LAT_BR_MainAttentionChannel__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_MainAttentionChannel__c' +'-'+ seg.LAT_BR_MainAttentionChannel__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_MainAttentionChannel__c' +'-'+ seg.LAT_BR_MainAttentionChannel__c));
                    }          
                    if(seg.LAT_BR_PerformingArea__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_PerformingArea__c' +'-'+ seg.LAT_BR_PerformingArea__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_PerformingArea__c' +'-'+ seg.LAT_BR_PerformingArea__c));
                    }                     
                    if(seg.LAT_BR_SKUCategoriesAmount__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_SKUCategoriesAmount__c' +'-'+ seg.LAT_BR_SKUCategoriesAmount__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_SKUCategoriesAmount__c' +'-'+ seg.LAT_BR_SKUCategoriesAmount__c));
                    }                     
                    if(seg.LAT_BR_RelationshipLevel__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_RelationshipLevel__c' +'-'+ seg.LAT_BR_RelationshipLevel__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_RelationshipLevel__c' +'-'+ seg.LAT_BR_RelationshipLevel__c));
                    }                      
                    if(seg.LAT_BR_PortfolioType__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_PortfolioType__c' +'-'+ seg.LAT_BR_PortfolioType__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_PortfolioType__c' +'-'+ seg.LAT_BR_PortfolioType__c));
                    }
                    if(seg.LAT_BR_FiscalBenefit__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_FiscalBenefit__c' +'-'+ seg.LAT_BR_FiscalBenefit__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_FiscalBenefit__c' +'-'+ seg.LAT_BR_FiscalBenefit__c));
                    }                     
                    if(seg.LAT_BR_StoresTypes__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_StoresTypes__c' +'-'+ seg.LAT_BR_StoresTypes__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_StoresTypes__c' +'-'+ seg.LAT_BR_StoresTypes__c));
                    }                     
                    if(seg.LAT_BR_StoreScope__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_StoreScope__c' +'-'+ seg.LAT_BR_StoreScope__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_StoreScope__c' +'-'+ seg.LAT_BR_StoreScope__c));
                    }                     
                    if(seg.LAT_BR_StoreSize__c != null && mapCodAnsToAnsCode.containsKey('LAT_BR_StoreSize__c' +'-'+ seg.LAT_BR_StoreSize__c)){
                        Lkey.add(mapCodAnsToAnsCode.get('LAT_BR_StoreSize__c' +'-'+ seg.LAT_BR_StoreSize__c));
                    }                     
                    Lkey.sort();
                    
                    string key = '';
                    for(string str: Lkey){
                        key += str;
                    }
                    if(key.contains('null')){
                        key.replace('null','');
                    }
                    
                    mapCustomerFlags = new Map<String,List<LAT_BR_ClientSegmentationParameters__c>>();
                    mapFiscalBenefit = new Map<String,List<LAT_BR_ClientSegmentationParameters__c>>();
                    listParam1 = new List<LAT_BR_ClientSegmentationParameters__c>(); 
                    listParam3 = new List<LAT_BR_ClientSegmentationParameters__c>();
                    if(mapKeyCFFBPLToPar.containsKey(key)){
                        for(LAT_BR_ClientSegmentationParameters__c param: mapKeyCFFBPLToPar.get(key)){
                            //creo submapa de Customer Flags
                            if(param.LAT_BR_CustomerFlag__c != null){
                                if(!mapCustomerFlags.containsKey(param.LAT_BR_CustomerFlag__c)){
                                    mapCustomerFlags.put(param.LAT_BR_CustomerFlag__c, new List<LAT_BR_ClientSegmentationParameters__c>{param});
                                }else{
                                    mapCustomerFlags.get(param.LAT_BR_CustomerFlag__c).add(param);
                                }
                            }else{
                                if(!mapCustomerFlags.containsKey('NULL')){
                                    mapCustomerFlags.put('NULL', new List<LAT_BR_ClientSegmentationParameters__c>{param});
                                }else{
                                    mapCustomerFlags.get('NULL').add(param);
                                }
                            }
                        }
                        if(mapIdToAcc.get(seg.LAT_BR_Client__c).Customer_Flag__c != null && mapCustomerFlags.containsKey(mapIdToAcc.get(seg.LAT_BR_Client__c).Customer_Flag__c)){
                            listParam1 = mapCustomerFlags.get(mapIdToAcc.get(seg.LAT_BR_Client__c).Customer_Flag__c);
                        }else{
                            listParam1 = mapCustomerFlags.get('NULL');
                        }
                        
                        String AuxFiscalBenefit = null;
                        String FiscalBenefit = null;
                        if(seg.LAT_BR_FiscalBenefit__c == null){
                            AuxFiscalBenefit = 'No';
                        }else{
                            AuxFiscalBenefit = seg.LAT_BR_FiscalBenefit__c;
                        }
                        if(mapFisBenToAnsCode.containsKey('LAT_BR_FiscalBenefit__c' +'-'+ AuxFiscalBenefit)){
                            FiscalBenefit = mapFisBenToAnsCode.get('LAT_BR_FiscalBenefit__c' +'-'+ AuxFiscalBenefit);
                        }
                        
                        //creo submapa de FiscalBenefit
                        for(LAT_BR_ClientSegmentationParameters__c param: listParam1){
                            if(param.LAT_BR_FiscalBenefit__c != null){
                                if(!mapFiscalBenefit.containsKey(param.LAT_BR_FiscalBenefit__c)){
                                    mapFiscalBenefit.put(param.LAT_BR_FiscalBenefit__c, new List<LAT_BR_ClientSegmentationParameters__c>{param});
                                }else{
                                    mapFiscalBenefit.get(param.LAT_BR_FiscalBenefit__c).add(param);
                                }
                            }else{
                                if(!mapFiscalBenefit.containsKey('NULL')){
                                    mapFiscalBenefit.put('NULL', new List<LAT_BR_ClientSegmentationParameters__c>{param});
                                }else{
                                    mapFiscalBenefit.get('NULL').add(param);
                                }
                            } 
                        }
                        if(FiscalBenefit != null && mapFiscalBenefit.containsKey(FiscalBenefit)){
                            listParam3 = mapFiscalBenefit.get(FiscalBenefit);
                        }else{
                            listParam3 = mapFiscalBenefit.get('NULL');
                        }
                        if(listParam3 != null && !listParam3.isEmpty()){
                            seg.LAT_BR_ObtainedSubChannel__c = listParam3[0].LAT_BR_SubChannel__c;
                            seg.LAT_BR_ObtainedSegment__c = listParam3[0].LAT_BR_Segment__c;
                            seg.LAT_BR_ObtainedProfile__c = listParam3[0].LAT_BR_Profile__c;
                            seg.LAT_BR_ObtainedChannel__c = listParam3[0].LAT_BR_Channel__c;
                        }else{
                            seg.addError(Label.LAT_BR_AP01_CCS_001);  return;
                            //LAT_BR_AP01_CCS_001: Please revise your answers for the questionnaire, as no valid segmentation was found for Account with the answers provided.
                        }
                    }else{
                        seg.addError(Label.LAT_BR_AP01_CCS_001);  return;
                            //LAT_BR_AP01_CCS_001: Please revise your answers for the questionnaire, as no valid segmentation was found for Account with the answers provided.
                    }
                    
                    if(!isMLE && seg.LAT_BR_ObtainedSubChannel__c != 'C&C'){
                        seg.LAT_BR_ObtainedFiscalBenefit__c = null;
                        seg.LAT_BR_ObtainedPriorityLevel__c = null;
                        if(seg.LAT_BR_StoreSizeDetail__c == null && mapBusSizToUdcId.containsKey('LAT_BR_StoreSize__c' +'-'+ seg.LAT_BR_StoreSize__c)){
                            seg.LAT_BR_ObtainedBusinessSize__c = mapBusSizToUdcId.get('LAT_BR_StoreSize__c' +'-'+ seg.LAT_BR_StoreSize__c);
                        }else if(seg.LAT_BR_StoreSizeDetail__c != null && mapBusSizToUdcId.containsKey('LAT_BR_StoreSizeDetail__c' +'-'+ seg.LAT_BR_StoreSizeDetail__c)){
                            seg.LAT_BR_ObtainedBusinessSize__c = mapBusSizToUdcId.get('LAT_BR_StoreSizeDetail__c' +'-'+ seg.LAT_BR_StoreSizeDetail__c);
                        }else{
                            seg.addError(Label.LAT_BR_AP01_CCS_001);  return;
                            //LAT_BR_AP01_CCS_001: Please revise your answers for the questionnaire, as no valid segmentation was found for Account with the answers provided.
                        }
                    }else if(!isMLE && seg.LAT_BR_ObtainedSubChannel__c == 'C&C'){
                        seg.LAT_BR_ObtainedFiscalBenefit__c = null;
                        seg.LAT_BR_ObtainedPriorityLevel__c = null;
                        seg.LAT_BR_ObtainedBusinessSize__c = null;
                    }else if(isMLE){
                        seg.LAT_BR_ObtainedFiscalBenefit__c = mapFisBenToAnsCode.get('LAT_BR_FiscalBenefit__c' +'-'+ seg.LAT_BR_FiscalBenefit__c);
                        seg.LAT_BR_ObtainedBusinessSize__c = null;
                    }
                }
            }
        }
    }
    
    
    /*****************************************************************************************
    * Nombre del metodo: AccUpdaterFromSeg
    * Descripcion: Updates Account with the values from Segmentacion
    * Desarrollador: Denis Aranda
    * Fecha: 30/05/2014
    * Modo: after Insert, after Update
    *****************************************************************************************/
    public static void AccUpdaterFromSegOff(List<LAT_BR_ClientChannelSegmentation__c> triggerNew, Map<Id,LAT_BR_ClientChannelSegmentation__c> oldMap){
        
        Map<Id, LAT_BR_ClientChannelSegmentation__c> mapIdtoSeg;
        List<LAT_BR_ClientChannelSegmentation__c> listSeg = new List<LAT_BR_ClientChannelSegmentation__c>();
        List<Account> ListOfAccToUpdate = new List<Account>();
        Set<String> setIdOfAccOnSegAll = new Set<String>();
        Set<String> setIdOfSegAll = new Set<String>();
        Set<String> setIdOfAccOnSeg = new Set<String>();
        Set<String> setIdOfSeg = new Set<String>();
        
        for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
            setIdOfAccOnSegAll.add(seg.LAT_BR_Client__c);
            setIdOfSegAll.add(seg.id);
        }
        
        mapIdtoSeg = new Map<Id, LAT_BR_ClientChannelSegmentation__c>([SELECT id,LAT_TriggerInUsage__c, Name, LAT_BR_Client__c, LAT_BR_ObtainedProfile__c, LAT_BR_ObtainedProfile__r.Name, LAT_BR_ObtainedBusinessSize__c, LAT_BR_ObtainedBusinessSize__r.Name, LAT_BR_ObtainedFiscalBenefit__c, LAT_BR_ObtainedFiscalBenefit__r.Name, LAT_BR_ObtainedPriorityLevel__c, LAT_BR_ObtainedPriorityLevel__r.Name FROM LAT_BR_ClientChannelSegmentation__c WHERE LAT_BR_Client__c IN: setIdOfAccOnSegAll]);
        Map<Id, Account> mapIdtoAcc = new Map<Id, Account>([SELECT id, Name, Status__c, Reason_for_Inactivation__c, LAT_BR_FiscalBenefit__c, Is_Interface_Process_AR__c, LAT_BR_PriorityLevel__c, LAT_BR_BusinessSize__c, Rating, Sub_Channel_Rating__c, Rating_segmentation_targert_market__c, Channel__c, LAT_MX_Market__c, Segmentation_Type_on_trade__c, Subtype__c, LAT_BR_ActingFormat__c, CheckList_AR__c FROM Account WHERE Id IN: setIdOfAccOnSegAll ]);
        
        if(!trigger.isInsert){
            //Saves Ids of Account and Segment Object
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if((mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no JDE' || mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no CRM') && (seg.LAT_BR_ApprovalStatus__c == 'Active' && seg.LAT_BR_ApprovalStatus__c != oldMap.get(seg.id).LAT_BR_ApprovalStatus__c)){
                    setIdOfAccOnSeg.add(seg.LAT_BR_Client__c);
                    setIdOfSeg.add(seg.id);
                }else if((mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Novo cadastro' || mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Não aprovado') && seg.LAT_BR_ApprovalStatus__c == 'Active'){
                    setIdOfAccOnSeg.add(seg.LAT_BR_Client__c);
                    setIdOfSeg.add(seg.id);
                }
            }
        }else{
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(seg.LAT_BR_ApprovalStatus__c == 'Active'){
                    setIdOfAccOnSeg.add(seg.LAT_BR_Client__c);
                    setIdOfSeg.add(seg.id);
                }
            }
        }
        if(!setIdOfSeg.isEmpty()){
            //Changes all other segmentations status for the same account to Inactive
            if(!trigger.isInsert){
                for(LAT_BR_ClientChannelSegmentation__c seg: mapIdtoSeg.values()){
                    if(!setIdOfSeg.contains(seg.id) ){
                        seg.LAT_BR_ApprovalStatus__c = 'Inactive';

                        //Increase by one to update the field and avoid some validation rules
                        seg.LAT_TriggerInUsage__c = (seg.LAT_TriggerInUsage__c != null ) ? seg.LAT_TriggerInUsage__c + 1 : 1;
                        listSeg.add(seg);
                    }
                }
            }
            
            for(LAT_BR_ClientChannelSegmentation__c seg: triggerNew){
                if(setIdOfAccOnSeg.contains(seg.LAT_BR_Client__c)){
                    //Match the fields of seg to the related Account
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_ActingFormat__c = null;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Channel__c = seg.LAT_BR_ObtainedChannel__c;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_MX_Market__c = null;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Segmentation_Type_on_trade__c = null;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Subtype__c = null;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_PriorityLevel__c = null;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Sub_Channel__c = seg.LAT_BR_ObtainedSubChannel__c;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_ActingFormat__c = null;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).CheckList_AR__c = null;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Is_Interface_Process_AR__c = true;
                    mapIdtoAcc.get(seg.LAT_BR_Client__c).Sub_Channel_Rating__c = seg.LAT_BR_ObtainedSegment__c;
                    
                    if(mapIdtoSeg.containsKey(seg.id)){
                        if(mapIdtoSeg.get(seg.id).LAT_BR_ObtainedProfile__c != null){
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating_segmentation_targert_market__c = mapIdtoSeg.get(seg.Id).LAT_BR_ObtainedProfile__r.Name;
                        }else{
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating_segmentation_targert_market__c = null;
                        }
                        if(mapIdtoSeg.get(seg.id).LAT_BR_ObtainedBusinessSize__c != null){
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_BusinessSize__c = mapIdtoSeg.get(seg.Id).LAT_BR_ObtainedBusinessSize__r.Name;
                        }else{
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_BusinessSize__c = null;
                        }
                        if(mapIdtoSeg.get(seg.id).LAT_BR_ObtainedFiscalBenefit__c != null){
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_FiscalBenefit__c = mapIdtoSeg.get(seg.Id).LAT_BR_ObtainedFiscalBenefit__r.Name == 'SIM' ? true : false;
                        }else{
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_FiscalBenefit__c = false;
                        }
                        if(mapIdtoSeg.get(seg.id).LAT_BR_ObtainedPriorityLevel__c != null){
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_PriorityLevel__c = mapIdtoSeg.get(seg.Id).LAT_BR_ObtainedPriorityLevel__r.Name;
                            
                        }else{
                            mapIdtoAcc.get(seg.LAT_BR_Client__c).LAT_BR_PriorityLevel__c = null;
                        }
                    }
                    //ask if Account.Rating is Cliente inativo and change it to Cliente
                    if(mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating == 'Cliente inativo') { // && mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no JDE'){
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Rating = 'Cliente';
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c = 'Aprovado - Aguardando retorno do JDE';
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Reason_for_Inactivation__c = null;
                    }

                    if(mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c == 'Cliente cadastrado no JDE'){
                        mapIdtoAcc.get(seg.LAT_BR_Client__c).Status__c = 'Aprovado - Aguardando retorno do JDE';
                    }
                    
                    //add all the accounts with changes to a list to update
                    ListOfAccToUpdate.add(mapIdtoAcc.get(seg.LAT_BR_Client__c));
                    system.debug('TESTTESTTEST++++ ESTA EN OFF');

                }
            }
            if(!ListOfAccToUpdate.isEmpty()){
                update ListOfAccToUpdate;
            }

            system.debug('segBeforea+++++' + listSeg);
            system.debug(listSeg);
            if (!listSeg.isEmpty()){
                update listSeg;
                system.debug('segAfter+++++' + listSeg);
            }

        }
    }
}
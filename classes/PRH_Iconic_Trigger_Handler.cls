/**
NOV 20.2014
- added custom logic for Germany, When the outlet does not have a parent account, set Independent to TRUE.
FEB 11.2015
- commented out the logic for germany for prh issue fix deployment for uk iconic.
JAN 23.2017 
- correction of SFA issue with Iconic Account regarding field Suppress&Archive
*/
public class PRH_Iconic_Trigger_Handler{

    public static string stringCustomLogic (SObject obj, PRH_Iconic_Account_Trigger__c fieldMapping){
        string returnVal = null;

        //customization for HK Accounts
        /*if(fieldMapping.PRH_Account_Object_API__c == 'Account'){
            if(fieldMapping.PRH_Account_Record_Type__c == 'ASI_HK_CRM_Outlet' || fieldMapping.PRH_Account_Record_Type__c == 'ASI_HK_CRM_Potential_Account' || fieldMapping.PRH_Account_Record_Type__c =='ASI_HK_CRM_Potential_Account_Prestige'){
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Name_of_Contact__c'){
                    List<Contact> mainContact = [Select id, name From Contact where AccountID = :(id)obj.get('ID') and ASI_HK_CRM_Main_Contact__c = true];
                   if(mainContact!=null && mainContact.size()>0){
                        returnVal = mainContact.get(0).name;
                    }else{
                        returnVal = '';
                    }
                }    
            }
        }*/
        
        //customization for USA Accounts
        if(fieldMapping.PRH_Account_Object_API__c == 'Account'){   
            if(fieldMapping.PRH_Account_Record_Type__c == 'USA_Account'){
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Detailed_address__c'){
                   Account acc = (Account)obj;
                   if(acc.BillingStreet != null)
                       returnVal = acc.BillingStreet;
                   if(acc.BillingCity != null && acc.BillingStreet != null)
                       returnVal += ', '+acc.BillingCity;
                   else if(acc.BillingCity != null)
                       returnVal = acc.BillingCity;
                       
                   if(acc.BillingState != null && (acc.BillingCity != null || acc.BillingStreet != null))
                       returnVal += ', '+acc.BillingState;
                   else if(acc.BillingState != null)
                       returnVal += acc.BillingState;
                       
                   if(acc.BillingPostalCode != null)
                       returnVal += ', '+acc.BillingPostalCode;
                   if(acc.BillingCountry != null)
                       returnVal += ', '+acc.BillingCountry;
                }    
            }
        }

        //customization for Brazil Accounts
        if(fieldMapping.PRH_Account_Object_API__c == 'Account'){
            if(fieldMapping.PRH_Account_Record_Type__c == 'On_Trade'){
                /*if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Name_of_Contact__c'){
                    List<Contact> mainContact = [Select id, name From Contact where AccountID = :(id)obj.get('ID')];
                   if(mainContact!=null && mainContact.size()>0){
                        returnVal = mainContact.get(0).name;
                    }else{
                        returnVal = '';
                    }
                }  */
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Account_Type__c'){
                    if((String)obj.get('Segmentation_Type_on_trade__c') == 'Bar'){
                        returnVal = 'Low Energy Bar';
                    }
                    if((String)obj.get('Segmentation_Type_on_trade__c') == 'Bar Agitado'){
                        returnVal = 'High Energy Bar';
                    }
                    if((String)obj.get('Segmentation_Type_on_trade__c') == 'Casa Noturna'){
                        returnVal = 'Night Club';
                    }
                    if((String)obj.get('Segmentation_Type_on_trade__c') == 'Restaurante'){
                        returnVal = 'Restaurant';
                    }
                    if((String)obj.get('Segmentation_Type_on_trade__c') == 'Restaurante'){
                        returnVal = 'Restaurant';
                    }
                } 
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Detailed_address__c'){
                     if(obj.get('Revenue_Address__c')!= null)
                          returnVal = obj.get('Revenue_Address__c')+', ' ;
                     if(obj.get('Revenue_Number__c')!= null)
                       returnVal += obj.get('Revenue_Number__c') +', ';
                     if(obj.get('Revenue_Complement__c')!= null)
                       returnVal +=obj.get('Revenue_Complement__c') +', ';
                     if(obj.get('Revenue_Neighbourhood__c')!= null)
                       returnVal += obj.get('Revenue_Neighbourhood__c')+', ';
                     if(obj.get('Revenue_UF__c')!= null)  
                       returnVal += obj.get('Revenue_UF__c');
                } 
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_City__c'){
                      ID cityID = (id)obj.get('Revenue_City__c');
                      if(cityID != null){
                          UDC__c city = [Select name from UDC__c where id = :cityID];
                          returnVal = city.Name;
                      }
                }
            }
        }
       
        // Changes the Image Level from Nightclub to Night Club in Iconic Accounts
        if(fieldMapping.PRH_Account_Object_API__c == 'EUR_CRM_Account__c'){
            if(obj.get('EUR_CRM_Group_Outlet_Type_Name__c') == 'Nightclub'){
                returnVal ='Night Club';
            }else{
                returnVal = (string)obj.get('EUR_CRM_Group_Outlet_Type_Name__c');
            }
        }
        return returnVal;
    }
    
    public static boolean booleanCustomLogic (SObject obj,PRH_Iconic_Account_Trigger__c fieldMapping){
        boolean returnVal = false;
        //adds each case according to record type and perform customization
        
        //customization for HK Accounts
        if(fieldMapping.PRH_Account_Object_API__c == 'Account'){
            if(fieldMapping.PRH_Account_Record_Type__c == 'ASI_HK_CRM_Outlet' ||fieldMapping.PRH_Account_Record_Type__c == 'ASI_HK_CRM_Potential_Account'|| fieldMapping.PRH_Account_Record_Type__c =='ASI_HK_CRM_Potential_Account_Prestige'){
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Suppress_and_archive__c'){
                    if(obj.get('ASI_HK_CRM_Status__c') =='Active'){
                        returnVal = false;
                    }else{
                        returnVal = true;
                    }
                } 
            }
        }
        
        //customization for Brazil Accounts
        if(fieldMapping.PRH_Account_Object_API__c == 'Account'){
            if(fieldMapping.PRH_Account_Record_Type__c == 'On_Trade'){
 
                /* LCS-1250 if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Contracted__c'){
                      if((string)obj.get('Rating') == 'Cliente com contrato') returnVal=true;
                }*/
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Suppress_and_archive__c'){
                   if((string)obj.get('Rating') == 'Cliente inativo') returnVal=true;
                }
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Independent__c'){
                   if((string)obj.get('ParentID') == null) returnVal=true;
                } 
             }
          }
         //customization for Germany Accounts NOV.20.2014
         //commented out for Feb 11, 2015 deployment issue fix. as of this time germany is not yet in production
         /*
        if(fieldMapping.PRH_Account_Object_API__c == 'EUR_CRM_Account__c' && 
           fieldMapping.PRH_Account_Record_Type__c == 'EUR_DE_ON_Gastronomy' &&
           fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Independent__c'){
           return obj.get('EUR_CRM_Parent_Account__c') == null; 
        } 
        */
        //customization for UK Accounts
        
        if(fieldMapping.PRH_Account_Object_API__c == 'EUR_CRM_Account__c'){
            if(fieldMapping.PRH_Account_Record_Type__c == 'EUR_GB_FS_Indirect'){
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Independent__c'){
                System.debug('TEST EPIC Trigger : ' + returnVal );
                    System.debug('TEST EPIC Trigger : ' + obj.get('EUR_CRM_Parent_Account__c') );
                    if(obj.get('EUR_CRM_Parent_Account__c') == null){
                        returnVal = true;
                    }
                    ID oid = (id)obj.get('ID');
                    List<EUR_CRM_Account__c> childAccounts = [Select id from EUR_CRM_Account__c where EUR_CRM_Parent_Account__c = :oid];
                    
                    System.debug('TEST EPIC Trigger : ' + childAccounts );
                    if(returnVal == true && childAccounts.size()== 0){
                        returnVal = true;
                    }else{
                        returnVal = false;
                    }
                    
                } 
                if(fieldMapping.PRH_Iconic_Account_Field_API__c == 'PRH_Suppress_and_archive__c'){
                    System.debug('TEST ICONIC ' + obj.get('EUR_CRM_Status__c') + ' ' + obj.get('EUR_CRM_Image_Level_Name__c')  );
                    if((obj.get('EUR_CRM_Status__c') == 'Active' && obj.get('EUR_CRM_Image_Level_Name__c') == 'Iconic') ||
                        (obj.get('EUR_CRM_Status__c') == 'Active' && (boolean)obj.get('EUR_CRM_Force_Iconic_Account__c'))){
                         returnVal = false;
                         System.debug('PRH_Iconic_Trigger_Handler, booleanCustomLogic() returnVal=' + returnVal );
                    }else{
                         //returnVal = true;  
                         //System.debug('PRH_Iconic_Trigger_Handler, booleanCustomLogic() returnVal=' + returnVal );
                         returnVal = false;
                         System.debug('PRH_Iconic_Trigger_Handler, booleanCustomLogic() new value after SFA issue correction, returnVal=' + returnVal );
                    }

                   System.debug('ENTRY TEST HANDLER :' + trigger.isDelete );
                }   
            }
        }
        
        System.debug('Test final : ' + returnval);
        return returnVal;   
    }

}
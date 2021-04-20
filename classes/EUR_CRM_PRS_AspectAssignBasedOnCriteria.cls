/*
 * This class is used to set the automatically a value of the segmentation (BP, BBP, VP or IL)
 * using a value of the account object (Customer_taxonomy__r.EUR_CRM_Business_Potential__c, etc...)
 * 
 * Use by Belgium only for the moment
 * 
 * Important: For the moment it cannot be used alone, a set of question must exist 
 * 	(BP if BBP autoset, BBP if BP autoset, VP if IL autoset & IL if VP autoset)
 * 
 * Test class: EUR_CRM_PRS_AspBasedOnCriteriaTest
 */
public class EUR_CRM_PRS_AspectAssignBasedOnCriteria {
    //Lower case are importants
    private static Map<String, String> mappingForceField = new Map<String, String> {
        'eur_crm_business_potential__c' => 'EUR_CRM_Force_Business_potential__c',
        'eur_crm_brand_building_potential__c' => 'EUR_CRM_Force_Brand_Building_Potential__c',
        'eur_crm_volume_potential__c' => 'EUR_CRM_Force_PRS_Volume_Potential__c',
        'eur_crm_image_level__c' => 'EUR_CRM_Force_PRS_Volume_Potential__c'
    };
    
    public static boolean hasBPLogic(Map<String, EUR_PROS_PROFS_Assignment__mdt> criterias) {
        return criterias.containsKey('EUR_CRM_Business_Potential__c'.toLowerCase());
    }
    public static boolean hasBBPLogic(Map<String, EUR_PROS_PROFS_Assignment__mdt> criterias) {
        return criterias.containsKey('EUR_CRM_Brand_Building_Potential__c'.toLowerCase());
    }
    public static boolean hasILLogic(Map<String, EUR_PROS_PROFS_Assignment__mdt> criterias) {
        return criterias.containsKey('EUR_CRM_Image_Level__c'.toLowerCase());
    }
    public static boolean hasVPLogic(Map<String, EUR_PROS_PROFS_Assignment__mdt> criterias) {
        return criterias.containsKey('EUR_CRM_Volume_Potential__c'.toLowerCase());
    }
    
    /*
     * Retrive the existing specific rule for the account from the metadata
     */
    public static Map<String, EUR_PROS_PROFS_Assignment__mdt> retrieveMetadata(String accountRecordType) {
        Map<String, EUR_PROS_PROFS_Assignment__mdt> map_criterias = new Map<String, EUR_PROS_PROFS_Assignment__mdt>();
        List<EUR_PROS_PROFS_Assignment__mdt> criterias = [
            SELECT 
            	Id,
            	EUR_CRM_Account_API_Name_Fields__c,
            	EUR_CRM_Account_PROS_PROF_API_Name_Field__c,
            	EUR_CRM_Account_Record_Types__c,
            	EUR_CRM_PRS_Seg_Aspect_Record_Types__c,
            	EUR_CRM_PRS_Segmentation_API_Name_Field__c
            FROM 
            	EUR_PROS_PROFS_Assignment__mdt 
            WHERE 
            	EUR_CRM_Account_Record_Types__c = :accountRecordType];
        
        for(EUR_PROS_PROFS_Assignment__mdt c : criterias) {
            //To match SOQL, we will not save this record
            c.EUR_CRM_Account_API_Name_Fields__c = c.EUR_CRM_Account_API_Name_Fields__c.toLowerCase().replaceAll('__c\\.', '__r.');
            c.EUR_CRM_PRS_Segmentation_API_Name_Field__c = c.EUR_CRM_PRS_Segmentation_API_Name_Field__c.toLowerCase();
            
            map_criterias.put(c.EUR_CRM_PRS_Segmentation_API_Name_Field__c, c);
            
        }
        
        return map_criterias;
    }
    
    public static void run(EUR_CRM_Account__c a, EUR_CRM_PRS_Segmentation__c prs) {
        
        //Rules that apply for the record types 
        Map<String, EUR_PROS_PROFS_Assignment__mdt> rules = retrieveMetadata(a.RecordType.DeveloperName);
        
        //If we found associated rules for this account's record type
        if(!rules.isEmpty()) {
            //Query for the fields in the account because the current object might not have retrieved the right information
            List<String> fields = new List<String>();
            
            for(String prsField : rules.keySet()) {
                EUR_PROS_PROFS_Assignment__mdt rule = rules.get(prsField);
                if(!fields.contains(rule.EUR_CRM_Account_API_Name_Fields__c.toLowerCase())) {
                    fields.add(rule.EUR_CRM_Account_API_Name_Fields__c.toLowerCase());
                }
                if(!fields.contains(mappingForceField.get(rule.EUR_CRM_PRS_Segmentation_API_Name_Field__c))) {
                    fields.add(mappingForceField.get(rule.EUR_CRM_PRS_Segmentation_API_Name_Field__c));
                }
            }
            
            String accountId = a.Id;
            //No try catch, if the admin did not configure it correctly it should throw an exception
            //It should work all the time when the admin configure it correctly
            String query = 'SELECT ' + String.join(fields, ',') + ' FROM EUR_CRM_Account__c WHERE Id = :accountId';
            System.debug(query);
            EUR_CRM_Account__c tmp = Database.query(query);
            System.debug(tmp);
            
            
            //Now we have the selected the fields we can run the rule
            for(String prsField : rules.keySet()) {
                EUR_PROS_PROFS_Assignment__mdt rule = rules.get(prsField);
                
                String valueField = rule.EUR_CRM_Account_API_Name_Fields__c;
                /*
                System.debug('TAXO : ');
                sObject taxo = tmp.getSobject('eur_jb_customer_taxonomy__r');
                System.debug(taxo);
                System.debug('POTENTIAL : ');
                sObject pot = (sObject) taxo.getSObject('eur_crm_business_potential__r');
                System.debug(pot);
                System.debug('ID : ');
                System.debug(pot.get('id'));
                System.debug('end');*/
                String value = goThroughFieldRelationship(rule.EUR_CRM_Account_API_Name_Fields__c, tmp);
                String accField = rule.EUR_CRM_Account_PROS_PROF_API_Name_Field__c;
                
                System.debug('Value to push : ' + value);
				//It works here because in the retrieveMetadata we have replaced __c by __r         
                //Set PRS Segmentation field
               	prs.put(prsField, value);
               
                String forceField = mappingForceField.get(prsField);
                
                //Do not set PRS Account field if it is forced
                if(tmp.get(forceField) == null) {
                    
                    //Set Account PRS Field
                    a.put(accField, value);
                   
                } else {
                    System.debug('Account not updated because field is forced on account');
                }
            }
        }
    }
    
    private static String goThroughFieldRelationship(String field, sObject o) {
        System.debug('goThroughFieldRelationship');
        
        List<String> fields = field.split('\\.');
        
        System.debug('Fields : ' + fields);
        if(fields.size() == 1) {
            return (String) o.get(field);
        } else {
            String first = fields.get(0);
            fields.remove(0);
            
            sObject nextRelation = o.getSObject(first);
            if(nextRelation == null) {
                return null;
            } else {
                return goThroughFieldRelationship(String.join(fields, '.'), nextRelation);
            }
            
        }
    }
}
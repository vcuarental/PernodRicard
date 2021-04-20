public with sharing class LAT_TestUserAdmin {

public  static User userWithAdminPorf (String firstName, String lastName, String alias, String email, String username, String communityNickname, String emailEncodingKey,
																					String timeZoneSidKey, String localeSidKey, String languageLocaleKey, String codigoJDE, String country){

     List<LAT_GeneralConfig__c> listGeneralConfigValues = [select Name,LAT_Value__c from LAT_GeneralConfig__c where name = 'Admin'];
     String[] profileNames;

     if(listGeneralConfigValues != null && listGeneralConfigValues.size()>0){
          profileNames = listGeneralConfigValues[0].LAT_Value__c.split(',', 0);
     }

     system.debug('profileNames' + profileNames);
     LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(Name = 'Admin', LAT_Value__c = 'LAT_SystemAdministrator');

     if(profileNames == null ){
          insert cfg;
          profileNames = LAT_GeneralConfigDao.getValueAsStringArray('Admin', ',');
     }
     system.debug('profileNames 2' + profileNames);

     if(profileNames == null)profileNames = new List<String>{'LAT_SystemAdministrator'};
     //String[] profileNames = LAT_GeneralConfigDao.getValueAsStringArray('Admin', ',');
     Profile perfil = [Select Id From Profile Where  Name IN :profileNames LIMIT 1]; 
 
     system.debug('aaaaaa ' + perfil);
     User usuario = new User();
     usuario.FirstName = firstName; // 'Nome2';
     usuario.LastName = lastName; //'Sobrenome2';
     usuario.Alias = alias; //'NSobre2';
     usuario.Email = email; //'nome2@sobrenome.com';
     usuario.Username = username; ///'PriceCalculationInterface@mail.com';
     usuario.CommunityNickname = communityNickname; //'123jjjuuu2';
     usuario.EmailEncodingKey = emailEncodingKey; //'ISO-8859-1';
     usuario.TimeZoneSidKey = timeZoneSidKey; //'GMT';
     usuario.LocaleSidKey = localeSidKey; //'en_Us';
     usuario.LanguageLocaleKey = languageLocaleKey; //'en_Us';
     usuario.C_digo_JDE__c = codigoJDE; //'234';
     usuario.ProfileId = perfil.Id;
     usuario.Country = country; //'BR';

     return usuario; 
	}
}
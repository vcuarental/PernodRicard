public class GRP_CC_Caroussel_CTRL {
    @AuraEnabled
    public static List<String> getUrlImage(Id idDeepDive, String ecran){
 
        List<String>l_idFichier = new List<String>();
        
        ecran = ecran + '%';
        
        for ( COntentDocumentLink cdl : [SELECT ContentDocument.latestpublishedversionid
                                         FROM ContentDocumentLink 
                                         where linkedentityid = :idDeepDive 
                                         and ContentDocument.Title LIKE :ecran 
                                         and ContentDocument.fileextension IN ('png', 'jpg', 'jpeg')
                                         order by ContentDocument.Title ASC]){
        	l_idFichier.add(cdl.ContentDocument.latestpublishedversionid);
        }
        //return new List<String>{'a'};
        return l_idFichier;
    }
    
    
 
}
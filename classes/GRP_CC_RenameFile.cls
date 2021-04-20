global class GRP_CC_RenameFile { 
    @InvocableMethod 
    public static void getRenameFile(List<String> idFile) 
    { 
        string idFichier = idFile.get(0).split(';').get(0);
        string prefix = idFile.get(0).split(';').get(1);
        system.debug(idFile);
        ContentDocument fichier = [SELECT Id, Title FROM ContentDocument WHERE id=:idFichier];
        fichier.Title = prefix + fichier.Title;
        
        update fichier;
    } 
}
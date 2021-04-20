public without sharing class ASI_CTY_CN_Vendor_DownLoadController {


	 @AuraEnabled
	 public static List<DocumentInfo> getDownLoadList(String filesName)
	 {
	 	List<Document> doclist = [SELECT Id,Name,Type,Body FROM Document WHERE Folder.Name =:filesName ];

	 	List<DocumentInfo> strList = new  List<DocumentInfo>();
	 	for(Document doc:doclist)
	 	{
	 	  DocumentInfo info = new DocumentInfo();
          Blob  str = doc.Body;

          info.body = EncodingUtil.base64Encode(str);
          info.name = doc.Name;
          info.type = doc.Type;
          strList.add(info);
	 	}
	 	return strList;
	 }


	 public Class DocumentInfo{
        @AuraEnabled
	 	public String name;
        @AuraEnabled
	 	public String type;
        @AuraEnabled
	 	public String body;
	 }
    
}
/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/syncmanager/*')
global class SyncManagerService {
    global SyncManagerService() {

    }
    @HttpPost
    global static void doPost(clm.SyncManagerService.SyncBodyWrapper data) {

    }
global class SyncBodyWrapper {
    global String action;
    global Map<String,List<Map<String,String>>> errors;
    global String fileBody;
    global SObject fileData;
    global Map<String,List<SObject>> items;
    global Map<String,String> itemsMap;
    global String userId;
    global SyncBodyWrapper() {

    }
}
}

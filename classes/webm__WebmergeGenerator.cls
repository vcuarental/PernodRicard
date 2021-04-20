/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class WebmergeGenerator {
    global WebmergeGenerator() {

    }
    global static System.HttpResponse doMerge(String jsonString, String mergeUrl) {
        return null;
    }
    global static System.HttpResponse doMerge(Map<String,String> mergeData, String mergeUrl) {
        return null;
    }
    global static System.HttpResponse doPreview(String jsonString, String mergeUrl) {
        return null;
    }
    global static System.HttpResponse doPreview(Map<String,String> mergeData, String mergeUrl) {
        return null;
    }
    global static Boolean generateDocument(String wmMappingId, String sfObjectId, String sfObjectName) {
        return null;
    }
    webService static void generateDocumentBatchCombinedJS(String wmMappingId, List<String> sfObjectIds, String sfObjectName) {

    }
    global static Boolean generateDocumentBatchCombined(List<Map<String,String>> mappingsAndRecords) {
        return null;
    }
    global static Boolean generateDocumentBatchCombined(List<Map<String,String>> mappingsAndRecords, String batchSettings) {
        return null;
    }
    global static Boolean generateDocumentBatchCombined(Map<String,List<String>> mappingsAndRecords) {
        return null;
    }
    global static Boolean generateDocumentBatchCombined(Map<String,List<String>> mappingsAndRecords, String batchSettings) {
        return null;
    }
    global static Boolean generateDocumentBatchCombined(String wmMappingId, List<String> sfObjectIds, String sfObjectName) {
        return null;
    }
    global static Boolean generateDocumentBatchCombined(String wmMappingId, List<String> sfObjectIds, String sfObjectName, String batchSettings) {
        return null;
    }
    webService static void generateDocumentBatchJS(String wmMappingId, List<String> sfObjectIds, String sfObjectName) {

    }
    global static Boolean generateDocumentBatch(String wmMappingId, List<String> sfObjectIds, String sfObjectName) {
        return null;
    }
    global static List<Attachment> generateDocumentGetAttachments(String wmMappingId, String sfObjectId, String sfObjectName) {
        return null;
    }
    global static String generateDocumentGetUrl(String wmMappingId, String sfObjectId, String sfObjectName) {
        return null;
    }
    webService static void generateDocumentJS(String wmMappingId, String sfObjectId, String sfObjectName) {

    }
    @InvocableMethod(label='Generate Document')
    global static void generateDocument(List<webm.WebmergeGenerator.MergeRequest> requests) {

    }
    global static Boolean mergeReport(String reportId, String mergeUrl) {
        return null;
    }
    global static System.HttpResponse mergeReportGetResponse(String reportId, String mergeUrl) {
        return null;
    }
    global static String previewDocument(String wmMappingId, String sfObjectId, String sfObjectName) {
        return null;
    }
global class MergeRequest {
    @InvocableVariable(label='Salesforce Record ID' required=true)
    global String sfRecordId;
    @InvocableVariable(label='WebMerge Mapping ID' required=true)
    global String wmMappingId;
    global MergeRequest() {

    }
}
}

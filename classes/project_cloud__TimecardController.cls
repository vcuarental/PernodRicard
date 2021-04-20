/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class TimecardController {
    global List<project_cloud__Work__c> cellEntries {
        get;
    }
    global List<String> labels {
        get;
    }
    global Boolean loadedLastWeek {
        get;
    }
    global List<System.SelectOption> relationshipOptions {
        get;
    }
    global List<project_cloud.TimecardController.TimecardRow> rows {
        get;
    }
    global Date suggestDayFilter {
        get;
        set;
    }
    global List<System.SelectOption> suggestDayFilterOptions {
        get;
    }
    global List<project_cloud.TimecardController.SuggestItem> suggestItems {
        get;
    }
    global String suggestObjectFilter {
        get;
        set;
    }
    global List<System.SelectOption> suggestObjectFilterOptions {
        get;
    }
    global project_cloud__Work__c timeEntry {
        get;
        set;
    }
    global String timeEntryDate {
        get;
        set;
    }
    global Id timeEntryRelatedTo {
        get;
        set;
    }
    global String timeEntryRelatedToField {
        get;
        set;
    }
    global String timeEntryRelatedToLabel {
        get;
        set;
    }
    global project_cloud__Timesheet__c timesheet {
        get;
    }
    global TimecardController() {

    }
    @Deprecated
    global System.PageReference cancel() {
        return null;
    }
    @Deprecated
    global System.PageReference clearTimeEntryRelationships() {
        return null;
    }
    @Deprecated
    global System.PageReference createMissingTimesheet() {
        return null;
    }
    @Deprecated
    global virtual System.PageReference loadCellEntries() {
        return null;
    }
    @Deprecated
    global virtual System.PageReference loadLastWeek() {
        return null;
    }
    @Deprecated
    global System.PageReference next() {
        return null;
    }
    @Deprecated
    global System.PageReference previous() {
        return null;
    }
    @Deprecated
    global virtual System.PageReference saveCellEntries() {
        return null;
    }
    @Deprecated
    global virtual System.PageReference saveStandaloneEntry() {
        return null;
    }
global class TimecardDeprecatedException extends Exception {
}
global class TimecardRow {
    global List<String> dates {
        get;
    }
    global Decimal day0 {
        get;
    }
    global Decimal day1 {
        get;
    }
    global Decimal day2 {
        get;
    }
    global Decimal day3 {
        get;
    }
    global Decimal day4 {
        get;
    }
    global Decimal day5 {
        get;
    }
    global Decimal day6 {
        get;
    }
    global String name {
        get;
    }
    global Id relatedTo {
        get;
    }
    global String relatedToField {
        get;
    }
    global System.PageReference relatedToLookupHoverDetail {
        get;
    }
    global Decimal sum {
        get;
    }
    global TimecardRow(List<project_cloud__Work__c> existing, Date day0Date, String name, String relatedToField, Id relatedTo) {

    }
}
}
